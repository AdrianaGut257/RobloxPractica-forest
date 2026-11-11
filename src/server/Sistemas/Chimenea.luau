local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estado = require(script.Parent.Estado)
local Inventario = require(script.Parent.Inventario)
local Util = require(script.Parent.Parent.Mundo.Util)

local Chimenea = {}

local CFG = Config.CHIMENEA
local fuego: BasePart? = nil
local llamas: Fire? = nil
local luz: PointLight? = nil
local chispas: ParticleEmitter? = nil
local centro = Vector3.zero
local radio = 0
local avisoPoco = false

local function nivel()
	return CFG.NIVELES[Estado.get("NivelChimenea") or 1]
end

local function actualizarAspecto()
	local combustible = Estado.get("Combustible") or 0
	local maximo = nivel().maximo
	local proporcion = math.clamp(combustible / maximo, 0, 1)
	if combustible > 0 then
		radio = nivel().radio * (0.45 + 0.55 * proporcion)
	else
		radio = 0
	end
	Estado.set("RadioLuz", math.floor(radio * 10) / 10)
	if llamas then
		llamas.Enabled = combustible > 0
		llamas.Size = 3 + 6 * proporcion
	end
	if chispas then
		chispas.Enabled = combustible > 0
	end
	if luz then
		luz.Enabled = combustible > 0
		luz.Range = math.clamp(radio + 8, 12, 60)
		luz.Brightness = 1.5 + 2 * proporcion
	end
end

function Chimenea.estaProtegido(pos: Vector3): boolean
	return radio > 0 and (pos - centro).Magnitude <= radio
end

function Chimenea.radio(): number
	return radio
end

function Chimenea.centro(): Vector3
	return centro
end

function Chimenea.puntoBorde(desde: Vector3, margen: number): Vector3
	local dir = Vector3.new(desde.X - centro.X, 0, desde.Z - centro.Z)
	if dir.Magnitude < 0.1 then
		dir = Vector3.new(0, 0, 1)
	end
	local p = centro + dir.Unit * (radio + margen)
	return Vector3.new(p.X, desde.Y, p.Z)
end

function Chimenea.mejorar(nuevoNivel: number)
	Estado.set("NivelChimenea", nuevoNivel)
	local datos = CFG.NIVELES[nuevoNivel]
	Estado.set("CombustibleMax", datos.maximo)
	Estado.set("Combustible", math.min(datos.maximo, (Estado.get("Combustible") or 0) + 30))
	actualizarAspecto()
end

local function echarLena(jugador: Player)
	local lena = Inventario.cantidad(jugador, "Lena")
	if lena <= 0 then
		Estado.notificar(jugador, "No llevas leña. Recoge ramas en el jardín o tala árboles secos.")
		return
	end
	local combustible = Estado.get("Combustible") or 0
	local maximo = nivel().maximo
	if combustible >= maximo - 1 then
		Estado.notificar(jugador, "🔥 La chimenea ya está llena.")
		return
	end
	local caben = math.ceil((maximo - combustible) / CFG.POR_LENA)
	local usar = math.min(lena, caben)
	local estabaApagada = combustible <= 0
	Inventario.quitar(jugador, "Lena", usar)
	Estado.set("Combustible", math.min(maximo, combustible + usar * CFG.POR_LENA))
	actualizarAspecto()
	if estabaApagada then
		Estado.notificar(nil, "🔥 " .. jugador.DisplayName .. " ha vuelto a encender la chimenea.", Color3.fromRGB(255, 190, 100))
	else
		Estado.notificar(jugador, "🔥 Echaste " .. usar .. " de leña al fuego.", Color3.fromRGB(255, 190, 100))
	end
end

function Chimenea.iniciar()
	local modelo = CollectionService:GetTagged("Chimenea")[1]
	if not modelo then
		warn("[Chimenea] No hay ninguna chimenea en el mapa (etiqueta 'Chimenea')")
		return
	end
	fuego = modelo:FindFirstChild("Fuego") :: BasePart
	centro = fuego.Position
	llamas = fuego:FindFirstChildOfClass("Fire")
	luz = fuego:FindFirstChildOfClass("PointLight")
	chispas = fuego:FindFirstChildOfClass("ParticleEmitter")
	Estado.set("CentroLuz", centro)
	Estado.set("NivelChimenea", 1)
	Estado.set("CombustibleMax", CFG.NIVELES[1].maximo)
	Estado.set("Combustible", CFG.COMBUSTIBLE_INICIAL)
	actualizarAspecto()

	local prompt = Util.prompt(fuego, "Echar leña", "Chimenea", 0, 12)
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Triggered:Connect(echarLena)

	task.spawn(function()
		local PASO = 0.5
		while true do
			task.wait(PASO)
			local fase = Estado.get("Fase")
			if fase ~= "Escape" then
				local gasto = if fase == "Dia" then CFG.GASTO_DIA else CFG.GASTO_NOCHE
				local antes = Estado.get("Combustible") or 0
				local ahora = math.max(0, antes - gasto * PASO)
				Estado.set("Combustible", ahora)
				local maximo = nivel().maximo
				if ahora < maximo * 0.25 and not avisoPoco and ahora > 0 then
					avisoPoco = true
					Estado.notificar(nil, "⚠️ ¡La chimenea se está apagando! Traed leña.", Color3.fromRGB(255, 170, 80))
				elseif ahora > maximo * 0.35 then
					avisoPoco = false
				end
				if antes > 0 and ahora <= 0 then
					Estado.notificar(nil, "🌑 ¡La chimenea se ha apagado! Ya nada os protege.", Color3.fromRGB(255, 90, 90))
				end
				actualizarAspecto()
			end
		end
	end)
end

return Chimenea
