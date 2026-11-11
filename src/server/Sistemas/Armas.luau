local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Enemigos = require(script.Parent.Enemigos)
local Recursos = require(script.Parent.Recursos)

local Armas = {}

local TweenService = game:GetService("TweenService")

local rgb = Color3.fromRGB
local plantillas: { [string]: Tool } = {}
local ultimoGolpe = {}

local function construir(nombre: string, tip: string, mango, piezas, agarre: CFrame): Tool
	local t = Instance.new("Tool")
	t.Name = nombre
	t.ToolTip = tip
	t.CanBeDropped = false
	t.Grip = agarre

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = mango.size
	handle.Color = mango.color
	handle.Material = mango.material
	handle.CanCollide = false
	handle.CanQuery = false
	handle.CFrame = CFrame.new()
	handle.Parent = t

	for _, info in piezas do
		local p = Instance.new("Part")
		p.Name = info.nombre or "Pieza"
		p.Size = info.size
		p.Color = info.color
		p.Material = info.material
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Massless = true
		if info.bola then
			p.Shape = Enum.PartType.Ball
			p.Size = info.size
		end
		p.CFrame = handle.CFrame * info.cf
		p.Parent = t
		local w = Instance.new("WeldConstraint")
		w.Part0 = handle
		w.Part1 = p
		w.Parent = p
	end
	return t
end

local function crearPlantillas()
	local madera = rgb(130, 90, 55)
	local metal = rgb(150, 152, 160)

	plantillas.Pala = construir("Pala", "Golpea monstruos y tala árboles secos (despacio).", {
		size = Vector3.new(0.3, 4.6, 0.3),
		color = madera,
		material = Enum.Material.Wood,
	}, {
		{ nombre = "Hoja", size = Vector3.new(1.3, 1.6, 0.15), cf = CFrame.new(0, 3.1, 0), color = metal, material = Enum.Material.Metal },
		{ nombre = "Agarre", size = Vector3.new(0.9, 0.25, 0.25), cf = CFrame.new(0, -2.3, 0), color = madera, material = Enum.Material.Wood },
	}, CFrame.new(0, -1.6, 0))

	plantillas.Hacha = construir("Hacha", "Mucho daño. Tala árboles secos rápido.", {
		size = Vector3.new(0.35, 4.2, 0.35),
		color = rgb(110, 75, 45),
		material = Enum.Material.Wood,
	}, {
		{ nombre = "Cabeza", size = Vector3.new(0.3, 1.3, 1.7), cf = CFrame.new(0, 1.6, -0.6), color = metal, material = Enum.Material.Metal },
		{ nombre = "Filo", size = Vector3.new(0.12, 1.6, 0.4), cf = CFrame.new(0, 1.6, -1.5), color = rgb(210, 212, 220), material = Enum.Material.Metal },
		{ nombre = "Punta", size = Vector3.new(0.3, 0.6, 0.5), cf = CFrame.new(0, 1.6, 0.45), color = metal, material = Enum.Material.Metal },
	}, CFrame.new(0, -1.4, 0))

	plantillas.Farol = construir("Farol", "Da luz y frena a los monstruos cercanos.", {
		size = Vector3.new(1.1, 1.4, 1.1),
		color = rgb(255, 235, 200),
		material = Enum.Material.Glass,
	}, {
		{ nombre = "Tapa", size = Vector3.new(1.3, 0.25, 1.3), cf = CFrame.new(0, 0.8, 0), color = rgb(45, 45, 50), material = Enum.Material.Metal },
		{ nombre = "Base", size = Vector3.new(1.3, 0.25, 1.3), cf = CFrame.new(0, -0.8, 0), color = rgb(45, 45, 50), material = Enum.Material.Metal },
		{ nombre = "Asa", size = Vector3.new(0.2, 0.6, 0.2), cf = CFrame.new(0, 1.15, 0), color = rgb(45, 45, 50), material = Enum.Material.Metal },
		{ nombre = "Llama", size = Vector3.new(0.55, 0.55, 0.55), cf = CFrame.new(), color = rgb(255, 200, 110), material = Enum.Material.Neon, bola = true },
	}, CFrame.new(0, 1.1, 0))
	plantillas.Ballesta = construir("Ballesta", "Dispara de lejos hacia donde miras.", {
		size = Vector3.new(0.4, 0.45, 2.6),
		color = rgb(115, 78, 48),
		material = Enum.Material.Wood,
	}, {
		{ nombre = "Arco", size = Vector3.new(3.2, 0.25, 0.3), cf = CFrame.new(0, 0.1, -1.15), color = rgb(60, 60, 68), material = Enum.Material.Metal },
		{ nombre = "Cuerda", size = Vector3.new(3, 0.06, 0.06), cf = CFrame.new(0, 0.12, -0.55), color = rgb(235, 230, 215), material = Enum.Material.Fabric },
		{ nombre = "Virote", size = Vector3.new(0.12, 0.12, 1.9), cf = CFrame.new(0, 0.32, -0.7), color = rgb(150, 110, 70), material = Enum.Material.Wood },
		{ nombre = "Punta", size = Vector3.new(0.2, 0.2, 0.35), cf = CFrame.new(0, 0.32, -1.75), color = rgb(190, 190, 200), material = Enum.Material.Metal },
		{ nombre = "Culata", size = Vector3.new(0.5, 0.9, 0.8), cf = CFrame.new(0, -0.35, 1.1), color = rgb(95, 62, 38), material = Enum.Material.Wood },
	}, CFrame.new(0, -0.1, 0.4))

	plantillas.Farol.Handle.Transparency = 0.4
	local luz = Instance.new("PointLight")
	luz.Color = rgb(255, 200, 130)
	luz.Range = 24
	luz.Brightness = 2
	luz.Shadows = false
	luz.Parent = plantillas.Farol.Handle
