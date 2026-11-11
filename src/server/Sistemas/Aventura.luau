local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Historia = require(Shared:WaitForChild("Historia"))
local Estado = require(script.Parent.Estado)
local Ciclo = require(script.Parent.Ciclo)
local Datos = require(script.Parent.Datos)
local Util = require(script.Parent.Parent.Mundo.Util)

local Aventura = {}

local ORO = Color3.fromRGB(255, 215, 120)
local puertas: { [Model]: ProximityPrompt } = {}

local function selladaPorRaices(puerta: Model): boolean
	return puerta:GetAttribute("NocheMinima") ~= nil and not Estado.get("RaicesRetiradas")
end

local function textoPuerta(puerta: Model): string
	if selladaPorRaices(puerta) then
		return "Sellada por raíces"
	end
	if Estado.get("Llave_" .. puerta:GetAttribute("Llave")) then
		return "Abrir"
	end
	return "Cerrada 🔒"
end

local function refrescarPuertas()
	for puerta, prompt in puertas do
		prompt.ActionText = textoPuerta(puerta)
	end
end

local function abrirPuerta(puerta: Model, jugador: Player)
	local prompt = puertas[puerta]
	puertas[puerta] = nil
	if prompt then
		prompt:Destroy()
	end
	for _, d in puerta:GetDescendants() do
		if d:IsA("BasePart") then
			d.CanCollide = false
		end
	end
	Util.pivotar(puerta, puerta:GetPivot() * CFrame.Angles(0, math.rad(100), 0), 1.2)
	Estado.notificar(nil, "🚪 " .. jugador.DisplayName .. " abrió: " .. puerta:GetAttribute("Nombre"))
end

local function iniciarPuertas()
	for _, puerta in CollectionService:GetTagged("PuertaCerrada") do
		local panel = puerta.PrimaryPart
		if not panel then
			continue
		end
		local llave = puerta:GetAttribute("Llave")
		local nombre = puerta:GetAttribute("Nombre") or llave
		local prompt = Util.prompt(panel, textoPuerta(puerta), "🚪 " .. nombre, 0.5, 9)
		puertas[puerta] = prompt
		prompt.Triggered:Connect(function(jugador)
			if not puertas[puerta] then
				return
			end
			if selladaPorRaices(puerta) then
				Estado.notificar(
					jugador,
					"🌿 Unas raíces enormes sellan la puerta. Se retirarán tras sobrevivir "
						.. puerta:GetAttribute("NocheMinima")
						.. " noches."
				)
				return
			end
			if not Estado.get("Llave_" .. llave) then
				Estado.notificar(jugador, "🔒 Está cerrada. Necesitas la " .. (Historia.LLAVES[llave] or "llave") .. ".")
				return
			end
			abrirPuerta(puerta, jugador)
		end)
	end
end

local function iniciarLlaves()
	for _, llave in CollectionService:GetTagged("Llave") do
		local id = llave:GetAttribute("Id")
		local cuerpo = llave.PrimaryPart
		if not cuerpo then
			continue
		end
		local nombre = Historia.LLAVES[id] or ("Llave " .. tostring(id))
		local prompt = Util.prompt(cuerpo, "Coger", "🗝️ " .. nombre, 0.3, 10)
		prompt.Triggered:Connect(function(jugador)
			if not llave.Parent then
				return
			end
			llave:Destroy()
			Estado.set("Llave_" .. id, true)
			Estado.notificar(nil, "🗝️ " .. jugador.DisplayName .. " encontró la " .. nombre .. ".", ORO)
			refrescarPuertas()
			if id == "Verja" then
				Estado.anunciar("LA LLAVE DE LA VERJA", "Usadla en la entrada del jardín cuando estéis listos: será la última noche.")
			end
		end)
	end
end

local function iniciarPaginas()
	for _, pagina in CollectionService:GetTagged("Pagina") do
		local n = pagina:GetAttribute("Numero")
		local datos = Historia.PAGINAS[n]
		local prompt = Util.prompt(pagina, "Leer", "📜 " .. (if datos then datos.titulo else "Página"), 0, 10)
		prompt.Triggered:Connect(function(jugador)
			if not pagina.Parent then
				return
			end
			pagina:Destroy()
			Estado.set("Pagina_" .. n, true)
			Estado.set("PaginasEncontradas", (Estado.get("PaginasEncontradas") or 0) + 1)
			Estado.remotos.MostrarPagina:FireClient(jugador, n)
			for _, otro in Players:GetPlayers() do
				if otro ~= jugador then
					Estado.notificar(otro, "📜 " .. jugador.DisplayName .. " encontró una página del diario. Pulsa J para leerla.")
				end
			end
		end)
	end
end

local function iniciarHallazgos()
	for _, hallazgo in CollectionService:GetTagged("Hallazgo") do
		local id = hallazgo:GetAttribute("Id")
		local datos = Historia.HALLAZGOS[id]
		local cuerpo = hallazgo.PrimaryPart
		if not cuerpo or not datos then
			continue
		end
		Estado.set(id, false)
		local prompt = Util.prompt(cuerpo, "Coger", datos.icono .. " " .. datos.nombre, 0.3, 10)
		prompt.Triggered:Connect(function(jugador)
			if not hallazgo.Parent then
				return
			end
			hallazgo:Destroy()
			Estado.set(id, true)
			Estado.notificar(nil, datos.icono .. " " .. jugador.DisplayName .. " encontró los " .. datos.nombre .. ". " .. datos.aviso, ORO)
		end)
	end
end

