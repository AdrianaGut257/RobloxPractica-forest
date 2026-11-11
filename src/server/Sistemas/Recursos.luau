local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estado = require(script.Parent.Estado)
local Inventario = require(script.Parent.Inventario)
local Util = require(script.Parent.Parent.Mundo.Util)

local Recursos = {}

local CFG = Config.RECURSOS
local rgb = Color3.fromRGB
local carpeta: Folder

local function aviso(jugador: Player, recurso: string, n: number)
	Estado.notificar(jugador, string.format("+%d %s %s", n, Config.ICONOS_RECURSOS[recurso], Config.NOMBRES_RECURSOS[recurso]))
end

function Recursos.soltar(recurso: string, pos: Vector3, cantidad: number?)
	local n = cantidad or 1
	local parte
	if recurso == "Lena" then
		parte = Util.cilindro(carpeta, 0.9, 3, CFrame.new(pos) * CFrame.Angles(0, math.random() * 3, 0), rgb(120, 82, 50), Enum.Material.Wood)
	elseif recurso == "Comida" then
		parte = Util.bola(carpeta, 1, pos, rgb(210, 30, 40), Enum.Material.SmoothPlastic)
	else
		parte = Util.bloque(carpeta, Vector3.new(1.2, 0.6, 1.2), CFrame.new(pos) * CFrame.Angles(0, math.random() * 3, 0.3), rgb(130, 130, 140), Enum.Material.CorrodedMetal)
	end
	parte.Name = "Suelto_" .. recurso
	parte.CanCollide = false
	local prompt = Util.prompt(parte, "Recoger", Config.ICONOS_RECURSOS[recurso] .. " " .. Config.NOMBRES_RECURSOS[recurso], 0, 9)
	prompt.Triggered:Connect(function(jugador)
		if not parte.Parent then
			return
		end
		parte:Destroy()
		Inventario.dar(jugador, recurso, n)
		aviso(jugador, recurso, n)
	end)
	task.delay(CFG.DURACION_SUELTO, function()
		if parte.Parent then
			parte:Destroy()
		end
	end)
	return parte
end

