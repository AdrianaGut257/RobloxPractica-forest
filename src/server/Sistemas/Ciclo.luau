local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estado = require(script.Parent.Estado)

local Ciclo = {}

local rgb = Color3.fromRGB
local saltar = false
local ultimaPendiente = false

local atmosfera: Atmosphere
local correccion: ColorCorrectionEffect

local AMBIENTE = {
	Dia = {
		luz = { Brightness = 2.6, OutdoorAmbient = rgb(140, 132, 120), Ambient = rgb(70, 64, 58), ExposureCompensation = 0 },
		atmosfera = { Density = 0.3, Haze = 1.2, Color = rgb(205, 196, 176), Decay = rgb(110, 118, 132), Glare = 0.3 },
		color = { TintColor = rgb(255, 248, 238), Saturation = 0.12, Contrast = 0.05, Brightness = 0 },
	},
	Noche = {
		luz = { Brightness = 1, OutdoorAmbient = rgb(48, 52, 82), Ambient = rgb(28, 28, 42), ExposureCompensation = 0.2 },
		atmosfera = { Density = 0.48, Haze = 2.4, Color = rgb(52, 58, 88), Decay = rgb(22, 26, 44), Glare = 0 },
		color = { TintColor = rgb(205, 215, 255), Saturation = -0.12, Contrast = 0.1, Brightness = 0 },
	},
}

local function prepararIluminacion()
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 1
	Lighting.GlobalShadows = true
	Lighting.ClockTime = 7

	atmosfera = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosfera.Offset = 0.2
	atmosfera.Parent = Lighting

	local cielo = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
	cielo.StarCount = 3000
	cielo.CelestialBodiesShown = true
	cielo.Parent = Lighting

	local brillo = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect")
	brillo.Intensity = 0.6
	brillo.Size = 24
	brillo.Threshold = 1.6
	brillo.Parent = Lighting

	local rayos = Lighting:FindFirstChildOfClass("SunRaysEffect") or Instance.new("SunRaysEffect")
	rayos.Intensity = 0.06
	rayos.Spread = 0.8
	rayos.Parent = Lighting

	correccion = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect")
	correccion.Parent = Lighting

	for propiedad, valor in AMBIENTE.Dia.luz do
		(Lighting :: any)[propiedad] = valor
	end
	for propiedad, valor in AMBIENTE.Dia.atmosfera do
		(atmosfera :: any)[propiedad] = valor
	end
	for propiedad, valor in AMBIENTE.Dia.color do
		(correccion :: any)[propiedad] = valor
	end
end

local function cambiarAmbiente(nombre: string)
	local datos = AMBIENTE[nombre]
	local info = TweenInfo.new(8, Enum.EasingStyle.Sine)
	TweenService:Create(Lighting, info, datos.luz):Play()
	TweenService:Create(atmosfera, info, datos.atmosfera):Play()
	TweenService:Create(correccion, info, datos.color):Play()

	local esNoche = nombre == "Noche"
	for _, luz in CollectionService:GetTagged("LuzJardin") do
		(luz :: any).Enabled = esNoche
	end
	for _, bombilla in CollectionService:GetTagged("BombillaJardin") do
		local b = bombilla :: BasePart
		b.Material = if esNoche then Enum.Material.Neon else Enum.Material.SmoothPlastic
	end
	for _, e in CollectionService:GetTagged("Luciernagas") do
		(e :: any).Enabled = esNoche
	end
	for _, e in CollectionService:GetTagged("Mariposas") do
		(e :: any).Enabled = not esNoche
	end
end

local function actualizarReloj(fase: string, p: number)
	if fase == "Dia" then
		Lighting.ClockTime = 7 + p * 11
	else
		Lighting.ClockTime = (18.5 + p * 12) % 24
	end
end

local function correrFase(fase: string, duracion: number)
	Estado.set("Fase", fase)
	Estado.set("DuracionFase", duracion)
	saltar = false
	local avisado = false
	local inicio = os.clock()
	while true do
		local t = os.clock() - inicio
		local restante = math.max(0, duracion - t)
		actualizarReloj(fase, math.clamp(t / duracion, 0, 1))
		Estado.set("TiempoRestante", math.ceil(restante))
		if fase == "Dia" and not avisado and restante <= Config.AVISO_ANOCHECER then
			avisado = true
			Estado.notificar(nil, "🌇 Está anocheciendo... ¡volved a la mansión y avivad el fuego!", rgb(255, 200, 120))
		end
		if t >= duracion or saltar then
			break
		end
		task.wait(0.1)
	end
end

function Ciclo.empezarUltimaNoche()
	if ultimaPendiente then
		return
	end
	ultimaPendiente = true
	saltar = true
end

local function bucle()
	while true do
		if ultimaPendiente then
			Estado.set("UltimaNoche", true)
			cambiarAmbiente("Noche")
			Estado.anunciar("LA ÚLTIMA NOCHE", "El jardín entero despierta. ¡Resistid hasta el amanecer!")
			Estado.emitir("UltimaNocheEmpieza")
			correrFase("UltimaNoche", Config.DURACION_ULTIMA_NOCHE)

			Estado.set("NochesSobrevividas", (Estado.get("NochesSobrevividas") or 0) + 1)
			Estado.set("Fase", "Escape")
			Estado.set("TiempoRestante", 0)
			cambiarAmbiente("Dia")
			TweenService:Create(Lighting, TweenInfo.new(6), { ClockTime = 7.5 }):Play()
			Estado.anunciar("¡AMANECE!", "La verja se ha abierto. ¡Corred hacia la salida!")
			Estado.emitir("Escape")
			return
		end

		local dia = Estado.get("Dia") or 1
		cambiarAmbiente("Dia")
		if dia == 1 then
			Estado.anunciar("LA MANSIÓN VELARDE", "Día 1 · Explora antes de que caiga la noche")
		else
			Estado.anunciar("DÍA " .. dia, "Has sobrevivido a la noche " .. (dia - 1))
		end
		Estado.emitir("DiaEmpieza", dia)
		correrFase("Dia", Config.DURACION_DIA)
		if ultimaPendiente then
			continue
		end

		Estado.set("NocheActual", dia)
		cambiarAmbiente("Noche")
		Estado.anunciar("NOCHE " .. dia, "Los monstruos despiertan: Marchitos en el jardín, lobos y arañas en el bosque, espectros en la casa. ¡Quedaos cerca del fuego!")
		Estado.emitir("NocheEmpieza", dia)
		correrFase("Noche", Config.DURACION_NOCHE)
		if ultimaPendiente then
			continue
		end

		Estado.set("NochesSobrevividas", dia)
		Estado.set("Dia", dia + 1)
		Estado.emitir("NocheSobrevivida", dia)
	end
end

function Ciclo.iniciar()
	prepararIluminacion()
	Estado.set("Dia", 1)
	Estado.set("NocheActual", 0)
	Estado.set("NochesSobrevividas", 0)
	Estado.set("UltimaNoche", false)
	cambiarAmbiente("Dia")
	task.spawn(bucle)
end

return Ciclo
