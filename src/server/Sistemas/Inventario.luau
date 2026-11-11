local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estado = require(script.Parent.Estado)

local Inventario = {}

local RECURSOS = { "Lena", "Chatarra", "Comida" }

function Inventario.cantidad(jugador: Player, recurso: string): number
	return jugador:GetAttribute(recurso) or 0
end

function Inventario.dar(jugador: Player, recurso: string, n: number)
	jugador:SetAttribute(recurso, Inventario.cantidad(jugador, recurso) + n)
end

function Inventario.quitar(jugador: Player, recurso: string, n: number)
	jugador:SetAttribute(recurso, math.max(0, Inventario.cantidad(jugador, recurso) - n))
end

function Inventario.puedePagar(jugador: Player, coste): boolean
	for recurso, n in coste do
		if Inventario.cantidad(jugador, recurso) < n then
			return false
		end
	end
	return true
end

function Inventario.pagar(jugador: Player, coste): boolean
	if not Inventario.puedePagar(jugador, coste) then
		return false
	end
	for recurso, n in coste do
		Inventario.quitar(jugador, recurso, n)
	end
	return true
end

function Inventario.humanoide(jugador: Player): Humanoid?
	local personaje = jugador.Character
	local hum = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		return hum
	end
	return nil
end

local function alAparecer(jugador: Player, personaje: Model)
	local hum = personaje:WaitForChild("Humanoid") :: Humanoid
	jugador:SetAttribute("Hambre", math.max(jugador:GetAttribute("Hambre") or 0, Config.HAMBRE.AL_REAPARECER))
	hum.Died:Connect(function()
		local perdido = Inventario.cantidad(jugador, "Lena") + Inventario.cantidad(jugador, "Chatarra")
		jugador:SetAttribute("Lena", 0)
		jugador:SetAttribute("Chatarra", math.floor(Inventario.cantidad(jugador, "Chatarra") / 2))
		if perdido > 0 then
			Estado.notificar(jugador, "💀 Has caído... perdiste la leña y parte de la chatarra que llevabas.", Color3.fromRGB(255, 120, 120))
		end
	end)
end

local ultimoBocado = {}

local function comer(jugador: Player)
	local ahora = os.clock()
	if ultimoBocado[jugador] and ahora - ultimoBocado[jugador] < 0.5 then
		return
	end
	ultimoBocado[jugador] = ahora
	local hum = Inventario.humanoide(jugador)
	if not hum then
		return
	end
	if Inventario.cantidad(jugador, "Comida") <= 0 then
		Estado.notificar(jugador, "No tienes comida. Busca manzanas en el huerto o en la despensa de la cocina.")
		return
	end
	local hambre = jugador:GetAttribute("Hambre") or 0
	if hambre >= Config.HAMBRE.MAXIMA - 1 and hum.Health >= hum.MaxHealth then
		Estado.notificar(jugador, "No tienes hambre ahora mismo.")
		return
	end
	Inventario.quitar(jugador, "Comida", 1)
	jugador:SetAttribute("Hambre", math.min(Config.HAMBRE.MAXIMA, hambre + Config.HAMBRE.POR_COMIDA))
	hum.Health = math.min(hum.MaxHealth, hum.Health + Config.HAMBRE.CURA_COMIDA)
	Estado.notificar(jugador, "🍎 ¡Ñam!", Color3.fromRGB(150, 230, 120))
end

function Inventario.iniciar()
	local function alEntrar(jugador: Player)
		for _, recurso in RECURSOS do
			jugador:SetAttribute(recurso, 0)
		end
		jugador:SetAttribute("Hambre", Config.HAMBRE.MAXIMA)
		jugador:SetAttribute("TieneHacha", false)
		jugador:SetAttribute("TieneFarol", false)
		jugador.CharacterAdded:Connect(function(personaje)
			alAparecer(jugador, personaje)
		end)
		if jugador.Character then
			alAparecer(jugador, jugador.Character)
		end
	end
	Players.PlayerAdded:Connect(alEntrar)
	for _, jugador in Players:GetPlayers() do
		task.spawn(alEntrar, jugador)
	end
	Players.PlayerRemoving:Connect(function(jugador)
		ultimoBocado[jugador] = nil
	end)

	Estado.remotos.Comer.OnServerEvent:Connect(comer)

	task.spawn(function()
		while true do
			task.wait(1)
			for _, jugador in Players:GetPlayers() do
				local hum = Inventario.humanoide(jugador)
				if hum and Estado.get("Fase") ~= "Escape" then
					local hambre = math.max(0, (jugador:GetAttribute("Hambre") or 0) - Config.HAMBRE.GASTO)
					jugador:SetAttribute("Hambre", hambre)
					if hambre <= 0 then
						hum:TakeDamage(Config.HAMBRE.DANO_SIN_COMIDA)
					end
				end
			end
		end
	end)
end

return Inventario
