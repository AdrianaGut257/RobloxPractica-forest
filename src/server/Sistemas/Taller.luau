local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estado = require(script.Parent.Estado)
local Inventario = require(script.Parent.Inventario)
local Chimenea = require(script.Parent.Chimenea)
local Armas = require(script.Parent.Armas)
local Util = require(script.Parent.Parent.Mundo.Util)

local Taller = {}

local DISTANCIA_MAXIMA = 20
local mesa: BasePart? = nil

local function buscarReceta(id: string)
	for _, receta in Config.RECETAS do
		if receta.id == id then
			return receta
		end
	end
	return nil
end

local function aplicar(jugador: Player, receta): boolean
	local hum = Inventario.humanoide(jugador)
	if receta.id == "Botiquin" then
		if not hum then
			return false
		end
		hum.Health = hum.MaxHealth
	elseif receta.id == "Hacha" then
		jugador:SetAttribute("TieneHacha", true)
		Armas.dar(jugador, "Hacha")
	elseif receta.id == "Farol" then
		jugador:SetAttribute("TieneFarol", true)
		Armas.dar(jugador, "Farol")
	elseif receta.id == "Ballesta" then
		jugador:SetAttribute("TieneBallesta", true)
		Armas.dar(jugador, "Ballesta")
	elseif receta.id == "Chimenea2" then
		Chimenea.mejorar(2)
		Estado.notificar(nil, "🔥 " .. jugador.DisplayName .. " ha mejorado la chimenea a nivel 2", Color3.fromRGB(255, 190, 100))
	elseif receta.id == "Chimenea3" then
		Chimenea.mejorar(3)
		Estado.notificar(nil, "🔥 " .. jugador.DisplayName .. " ha mejorado la chimenea a nivel 3", Color3.fromRGB(255, 190, 100))
	else
		return false
	end
	return true
end

local function fabricar(jugador: Player, id)
	if type(id) ~= "string" then
		return
	end
	local receta = buscarReceta(id)
	if not receta then
		return
	end
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart
	if not raiz or not mesa or (raiz.Position - mesa.Position).Magnitude > DISTANCIA_MAXIMA then
		Estado.notificar(jugador, "Acércate a la mesa de trabajo.")
		return
	end
	local ok, motivo = Config.recetaDesbloqueada(receta, Estado.obj)
	if not ok then
		Estado.notificar(jugador, "🔒 " .. (motivo or "Todavía no puedes fabricar esto."))
		return
	end
	if receta.unica and jugador:GetAttribute(receta.unica) then
		Estado.notificar(jugador, "Ya tienes " .. receta.nombre .. ".")
		return
	end
	if receta.id == "Botiquin" then
		local hum = Inventario.humanoide(jugador)
		if not hum or hum.Health >= hum.MaxHealth then
			Estado.notificar(jugador, "Tu vida ya está llena.")
			return
		end
	end
	if not Inventario.puedePagar(jugador, receta.coste) then
		Estado.notificar(jugador, "Te faltan materiales para " .. receta.nombre .. ".", Color3.fromRGB(255, 140, 120))
		return
	end
	Inventario.pagar(jugador, receta.coste)
	if aplicar(jugador, receta) then
		Estado.notificar(jugador, receta.icono .. " ¡Has fabricado " .. receta.nombre .. "!", Color3.fromRGB(150, 230, 120))
	end
end

function Taller.iniciar()
	local modelo = CollectionService:GetTagged("Taller")[1]
	if not modelo then
		warn("[Taller] No hay mesa de trabajo en el mapa (etiqueta 'Taller')")
		return
	end
	mesa = modelo.PrimaryPart or modelo:FindFirstChildWhichIsA("BasePart")
	local prompt = Util.prompt(mesa, "Usar", "🔨 Mesa de trabajo", 0, 10)
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Triggered:Connect(function(jugador)
		Estado.remotos.AbrirTaller:FireClient(jugador)
	end)
	Estado.remotos.Fabricar.OnServerEvent:Connect(fabricar)
end

return Taller