local function iniciarNiebla()
	local retorno = CollectionService:GetTagged("PuntoRetorno")[1] :: BasePart
	if not retorno then
		return
	end
	local ultimo: { [Player]: number } = {}
	for _, pared in CollectionService:GetTagged("Niebla") do
		(pared :: BasePart).Touched:Connect(function(parte)
			local personaje = parte:FindFirstAncestorOfClass("Model")
			local jugador = personaje and Players:GetPlayerFromCharacter(personaje)
			local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart
			if not jugador or not raiz then
				return
			end
			if ultimo[jugador] and os.clock() - ultimo[jugador] < 3 then
				return
			end
			ultimo[jugador] = os.clock()
			local desvio = Vector3.new(math.random(-8, 8), 0, math.random(0, 6))
			personaje:PivotTo(CFrame.new(retorno.Position + desvio))
			Estado.notificar(jugador, Historia.NIEBLA, Color3.fromRGB(200, 210, 230))
		end)
	end
	Players.PlayerRemoving:Connect(function(jugador)
		ultimo[jugador] = nil
	end)
end

local function retirarRaices()
	if Estado.get("RaicesRetiradas") then
		return
	end
	Estado.set("RaicesRetiradas", true)
	for _, raices in CollectionService:GetTagged("Raices") do
		Util.desvanecer(raices, 2)
	end
	refrescarPuertas()
	task.delay(6, function()
		Estado.anunciar("LAS RAÍCES SE RETIRAN", "La cripta del cementerio ya se puede abrir.")
	end)
end

local escaparon: { [Player]: boolean } = {}
local finalProgramado = false

local function terminarPartida()
	if finalProgramado then
		return
	end
	finalProgramado = true
	task.delay(20, function()
		local jugadores = Players:GetPlayers()
		if #jugadores == 0 then
			return
		end
		Estado.notificar(nil, "Preparando una partida nueva...")
		local ok, err = pcall(function()
			local opciones = Instance.new("TeleportOptions")
			opciones.ShouldReserveServer = true
			TeleportService:TeleportAsync(game.PlaceId, jugadores, opciones)
		end)
		if not ok then
			warn("[Aventura] No se pudo empezar una partida nueva: " .. tostring(err))
			Estado.notificar(nil, "Fin de la partida. Para jugar otra vez, vuelve a entrar al juego.")
		end
	end)
end

local function iniciarVerja()
	local verja = CollectionService:GetTagged("Verja")[1]
	if not verja then
		warn("[Aventura] No hay verja en el mapa (etiqueta 'Verja')")
		return
	end
	local cerradura = verja:FindFirstChild("Cerradura") :: BasePart
	if cerradura then
		local prompt = Util.prompt(cerradura, "Usar la llave", "🗝️ Verja", 1, 10)
		prompt.Triggered:Connect(function(jugador)
			if not Estado.get("Llave_Verja") then
				Estado.notificar(jugador, "🔒 Un candado enorme cierra la verja. Necesitas la Llave de la Verja.")
				return
			end
			local fase = Estado.get("Fase")
			if fase == "UltimaNoche" or fase == "Escape" then
				return
			end
			prompt.Enabled = false
			Estado.notificar(nil, "🗝️ " .. jugador.DisplayName .. " ha girado la llave de la verja... ¡el jardín despierta!", Color3.fromRGB(255, 120, 120))
			Ciclo.empezarUltimaNoche()
		end)
	end

	Estado.escuchar("Escape", function()
		Estado.set("VerjaAbierta", true)
		if cerradura then
			cerradura:Destroy()
		end
		local giros = { HojaIzq = -math.pi / 2, HojaDer = math.pi / 2 }
		for nombre, giro in giros do
			local hoja = verja:FindFirstChild(nombre)
			if hoja and hoja:IsA("Model") then
				for _, d in hoja:GetDescendants() do
					if d:IsA("BasePart") then
						d.CanCollide = false
					end
				end
				Util.pivotar(hoja, hoja:GetPivot() * CFrame.Angles(0, giro, 0), 3)
			end
		end
	end)

	local salida = CollectionService:GetTagged("Salida")[1] :: BasePart
	if not salida then
		return
	end
	salida.Touched:Connect(function(parte)
		if Estado.get("Fase") ~= "Escape" then
			return
		end
		local personaje = parte:FindFirstAncestorOfClass("Model")
		local jugador = personaje and Players:GetPlayerFromCharacter(personaje)
		if not jugador or escaparon[jugador] then
			return
		end
		escaparon[jugador] = true
		local noches = Estado.get("NochesSobrevividas") or 0
		Datos.registrarEscape(jugador)
		Estado.remotos.Victoria:FireClient(jugador, noches)
		Estado.notificar(nil, "🎉 ¡" .. jugador.DisplayName .. " ha escapado de la Mansión Velarde!", ORO)

		local todos = true
		for _, j in Players:GetPlayers() do
			if not escaparon[j] then
				todos = false
			end
		end
		if todos then
			terminarPartida()
		end
	end)
end

function Aventura.iniciar()
	Estado.set("PaginasEncontradas", 0)
	Estado.set("RaicesRetiradas", false)
	Estado.set("VerjaAbierta", false)
	for _, id in Historia.ORDEN_LLAVES do
		Estado.set("Llave_" .. id, false)
	end

	iniciarPuertas()
	iniciarLlaves()
	iniciarPaginas()
	iniciarHallazgos()
	iniciarVerja()
	iniciarNiebla()

	Estado.escuchar("NocheSobrevivida", function(noches: number)
		if noches >= Config.NOCHE_CRIPTA then
			retirarRaices()
		end
	end)

	Players.PlayerAdded:Connect(function(jugador)
		task.wait(4)
		Estado.notificar(jugador, Historia.INTRO)
	end)
	for _, jugador in Players:GetPlayers() do
		task.delay(4, function()
			Estado.notificar(jugador, Historia.INTRO)
		end)
	end
end

return Aventura