end

local function destello(enemigo: Model)
	local h = Instance.new("Highlight")
	h.FillColor = rgb(255, 60, 60)
	h.FillTransparency = 0.4
	h.OutlineTransparency = 1
	h.Parent = enemigo
	task.delay(0.15, function()
		h:Destroy()
	end)
end

local function virote(desde: Vector3, hasta: Vector3)
	local largo = (hasta - desde).Magnitude
	if largo < 0.5 then
		return
	end
	local p = Instance.new("Part")
	p.Name = "Virote"
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Size = Vector3.new(0.18, 0.18, 2)
	p.Color = rgb(150, 110, 70)
	p.Material = Enum.Material.Wood
	p.CFrame = CFrame.lookAt(desde, hasta)
	p.Parent = workspace
	local estela = Instance.new("Trail")
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, 0.1, 1)
	a0.Parent = p
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -0.1, 1)
	a1.Parent = p
	estela.Attachment0 = a0
	estela.Attachment1 = a1
	estela.Lifetime = 0.15
	estela.Color = ColorSequence.new(rgb(255, 240, 210))
	estela.Transparency = NumberSequence.new(0.4, 1)
	estela.Parent = p
	local t = largo / 160
	TweenService:Create(p, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = CFrame.lookAt(hasta, hasta + (hasta - desde).Unit) }):Play()
	task.delay(t + 0.3, function()
		p:Destroy()
	end)
	return t
end

local function disparar(jugador: Player, tool: Tool, stats)
	local personaje = jugador.Character
	if not personaje or tool.Parent ~= personaje then
		return
	end
	local raiz = personaje:FindFirstChild("HumanoidRootPart") :: BasePart
	local hum = personaje:FindFirstChildOfClass("Humanoid")
	if not raiz or not hum or hum.Health <= 0 then
		return
	end
	local ahora = os.clock()
	if ultimoGolpe[tool] and ahora - ultimoGolpe[tool] < stats.cadencia then
		return
	end
	ultimoGolpe[tool] = ahora

	local origen = raiz.Position + Vector3.new(0, 1.2, 0)
	local frente = raiz.CFrame.LookVector
	local filtro = RaycastParams.new()
	filtro.FilterType = Enum.RaycastFilterType.Exclude
	filtro.FilterDescendantsInstances = { personaje, Recursos.carpeta }

	local mejor, mejorDist = nil, math.huge
	for _, enemigo in CollectionService:GetTagged("Enemigo") do
		local eRaiz = enemigo:FindFirstChild("HumanoidRootPart") :: BasePart
		local eHum = enemigo:FindFirstChildOfClass("Humanoid")
		if eRaiz and eHum and eHum.Health > 0 then
			local dir = eRaiz.Position - origen
			local d = dir.Magnitude
			local plano = Vector3.new(dir.X, 0, dir.Z)
			if d <= stats.alcance and d < mejorDist and plano.Magnitude > 0.1 and frente:Dot(plano.Unit) > 0.93 then
				local res = workspace:Raycast(origen, dir, filtro)
				if not res or res.Instance:IsDescendantOf(enemigo) then
					mejor, mejorDist = enemigo, d
				end
			end
		end
	end

	if mejor then
		local eRaiz = mejor:FindFirstChild("HumanoidRootPart") :: BasePart
		local t = virote(origen + frente * 1.5, eRaiz.Position) or 0
		task.delay(t, function()
			local eHum = mejor:FindFirstChildOfClass("Humanoid")
			if eHum and eHum.Health > 0 then
				eHum:TakeDamage(stats.dano)
				destello(mejor)
			end
		end)
	else
		local res = workspace:Raycast(origen, frente * stats.alcance, filtro)
		virote(origen + frente * 1.5, if res then res.Position else origen + frente * stats.alcance)
	end