local function iniciarRamas()
	local puntos = CollectionService:GetTagged("PuntoRama")
	if #puntos == 0 then
		return
	end
	local ocupados = {}
	local cuantas = 0

	local function crearRama()
		local libres = {}
		for _, p in puntos do
			if not ocupados[p] then
				table.insert(libres, p)
			end
		end
		if #libres == 0 then
			return
		end
		local punto = libres[math.random(1, #libres)]
		ocupados[punto] = true
		cuantas += 1
		local pos = punto.Position
		local rama = Util.cilindro(
			carpeta,
			0.55,
			math.random(28, 40) / 10,
			CFrame.new(pos.X, 0.3, pos.Z) * CFrame.Angles(0, math.random() * 6, 0),
			rgb(110, 76, 48),
			Enum.Material.Wood
		)
		rama.Name = "Rama"
		rama.CanCollide = false
		Util.cilindro(carpeta, 0.3, 1.4, rama.CFrame * CFrame.new(0.5, 0, 0.5) * CFrame.Angles(0, 0.8, 0), rgb(110, 76, 48), Enum.Material.Wood, {
			Deco = true,
			Parent = rama,
		})
		local prompt = Util.prompt(rama, "Recoger", "🪵 Rama", 0.25, 9)
		prompt.Triggered:Connect(function(jugador)
			if not rama.Parent then
				return
			end
			rama:Destroy()
			ocupados[punto] = nil
			cuantas -= 1
			Inventario.dar(jugador, "Lena", 1)
			aviso(jugador, "Lena", 1)
		end)
	end

	for _ = 1, CFG.MAX_RAMAS do
		crearRama()
	end
	task.spawn(function()
		while true do
			task.wait(CFG.REAPARICION_RAMAS)
			if cuantas < CFG.MAX_RAMAS then
				crearRama()
			end
		end
	end)
end

local function iniciarCajas()
	for _, caja in CollectionService:GetTagged("Caja") do
		local cuerpo = caja:FindFirstChild("Cuerpo") :: BasePart
		local tapa = caja:FindFirstChild("Tapa") :: BasePart
		if not cuerpo then
			continue
		end
		local tapaCerrada = tapa and tapa.CFrame
		local prompt = Util.prompt(cuerpo, "Registrar", "📦 Caja", 0.8, 8)
		prompt.Triggered:Connect(function(jugador)
			if not prompt.Enabled then
				return
			end
			prompt.Enabled = false
			local chatarra = math.random(1, 3)
			Inventario.dar(jugador, "Chatarra", chatarra)
			local texto = string.format("📦 +%d ⚙️ Chatarra", chatarra)
			if math.random() < 0.3 then
				Inventario.dar(jugador, "Comida", 1)
				texto ..= "  +1 🍎 Comida"
			end
			if math.random() < 0.25 then
				Inventario.dar(jugador, "Lena", 1)
				texto ..= "  +1 🪵 Leña"
			end
			Estado.notificar(jugador, texto)
			if tapa and tapaCerrada then
				tapa.CFrame = tapaCerrada * CFrame.new(0, 0.6, 0.9) * CFrame.Angles(math.rad(70), 0, 0)
			end
			task.delay(CFG.CAJA_RECARGA, function()
				if tapa and tapaCerrada then
					tapa.CFrame = tapaCerrada
				end
				prompt.Enabled = true
			end)
		end)
	end
end

local function iniciarDespensas()
	for _, despensa in CollectionService:GetTagged("Despensa") do
		local cuerpo = despensa:FindFirstChild("Cuerpo") :: BasePart
		if not cuerpo then
			continue
		end
		local tarros = {}
		for _, d in despensa:GetChildren() do
			if d.Name == "Tarro" then
				table.insert(tarros, d)
			end
		end
		local prompt = Util.prompt(cuerpo, "Coger conservas", "🥫 Despensa", 0.6, 8)
		prompt.Triggered:Connect(function(jugador)
			if not prompt.Enabled then
				return
			end
			prompt.Enabled = false
			local n = math.random(1, 2)
			Inventario.dar(jugador, "Comida", n)
			aviso(jugador, "Comida", n)
			for _, t in tarros do
				t.Transparency = 1
			end
			task.delay(CFG.DESPENSA_RECARGA, function()
				for _, t in tarros do
					t.Transparency = 0
				end
				prompt.Enabled = true
			end)
		end)
	end
end

local function iniciarFrutales()
	for _, arbol in CollectionService:GetTagged("Frutal") do
		local tronco = arbol:FindFirstChild("Tronco") :: BasePart
		if not tronco then
			continue
		end
		local frutos = {}
		for _, d in arbol:GetChildren() do
			if d.Name == "Fruto" then
				table.insert(frutos, d)
			end
		end
		local prompt = Util.prompt(tronco, "Recoger manzana", "🍎 Manzano", 0.3, 10)
		local function mostrar()
			local n = arbol:GetAttribute("Frutos") or 0
			for i, f in frutos do
				f.Transparency = if i <= n * 2 then 0 else 1
			end
			prompt.Enabled = n > 0
			prompt.ObjectText = string.format("🍎 Manzano (%d)", n)
		end
		arbol:SetAttribute("Frutos", CFG.FRUTOS_POR_ARBOL)
		mostrar()
		prompt.Triggered:Connect(function(jugador)
			local n = arbol:GetAttribute("Frutos") or 0
			if n <= 0 then
				return
			end
			arbol:SetAttribute("Frutos", n - 1)
			Inventario.dar(jugador, "Comida", 1)
			aviso(jugador, "Comida", 1)
			mostrar()
		end)
		task.spawn(function()
			while arbol.Parent do
				task.wait(CFG.FRUTO_RECRECE)
				local n = arbol:GetAttribute("Frutos") or 0
				if n < CFG.FRUTOS_POR_ARBOL then
					arbol:SetAttribute("Frutos", n + 1)
					mostrar()
				end
			end
		end)
	end
end

local function iniciarLenera()
	for _, lenera in CollectionService:GetTagged("Lenera") do
		local base = lenera:FindFirstChild("Base") :: BasePart
		if not base then
			continue
		end
		local lenos = {}
		for _, d in lenera:GetChildren() do
			if d.Name == "Leno" then
				table.insert(lenos, d)
			end
		end
		local stock = CFG.LENERA_MAXIMO
		local prompt = Util.prompt(base, "Coger leña", "🪵 Leñera", 0.5, 9)
		local function mostrar()
			for i, l in lenos do
				l.Transparency = if i <= stock then 0 else 1
			end
			prompt.Enabled = stock > 0
			prompt.ObjectText = string.format("🪵 Leñera (%d)", stock)
		end
		mostrar()
		prompt.Triggered:Connect(function(jugador)
			if stock <= 0 then
				return
			end
			local n = math.min(2, stock)
			stock -= n
			Inventario.dar(jugador, "Lena", n)
			aviso(jugador, "Lena", n)
			mostrar()
		end)
		task.spawn(function()
			while true do
				task.wait(CFG.LENERA_RECARGA)
				if stock < CFG.LENERA_MAXIMO then
					stock += 1
					mostrar()
				end
			end
		end)
	end
end

local talando = {}

function Recursos.talar(arbol: Model, golpe: number, jugador: Player)
	if talando[arbol] or arbol:GetAttribute("Talado") then
		return
	end
	local vida = (arbol:GetAttribute("Vida") or CFG.ARBOL_SECO_VIDA) - golpe
	arbol:SetAttribute("Vida", vida)
	local tronco = arbol.PrimaryPart
	if not tronco then
		return
	end
	if vida > 0 then
		local original = arbol:GetPivot()
		arbol:PivotTo(original * CFrame.Angles(0, 0, math.rad(2)))
		task.delay(0.08, function()
			arbol:PivotTo(original)
		end)
		Estado.notificar(jugador, string.format("🪓 Talando... (%d)", math.ceil(vida)))
		return
	end
	talando[arbol] = true
	arbol:SetAttribute("Talado", true)
	local base = tronco.Position - Vector3.new(0, tronco.Size.X / 2, 0)
	for i = 1, CFG.LENA_POR_ARBOL do
		local a = i * (math.pi * 2 / CFG.LENA_POR_ARBOL)
		Recursos.soltar("Lena", base + Vector3.new(math.cos(a) * 3, 0.5, math.sin(a) * 3), 1)
	end
	Estado.notificar(jugador, "🌳 ¡Árbol talado! Recoge la leña del suelo.")
	local transparencias = {}
	for _, d in arbol:GetDescendants() do
		if d:IsA("BasePart") then
			transparencias[d] = { d.Transparency, d.CanCollide }
			TweenService:Create(d, TweenInfo.new(0.8), { Transparency = 1 }):Play()
			d.CanCollide = false
		end
	end
	task.delay(CFG.ARBOL_RECRECE, function()
		for d, datos in transparencias do
			if d.Parent then
				d.Transparency = datos[1]
				d.CanCollide = datos[2]
			end
		end
		arbol:SetAttribute("Vida", CFG.ARBOL_SECO_VIDA)
		arbol:SetAttribute("Talado", false)
		talando[arbol] = nil
	end)
end

function Recursos.iniciar()
	carpeta = Instance.new("Folder")
	carpeta.Name = "Recogibles"
	carpeta.Parent = workspace
	Recursos.carpeta = carpeta

	for _, arbol in CollectionService:GetTagged("Talable") do
		arbol:SetAttribute("Vida", CFG.ARBOL_SECO_VIDA)
	end

	iniciarRamas()
	iniciarCajas()
	iniciarDespensas()
	iniciarFrutales()
	iniciarLenera()
end

return Recursos