end

local function golpear(jugador: Player, tool: Tool, stats)
	local personaje = jugador.Character
	if not personaje or tool.Parent ~= personaje then
		return
	end
	local raiz = personaje:FindFirstChild("HumanoidRootPart") :: BasePart
	local hum = personaje:FindFirstChildOfClass("Humanoid")
	if not raiz or not hum or hum.Health <= 0 then
		return
	end
	local ahora = os.clock()
	if ultimoGolpe[tool] and ahora - ultimoGolpe[tool] < stats.cadencia then
		return
	end
	ultimoGolpe[tool] = ahora

	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = tool

	local frente = raiz.CFrame.LookVector
	local acerto = false
	for _, enemigo in CollectionService:GetTagged("Enemigo") do
		local eRaiz = enemigo:FindFirstChild("HumanoidRootPart") :: BasePart
		local eHum = enemigo:FindFirstChildOfClass("Humanoid")
		if eRaiz and eHum and eHum.Health > 0 then
			local dir = eRaiz.Position - raiz.Position
			local distancia = dir.Magnitude
			local alcance = stats.alcance + eRaiz.Size.X / 2
			if distancia <= alcance and (distancia < 2.5 or frente:Dot(dir.Unit) > 0.2) then
				eHum:TakeDamage(stats.dano)
				destello(enemigo)
				acerto = true
			end
		end
	end
	if acerto then
		return
	end
	for _, arbol in CollectionService:GetTagged("Talable") do
		local tronco = arbol.PrimaryPart
		if tronco and not arbol:GetAttribute("Talado") then
			local d = Vector3.new(tronco.Position.X - raiz.Position.X, 0, tronco.Position.Z - raiz.Position.Z)
			if d.Magnitude <= stats.alcance + 1 then
				Recursos.talar(arbol, stats.tala, jugador)
				break
			end
		end
	end
end

function Armas.dar(jugador: Player, nombre: string)
	local mochila = jugador:FindFirstChildOfClass("Backpack")
	if not mochila or not plantillas[nombre] then
		return
	end
	if mochila:FindFirstChild(nombre) or (jugador.Character and jugador.Character:FindFirstChild(nombre)) then
		return
	end
	local t = plantillas[nombre]:Clone()
	local stats = Config.ARMAS[nombre]
	if stats then
		t.Activated:Connect(function()
			if stats.distancia then
				disparar(jugador, t, stats)
			else
				golpear(jugador, t, stats)
			end
		end)
	end
	t.Destroying:Connect(function()
		ultimoGolpe[t] = nil
	end)
	t.Parent = mochila
end

function Armas.iniciar()
	crearPlantillas()

	local function alAparecer(jugador: Player)
		local mochila = jugador:WaitForChild("Backpack", 10)
		if not mochila then
			return
		end
		Armas.dar(jugador, "Pala")
		if jugador:GetAttribute("TieneHacha") then
			Armas.dar(jugador, "Hacha")
		end
		if jugador:GetAttribute("TieneFarol") then
			Armas.dar(jugador, "Farol")
		end
		if jugador:GetAttribute("TieneBallesta") then
			Armas.dar(jugador, "Ballesta")
		end
	end
	local function alEntrar(jugador: Player)
		jugador.CharacterAdded:Connect(function()
			alAparecer(jugador)
		end)
		if jugador.Character then
			task.spawn(alAparecer, jugador)
		end
	end
	Players.PlayerAdded:Connect(alEntrar)
	for _, jugador in Players:GetPlayers() do
		alEntrar(jugador)
	end

	task.spawn(function()
		while true do
			task.wait(0.3)
			for _, jugador in Players:GetPlayers() do
				local personaje = jugador.Character
				local farol = personaje and personaje:FindFirstChild("Farol")
				local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
				if farol and raiz then
					for _, enemigo in CollectionService:GetTagged("Enemigo") do
						local eRaiz = enemigo:FindFirstChild("HumanoidRootPart")
						if eRaiz and (eRaiz.Position - raiz.Position).Magnitude <= Config.FAROL.RADIO then
							Enemigos.ralentizar(enemigo, 0.5)
						end
					end
				end
			end
		end
	end)
end

return Armas
