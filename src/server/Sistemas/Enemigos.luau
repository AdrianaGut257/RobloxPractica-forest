local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estado = require(script.Parent.Estado)
local Chimenea = require(script.Parent.Chimenea)
local Recursos = require(script.Parent.Recursos)

local Enemigos = {}

local CFG = Config.ENEMIGOS
local BOSQUE = Config.BOSQUE
local rgb = Color3.fromRGB
local V = Vector3.new
local TICK = 0.2
local ANIM_ANDAR = "rbxassetid://180426354"
local GRUPO = "Enemigos"

local carpeta: Folder
local activos = {}
local puntos: { [string]: { BasePart } } = {}
local plantillas = {}
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude

local APARIENCIA = {
	Marchito = { piel = rgb(112, 128, 84), torso = rgb(78, 62, 46), piernas = rgb(58, 48, 40), ojos = rgb(255, 230, 90), musgo = rgb(70, 112, 50) },
	Espino = { piel = rgb(72, 102, 56), torso = rgb(50, 72, 40), piernas = rgb(40, 56, 32), ojos = rgb(255, 70, 60), musgo = rgb(115, 78, 45), espinas = true },
	Raigon = { piel = rgb(98, 72, 50), torso = rgb(80, 58, 40), piernas = rgb(70, 50, 35), ojos = rgb(255, 150, 50), musgo = rgb(60, 100, 45), corteza = true },
	Jardinero = { piel = rgb(66, 68, 60), torso = rgb(35, 35, 32), piernas = rgb(30, 30, 28), ojos = rgb(230, 240, 255), musgo = rgb(50, 82, 40), sombrero = true, tijeras = true },
	Lobo = { pelo = rgb(58, 56, 64), panza = rgb(92, 88, 96), oscuro = rgb(32, 30, 36), ojos = rgb(255, 110, 40) },
	Huargo = { pelo = rgb(34, 30, 34), panza = rgb(70, 62, 66), oscuro = rgb(18, 16, 20), ojos = rgb(255, 40, 30), musgo = rgb(60, 92, 48) },
	Arana = { cuerpo = rgb(42, 34, 40), dibujo = rgb(190, 30, 45), patas = rgb(30, 24, 28), ojos = rgb(255, 60, 60) },
	Espectro = { vestido = rgb(205, 220, 245), piel = rgb(235, 240, 255), pelo = rgb(40, 40, 52), ojos = rgb(110, 220, 255) },
}

local function constructor(m: Model, s: number)
	local c = {}

	function c.pieza(nombre: string, size: Vector3, cf: CFrame, color: Color3, choca: boolean, material: Enum.Material?)
		local p = Instance.new("Part")
		p.Name = nombre
		p.Size = size * s
		p.CFrame = cf
		p.Color = color
		p.Material = material or Enum.Material.SmoothPlastic
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.CanCollide = choca
		p.Parent = m
		return p
	end

	function c.en(x: number, y: number, z: number)
		return CFrame.new(x * s, y * s, z * s)
	end

	function c.adorno(nombre: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, unido: BasePart, neon: boolean?)
		local p = c.pieza(nombre, size, cf, color, false)
		p.Material = if neon then Enum.Material.Neon else (material or Enum.Material.SmoothPlastic)
		p.Massless = true
		p.CanQuery = false
		p.CanTouch = false
		local w = Instance.new("WeldConstraint")
		w.Part0 = unido
		w.Part1 = p
		w.Parent = p
		return p
	end

	function c.redondo(p: BasePart)
		local malla = Instance.new("SpecialMesh")
		malla.MeshType = Enum.MeshType.Sphere
		malla.Parent = p
		return p
	end

	function c.pata(tronco: BasePart, pos: Vector3, dir: Vector3, largo: number, grosor: number, color: Color3, eje: string): Motor6D
		local giro = if eje == "vertical" then CFrame.Angles(-math.pi / 2, 0, 0) else CFrame.Angles(0, math.pi / 2, 0)
		local c0 = CFrame.new(pos * s) * giro
		local dirLocal = giro:VectorToObjectSpace(dir.Unit)
		local arriba = if math.abs(dirLocal.Y) > 0.95 then V(0, 0, 1) else V(0, 1, 0)
		local rel = CFrame.lookAt(Vector3.zero, dirLocal, arriba) * CFrame.new(0, 0, -largo * s / 2)
		local p = c.pieza("Pata", V(grosor, grosor, largo), tronco.CFrame * c0 * rel, color, false)
		p.Massless = true
		p.CanQuery = false
		p.CanTouch = false
		local mo = Instance.new("Motor6D")
		mo.Name = "Pata"
		mo.Part0 = tronco
		mo.Part1 = p
		mo.C0 = c0
		mo.C1 = rel:Inverse()
		mo.MaxVelocity = 0.12
		mo.Parent = tronco
		return mo
	end

	return c
end

local function humanoide(m: Model, datos, rig: Enum.HumanoidRigType, alturaCadera: number?)
	local hum = Instance.new("Humanoid")
	hum.RigType = rig
	hum.RequiresNeck = false
	hum.BreakJointsOnDeath = false
	pcall(function()
		hum.AutomaticScalingEnabled = false
	end)
	if alturaCadera then
		hum.HipHeight = alturaCadera
	end
	hum.DisplayName = datos.nombre
	hum.MaxHealth = datos.vida
	hum.Health = datos.vida
	hum.WalkSpeed = datos.velocidad
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged
	hum.HealthDisplayDistance = 60
	hum.NameDisplayDistance = if datos.jefe or datos.especial then 150 else 0
	hum.Parent = m
	return hum
end

local function terminar(m: Model)
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			d.CollisionGroup = GRUPO
		end
	end
	m.PrimaryPart = m:FindFirstChild("HumanoidRootPart") :: BasePart
end

local function crearHumano(tipo: string): Model
	local datos = CFG.TIPOS[tipo]
	local ap = APARIENCIA[tipo]
	local s = datos.escala
	local m = Instance.new("Model")
	m.Name = datos.nombre
	local c = constructor(m, s)
	local pieza, en, adorno = c.pieza, c.en, c.adorno

	local raiz = pieza("HumanoidRootPart", V(2, 2, 1), en(0, 0, 0), ap.torso, false)
	raiz.Transparency = 1
	local torso = pieza("Torso", V(2, 2, 1), en(0, 0, 0), ap.torso, true)
	local cabeza = pieza("Head", V(2, 1, 1), en(0, 1.5, 0), ap.piel, true)
	local mallaCabeza = Instance.new("SpecialMesh")
	mallaCabeza.MeshType = Enum.MeshType.Head
	mallaCabeza.Scale = V(1.25, 1.25, 1.25)
	mallaCabeza.Parent = cabeza
	local brazoD = pieza("Right Arm", V(1, 2, 1), en(1.5, 0, 0), ap.piel, false)
	local brazoI = pieza("Left Arm", V(1, 2, 1), en(-1.5, 0, 0), ap.piel, false)
	local piernaD = pieza("Right Leg", V(1, 2, 1), en(0.5, -2, 0), ap.piernas, false)
	local piernaI = pieza("Left Leg", V(1, 2, 1), en(-0.5, -2, 0), ap.piernas, false)

	for _, x in { -0.28, 0.28 } do
		adorno("Ojo", V(0.22, 0.18, 0.1), en(x, 1.6, -0.66), ap.ojos, nil, cabeza, true)
	end
	adorno("Musgo", V(1.2, 0.4, 1.1), en(0.4, 2.05, 0.1), ap.musgo, Enum.Material.LeafyGrass, cabeza)
	adorno("Musgo", V(1, 0.5, 1.1), en(1.2, 1.05, 0), ap.musgo, Enum.Material.LeafyGrass, torso)
	adorno("Musgo", V(0.9, 0.4, 1.1), en(-1.3, 1.02, 0.1), ap.musgo, Enum.Material.LeafyGrass, torso)
	adorno("Raiz", V(0.3, 1.6, 0.3), en(0.6, -0.2, -0.55) * CFrame.Angles(0, 0, 0.5), rgb(70, 50, 35), Enum.Material.Wood, torso)
	if ap.espinas then
		for i = 1, 6 do
			local x = -0.8 + (i - 1) * 0.32
			adorno("Espina", V(0.18, 0.18, 0.9), en(x, 0.6 - (i % 2) * 0.6, 0.85) * CFrame.Angles(math.rad(-30), 0, 0), ap.musgo, Enum.Material.Wood, torso)
		end
	end
	if ap.corteza then
		adorno("Corteza", V(2.2, 1.4, 0.3), en(0, 0.2, -0.6), rgb(70, 52, 38), Enum.Material.Wood, torso)
		adorno("Corteza", V(0.4, 1.6, 1.2), en(1.95, 0.2, 0), rgb(70, 52, 38), Enum.Material.Wood, brazoD)
		adorno("Corteza", V(0.4, 1.6, 1.2), en(-1.95, 0.2, 0), rgb(70, 52, 38), Enum.Material.Wood, brazoI)
	end
	if ap.sombrero then
		local ala = adorno("Sombrero", V(0.12, 3.4, 3.4), en(0, 2.15, 0) * CFrame.Angles(0, 0, math.pi / 2), rgb(120, 95, 55), Enum.Material.Fabric, cabeza)
		ala.Shape = Enum.PartType.Cylinder
		ala.Size = V(0.12, 3.4, 3.4) * s
		local copa = adorno("Sombrero", V(1, 1.6, 1.6), en(0, 2.65, 0) * CFrame.Angles(0, 0, math.pi / 2), rgb(110, 85, 50), Enum.Material.Fabric, cabeza)
		copa.Shape = Enum.PartType.Cylinder
		copa.Size = V(1, 1.6, 1.6) * s
	end
	if ap.tijeras then
		adorno("Tijeras", V(0.2, 0.3, 5), en(1.4, -1.1, -2.4) * CFrame.Angles(0, 0.12, 0), rgb(150, 150, 160), Enum.Material.Metal, brazoD)
		adorno("Tijeras", V(0.2, 0.3, 5), en(1.6, -1.1, -2.4) * CFrame.Angles(0, -0.12, 0), rgb(150, 150, 160), Enum.Material.Metal, brazoD)
		adorno("Mango", V(0.5, 0.5, 1.4), en(1.5, -1.1, 0.4), rgb(90, 60, 40), Enum.Material.Wood, brazoD)
	end

	local function motor(nombre: string, p0: BasePart, p1: BasePart, c0: CFrame, c1: CFrame)
		local mo = Instance.new("Motor6D")
		mo.Name = nombre
		mo.Part0 = p0
		mo.Part1 = p1
		mo.C0 = CFrame.new(c0.Position * s) * c0.Rotation
		mo.C1 = CFrame.new(c1.Position * s) * c1.Rotation
		mo.MaxVelocity = 0.1
		mo.Parent = p0
		return mo
	end
	motor("RootJoint", raiz, torso, CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0), CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0))
	motor("Neck", torso, cabeza, CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0), CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0))
	motor(
		"Right Shoulder",
		torso,
		brazoD,
		CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0) * CFrame.Angles(0, 0, math.rad(80)),
		CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
	)
	motor(
		"Left Shoulder",
		torso,
		brazoI,
		CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0) * CFrame.Angles(0, 0, math.rad(-80)),
		CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	)
	motor("Right Hip", torso, piernaD, CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0))
	motor("Left Hip", torso, piernaI, CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0))

	local hum = humanoide(m, datos, Enum.HumanoidRigType.R6)
	hum.RequiresNeck = true
	hum.BreakJointsOnDeath = true
	Instance.new("Animator").Parent = hum
	terminar(m)
	return m
end

local function crearLobo(tipo: string): Model
	local datos = CFG.TIPOS[tipo]
	local ap = APARIENCIA[tipo]
	local s = datos.escala
	local m = Instance.new("Model")
	m.Name = datos.nombre
	local c = constructor(m, s)
	local pieza, en, adorno = c.pieza, c.en, c.adorno
	local pelo = Enum.Material.Fabric

	local raiz = pieza("HumanoidRootPart", V(2, 2, 4), en(0, 0, 0), ap.pelo, false)
	raiz.Transparency = 1
	local torso = pieza("Torso", V(2.2, 2.1, 4.6), en(0, 0.1, 0), ap.pelo, true, pelo)
	local w = Instance.new("WeldConstraint")
	w.Part0 = raiz
	w.Part1 = torso
	w.Parent = torso
	adorno("Pecho", V(2.5, 2.5, 1.8), en(0, 0.35, -1.7), ap.pelo, pelo, torso)
	adorno("Panza", V(1.8, 0.4, 3.6), en(0, -1, 0.1), ap.panza, pelo, torso)
	adorno("Lomo", V(0.7, 0.45, 3.8), en(0, 1.25, 0.2), ap.oscuro, pelo, torso)
	adorno("Cuello", V(1.6, 1.6, 1.4), en(0, 0.9, -2.6) * CFrame.Angles(math.rad(25), 0, 0), ap.pelo, pelo, torso)
	local cabeza = pieza("Head", V(1.7, 1.5, 1.8), en(0, 1.25, -3.3), ap.pelo, false, pelo)
	cabeza.Massless = true
	local wc = Instance.new("WeldConstraint")
	wc.Part0 = torso
	wc.Part1 = cabeza
	wc.Parent = cabeza
	adorno("Hocico", V(1, 0.8, 1.4), en(0, 0.9, -4.6), ap.pelo, pelo, cabeza)
	adorno("Nariz", V(0.45, 0.35, 0.3), en(0, 1.2, -5.35), rgb(15, 15, 15), nil, cabeza)
	adorno("Mandibula", V(0.85, 0.3, 1.2), en(0, 0.4, -4.4), ap.oscuro, nil, cabeza)
	for _, x in { -0.28, 0.28 } do
		adorno("Colmillo", V(0.14, 0.4, 0.14), en(x, 0.55, -5.05), rgb(240, 235, 220), nil, cabeza)
	end
	for _, x in { -0.5, 0.5 } do
		adorno("Oreja", V(0.4, 0.8, 0.35), en(x, 2.25, -3.05) * CFrame.Angles(math.rad(-10), 0, x * 0.4), ap.oscuro, pelo, cabeza)
		adorno("Ojo", V(0.3, 0.18, 0.1), en(x * 0.85, 1.55, -4.22), ap.ojos, nil, cabeza, true)
	end
	adorno("Cola", V(0.55, 0.55, 2.4), en(0, 0.8, 3.1) * CFrame.Angles(math.rad(30), 0, 0), ap.pelo, pelo, torso)
	adorno("Cola", V(0.45, 0.45, 1.2), en(0, 0.2, 4.2) * CFrame.Angles(math.rad(50), 0, 0), ap.oscuro, pelo, torso)
	if ap.musgo then
		adorno("Musgo", V(1.6, 0.5, 1.6), en(0.3, 1.25, -0.8), ap.musgo, Enum.Material.LeafyGrass, torso)
		adorno("Musgo", V(1.2, 0.5, 1.4), en(-0.4, 1.2, 1.2), ap.musgo, Enum.Material.LeafyGrass, torso)
		for i = 1, 4 do
			adorno("Espina", V(0.2, 0.9, 0.2), en(0, 1.6, -1.5 + i * 0.8) * CFrame.Angles(math.rad(-25), 0, 0), rgb(70, 50, 35), Enum.Material.Wood, torso)
		end
		local luz = Instance.new("PointLight")
		luz.Color = ap.ojos
		luz.Range = 14
		luz.Brightness = 1.5
		luz.Parent = cabeza
	end

	local patas = {}
	for _, z in { -1.6, 1.6 } do
		for _, x in { -0.75, 0.75 } do
			table.insert(patas, c.pata(torso, V(x, -0.9, z), V(0, -1, 0), 2.5, 0.7, ap.oscuro, "lateral"))
		end
	end
	patas = { patas[1], patas[4], patas[2], patas[3] }

	humanoide(m, datos, Enum.HumanoidRigType.R15, 2.4 * s)
	terminar(m)
	m:SetAttribute("Patas", #patas)
	return m
end

local function crearArana(tipo: string): Model
	local datos = CFG.TIPOS[tipo]
	local ap = APARIENCIA[tipo]
	local s = datos.escala
	local m = Instance.new("Model")
	m.Name = datos.nombre
	local c = constructor(m, s)
	local pieza, en, adorno = c.pieza, c.en, c.adorno

	local raiz = pieza("HumanoidRootPart", V(2.4, 1.4, 2.8), en(0, 0, 0), ap.cuerpo, false)
	raiz.Transparency = 1
	local torso = pieza("Torso", V(2.2, 1.3, 2), en(0, 0, -0.5), ap.cuerpo, true)
	c.redondo(torso)
	local w = Instance.new("WeldConstraint")
	w.Part0 = raiz
	w.Part1 = torso
	w.Parent = torso
	local abdomen = c.redondo(adorno("Abdomen", V(2.8, 2.2, 3.2), en(0, 0.55, 1.8), ap.cuerpo, nil, torso))
	abdomen.Material = Enum.Material.Fabric
	c.redondo(adorno("Dibujo", V(1.2, 0.3, 1.6), en(0, 1.62, 1.8), ap.dibujo, nil, torso, true))
	local cabeza = pieza("Head", V(1.2, 0.9, 0.9), en(0, 0.15, -1.6), ap.cuerpo, false)
	c.redondo(cabeza)
	cabeza.Massless = true
	local wc = Instance.new("WeldConstraint")
	wc.Part0 = torso
	wc.Part1 = cabeza
	wc.Parent = cabeza
	for _, p in { V(-0.25, 0.45, -2), V(0.25, 0.45, -2), V(-0.45, 0.3, -1.95), V(0.45, 0.3, -1.95), V(-0.15, 0.25, -2.05), V(0.15, 0.25, -2.05) } do
		c.redondo(adorno("Ojo", V(0.2, 0.2, 0.2), en(p.X, p.Y, p.Z), ap.ojos, nil, cabeza, true))
	end
	for _, x in { -0.25, 0.25 } do
		adorno("Colmillo", V(0.16, 0.5, 0.16), en(x, -0.2, -2) * CFrame.Angles(math.rad(-20), 0, 0), rgb(220, 210, 190), nil, cabeza)
	end

	local patas = {}
	for i, z in { -1.1, -0.7, -0.3, 0.1 } do
		local haciaZ = ({ -0.9, -0.3, 0.3, 0.9 })[i]
		for _, lado in { -1, 1 } do
			table.insert(patas, c.pata(torso, V(lado * 0.8, 0.1, z), V(lado, -0.75, haciaZ), 3.3, 0.28, ap.patas, "vertical"))
		end
	end

	humanoide(m, datos, Enum.HumanoidRigType.R15, 1.4 * s)
	terminar(m)
	m:SetAttribute("Patas", #patas)
	return m
end

local function crearFantasma(tipo: string): Model
	local datos = CFG.TIPOS[tipo]
	local ap = APARIENCIA[tipo]
	local s = datos.escala
	local m = Instance.new("Model")
	m.Name = datos.nombre
	local c = constructor(m, s)
	local pieza, en = c.pieza, c.en

	local raiz = pieza("HumanoidRootPart", V(2, 2, 1), en(0, 0, 0), ap.vestido, false)
	raiz.Transparency = 1
	raiz.Anchored = true
	raiz.CanQuery = true
	local function parteFantasma(nombre: string, size: Vector3, cf: CFrame, color: Color3, transparencia: number, redonda: boolean?)
		local p = pieza(nombre, size, cf, color, false, Enum.Material.Neon)
		p.Transparency = transparencia
		p.Massless = true
		p.CanTouch = false
		p.CanQuery = false
		if redonda then
			c.redondo(p)
		end
		local w = Instance.new("WeldConstraint")
		w.Part0 = raiz
		w.Part1 = p
		w.Parent = p
		return p
	end
	local torso = parteFantasma("Torso", V(2, 2.6, 1.3), en(0, 0, 0), ap.vestido, 0.45, true)
	torso.Name = "Torso"
	parteFantasma("Falda", V(3, 3.4, 2.2), en(0, -2, 0.1), ap.vestido, 0.55, true)
	parteFantasma("Bajo", V(2.4, 2.2, 1.8), en(0, -3.8, 0.4), ap.vestido, 0.75, true)
	local cabeza = parteFantasma("Head", V(1.5, 1.7, 1.5), en(0, 2.1, 0), ap.piel, 0.3, true)
	cabeza.Name = "Head"
	local pelo = pieza("Pelo", V(1.7, 2.6, 0.6), en(0, 1.6, 0.6), ap.pelo, false)
	pelo.Transparency = 0.25
	pelo.Massless = true
	pelo.CanTouch = false
	pelo.CanQuery = false
	local wp = Instance.new("WeldConstraint")
	wp.Part0 = raiz
	wp.Part1 = pelo
	wp.Parent = pelo
	for _, x in { -0.32, 0.32 } do
		local ojo = parteFantasma("Ojo", V(0.32, 0.4, 0.1), en(x, 2.25, -0.72), ap.ojos, 0, true)
		ojo.Transparency = 0
	end
	for _, x in { -1.1, 1.1 } do
		parteFantasma("Brazo", V(0.5, 0.5, 2.8), en(x, 0.7, -1.3) * CFrame.Angles(math.rad(10), 0, 0), ap.piel, 0.45)
	end
	local luz = Instance.new("PointLight")
	luz.Color = ap.ojos
	luz.Range = 16
	luz.Brightness = 1.4
	luz.Parent = torso
	local bruma = Instance.new("ParticleEmitter")
	bruma.Texture = "rbxasset://textures/particles/smoke_main.dds"
	bruma.Color = ColorSequence.new(rgb(200, 220, 255))
	bruma.LightEmission = 0.6
	bruma.Size = NumberSequence.new(1.5, 3)
	bruma.Transparency = NumberSequence.new(0.7, 1)
	bruma.Lifetime = NumberRange.new(1, 2)
	bruma.Rate = 8
	bruma.Speed = NumberRange.new(0.5, 1)
	bruma.Parent = torso

	humanoide(m, datos, Enum.HumanoidRigType.R6)
	terminar(m)
	return m
end

local function plantilla(tipo: string): Model
	if not plantillas[tipo] then
		local forma = CFG.TIPOS[tipo].forma
		if forma == "lobo" then
			plantillas[tipo] = crearLobo(tipo)
		elseif forma == "arana" then
			plantillas[tipo] = crearArana(tipo)
		elseif forma == "fantasma" then
			plantillas[tipo] = crearFantasma(tipo)
		else
			plantillas[tipo] = crearHumano(tipo)
		end
	end
	return plantillas[tipo]
end

local function contar(filtro: ((any) -> boolean)?): number
	local n = 0
	for _, e in activos do
		if not filtro or filtro(e) then
			n += 1
		end
	end
	return n
end

local function actualizarContador()
	Estado.set("EnemigosVivos", contar())
end

local function suelo(pos: Vector3): Vector3
	local res = workspace:Raycast(pos + V(0, 2, 0), V(0, -60, 0), params)
	if res then
		return res.Position + V(0, 0.6, 0)
	end
	return pos
end

local function hayVision(desde: Vector3, hasta: Vector3): boolean
	local res = workspace:Raycast(desde, hasta - desde, params)
	if not res then
		return true
	end
	local modelo = res.Instance:FindFirstAncestorOfClass("Model")
	return modelo ~= nil and modelo:FindFirstChildOfClass("Humanoid") ~= nil
end

local function tierra(pos: Vector3, color: Color3?)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = V(3, 1, 3)
	p.Position = pos
	p.Parent = workspace
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(color or rgb(90, 64, 42))
	e.Size = NumberSequence.new(0.6, 0.1)
	e.Lifetime = NumberRange.new(0.6, 1.2)
	e.Speed = NumberRange.new(8, 14)
	e.SpreadAngle = Vector2.new(35, 35)
	e.Acceleration = V(0, -30, 0)
	e.EmissionDirection = Enum.NormalId.Top
	e.Enabled = false
	e.Parent = p
	e:Emit(30)
	task.delay(2, function()
		p:Destroy()
	end)
end

local function jugadoresVivos()
	local lista = {}
	for _, j in Players:GetPlayers() do
		local c = j.Character
		local h = c and c:FindFirstChildOfClass("Humanoid")
		local r = c and c:FindFirstChild("HumanoidRootPart")
		if h and r and h.Health > 0 then
			table.insert(lista, { jugador = j, hum = h, raiz = r :: BasePart })
		end
	end
	return lista
end

local function plano(v: Vector3): Vector3
	return V(v.X, 0, v.Z)
end

local function soltarCerca(recurso: string, pos: Vector3, radio: number)
	local a = math.random() * math.pi * 2
	Recursos.soltar(recurso, suelo(pos + V(math.cos(a) * radio, 0, math.sin(a) * radio)), 1)
end

local function morir(e)
	if e.muerto then
		return
	end
	e.muerto = true
	activos[e.modelo] = nil
	actualizarContador()
	local pos = e.raiz.Position
	local datos = e.datos
	if not e.sinBotin then
		if datos.jefe then
			for i = 1, 8 do
				local a = i * (math.pi / 4)
				Recursos.soltar(if i % 2 == 0 then "Chatarra" else "Comida", suelo(pos + V(math.cos(a) * 4, 0, math.sin(a) * 4)), 2)
			end
			Estado.anunciar("¡EL JARDINERO HA CAÍDO!", "Pero el jardín sigue despierto... ¡resistid hasta el amanecer!")
		elseif datos.botinExtra then
			local recursos = { "Comida", "Chatarra", "Lena" }
			for i = 1, datos.botinExtra do
				soltarCerca(recursos[(i % 3) + 1], pos, 4)
			end
			Estado.anunciar("¡" .. string.upper(datos.nombre) .. " HA CAÍDO!", "El bosque se queda en silencio... por ahora.")
		elseif datos.botin then
			for recurso, probabilidad in datos.botin do
				if math.random() < probabilidad then
					soltarCerca(recurso, pos, 2)
				end
			end
		end
	end
	for _, d in e.modelo:GetDescendants() do
		if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
			TweenService:Create(d, TweenInfo.new(1.5), { Color = rgb(40, 32, 26), Transparency = 1 }):Play()
		elseif d:IsA("Light") then
			TweenService:Create(d, TweenInfo.new(1), { Brightness = 0 }):Play()
		end
	end
	task.delay(1.6, function()
		e.modelo:Destroy()
	end)
end

local function marchitarTodos()
	for _, e in activos do
		e.sinBotin = true
		e.hum.Health = 0
	end
end

local function esconder(e)
	if e.muerto then
		return
	end
	e.muerto = true
	activos[e.modelo] = nil
	actualizarContador()
	e.modelo:Destroy()
end

local function moverA(e, destino: Vector3)
	local pos = e.raiz.Position
	local ahora = os.clock()
	e.destino = destino
	local dist = (destino - pos).Magnitude
	if dist < 14 and math.abs(destino.Y - pos.Y) < 4 and hayVision(pos, destino) then
		e.ruta = nil
		e.hum:MoveTo(destino)
		return
	end

	local espera = if e.ruta then 1.5 else 2.5
	local lejos = e.rutaDestino == nil or (e.rutaDestino - destino).Magnitude > 8
	if not e.calculando and (ahora - e.rutaTiempo > espera or (lejos and ahora - e.rutaTiempo > 0.6)) then
		e.calculando = true
		task.spawn(function()
			local ok = pcall(function()
				e.path:ComputeAsync(e.raiz.Position, destino)
			end)
			e.calculando = false
			e.rutaTiempo = os.clock()
			e.rutaDestino = destino
			if ok and e.path.Status == Enum.PathStatus.Success then
				e.ruta = e.path:GetWaypoints()
				e.indice = 2
			else
				e.ruta = nil
			end
		end)
	end

	if e.ruta then
		local wp = e.ruta[e.indice]
		while wp and (V(wp.Position.X, pos.Y, wp.Position.Z) - pos).Magnitude < 2.5 do
			e.indice += 1
			wp = e.ruta[e.indice]
		end
		if wp then
			if wp.Action == Enum.PathWaypointAction.Jump then
				e.hum.Jump = true
			end
			e.hum:MoveTo(wp.Position)
			return
		end
	end
	e.hum:MoveTo(destino)
end

local function flotarA(e, destino: Vector3)
	local pos = e.raiz.Position
	local t = os.clock()
	local objetivo = destino + V(0, 0.6 + math.sin(t * 2 + e.fase) * 0.5, 0)
	local dir = objetivo - pos
	local paso = math.min(dir.Magnitude, e.hum.WalkSpeed * TICK)
	local nueva = if dir.Magnitude > 0.05 then pos + dir.Unit * paso else pos
	local mirar = plano(destino - pos)
	local cf = if mirar.Magnitude > 0.5 then CFrame.lookAt(nueva, nueva + mirar) else CFrame.new(nueva) * e.raiz.CFrame.Rotation
	if e.tween then
		e.tween:Cancel()
	end
	e.tween = TweenService:Create(e.raiz, TweenInfo.new(TICK, Enum.EasingStyle.Linear), { CFrame = cf })
	e.tween:Play()
end

local function ir(e, destino: Vector3)
	if e.vuela then
		flotarA(e, destino)
	else
		moverA(e, destino)
	end
end

local function envenenar(hum: Humanoid, segundos: number, jugador: Player?)
	local hasta = os.clock() + segundos
	local yaEstaba = (hum:GetAttribute("VenenoHasta") or 0) > os.clock()
	hum:SetAttribute("VenenoHasta", hasta)
	if not yaEstaba then
		hum:SetAttribute("VelocidadNormal", hum.WalkSpeed)
		hum.WalkSpeed = hum.WalkSpeed * 0.55
		if jugador then
			Estado.notificar(jugador, "🕷️ ¡Te ha mordido una araña! Vas más lento un momento.", rgb(190, 255, 120))
		end
	end
	task.delay(segundos + 0.05, function()
		if hum.Parent and (hum:GetAttribute("VenenoHasta") or 0) <= os.clock() then
			hum.WalkSpeed = hum:GetAttribute("VelocidadNormal") or 16
			hum:SetAttribute("VenenoHasta", nil)
		end
	end)
end

local function atacar(e, objetivo)
	local ahora = os.clock()
	if ahora - e.ultimoAtaque < e.datos.cadencia then
		return
	end
	e.ultimoAtaque = ahora
	objetivo.hum:TakeDamage(e.datos.dano)
	if e.datos.veneno then
		envenenar(objetivo.hum, e.datos.veneno, objetivo.jugador)
	end
	if e.patas and not e.vuela then
		e.hum.Jump = true
	end
end

local function puedePerseguir(e, v): boolean
	local p = v.raiz.Position
	if not e.datos.jefe and Chimenea.estaProtegido(p) then
		return false
	end
	if e.correa and (plano(p) - plano(e.hogar)).Magnitude > e.correa then
		return false
	end
	if e.soloFuera and Config.dentroDeFinca(p) then
		return false
	end
	return true
end

local function animarPatas(e)
	if not e.patas then
		return
	end
	local anda = e.raiz.AssemblyLinearVelocity.Magnitude > 1.5
	e.pisada = not e.pisada
	local amplitud = if e.datos.forma == "arana" then 0.35 else 0.6
	for i, motor in e.patas do
		if anda then
			local par = (i % 2 == 0) == e.pisada
			motor.DesiredAngle = if par then amplitud else -amplitud
		else
			motor.DesiredAngle = 0
		end
	end
end

local function pasear(e, ahora: number)
	if ahora - (e.ultimoPaseo or 0) > 7 then
		e.ultimoPaseo = ahora
		if e.hogar then
			local a = math.random() * math.pi * 2
			local r = math.random(6, 30)
			e.paseo = e.hogar + V(math.cos(a) * r, 0, math.sin(a) * r)
		else
			local lista = puntos[e.datos.aparece or "PuntoEnemigo"] or {}
			if #lista == 0 then
				lista = puntos.PuntoEnemigo or {}
			end
			if #lista > 0 then
				e.paseo = lista[math.random(1, #lista)].Position
			end
		end
	end
	if e.paseo then
		ir(e, e.paseo)
	end
end

local function actualizar(e, vivos)
	local pos = e.raiz.Position
	local ahora = os.clock()
	local datos = e.datos

	e.hum.WalkSpeed = datos.velocidad * (if ahora < e.lentoHasta then Config.FAROL.LENTITUD else 1)
	animarPatas(e)

	if Chimenea.estaProtegido(pos) then
		e.hum:TakeDamage(Config.CHIMENEA.DANO_LUZ * TICK * (if datos.jefe then 0.3 else 1))
		if not datos.jefe then
			ir(e, Chimenea.puntoBorde(pos, 8))
			return
		end
	end

	local mejor, mejorDist = nil, math.huge
	for _, v in vivos do
		local d = (v.raiz.Position - pos).Magnitude
		if d < mejorDist and puedePerseguir(e, v) then
			mejor, mejorDist = v, d
		end
	end

	local alcance = (if datos.forma == "lobo" then 4.5 elseif datos.forma == "arana" then 3.8 else 3.5) * datos.escala + 1.5
	if mejor then
		if mejorDist <= alcance then
			atacar(e, mejor)
		end
		ir(e, mejor.raiz.Position)
	elseif #vivos > 0 and not e.correa and not e.soloFuera then
		ir(e, Chimenea.puntoBorde(pos, 6))
	else
		pasear(e, ahora)
	end

	if e.vuela then
		return
	end
	local lejosDelDestino = e.destino ~= nil and (e.destino - pos).Magnitude > 6
	if (pos - e.ultimaPos).Magnitude > 1.5 or not lejosDelDestino then
		e.ultimaPos = pos
		e.ultimoMovimiento = ahora
	elseif ahora - e.ultimoMovimiento > 1.5 then
		e.hum.Jump = true
		e.ruta = nil
		e.ultimoMovimiento = ahora
	end
end

function Enemigos.aparecer(tipo: string, pos: Vector3, opciones: { [string]: any }?)
	local op = opciones or {}
	local datos = CFG.TIPOS[tipo]
	local m = plantilla(tipo):Clone()
	local hum = m:FindFirstChildOfClass("Humanoid") :: Humanoid
	local raiz = m:FindFirstChild("HumanoidRootPart") :: BasePart
	local noche = math.max(1, Estado.get("NocheActual") or 1)
	local vida = if datos.jefe then datos.vida else math.floor(datos.vida * (1 + CFG.VIDA_POR_NOCHE * (noche - 1)))
	hum.MaxHealth = vida
	hum.Health = vida
	local vuela = datos.forma == "fantasma"
	local alto = if vuela then 3.4 elseif datos.forma == "lobo" then 3.6 * datos.escala elseif datos.forma == "arana" then 2.4 else 3 * datos.escala
	m:PivotTo(CFrame.new(pos + V(0, alto, 0)) * CFrame.Angles(0, math.random() * 6.28, 0))
	m.Parent = carpeta
	if not vuela then
		pcall(function()
			raiz:SetNetworkOwner(nil)
		end)
	end
	CollectionService:AddTag(m, "Enemigo")
	if datos.jefe or datos.especial then
		local resalte = Instance.new("Highlight")
		resalte.FillTransparency = 1
		resalte.OutlineColor = if datos.jefe then rgb(255, 60, 60) else rgb(255, 140, 40)
		resalte.Parent = m
	end

	local patas = nil
	local torso = m:FindFirstChild("Torso")
	if torso and datos.forma ~= nil and datos.forma ~= "fantasma" then
		patas = {}
		for _, d in torso:GetChildren() do
			if d:IsA("Motor6D") and d.Name == "Pata" then
				table.insert(patas, d)
			end
		end
	end

	local e = {
		modelo = m,
		hum = hum,
		raiz = raiz,
		tipo = tipo,
		datos = datos,
		vuela = vuela,
		patas = patas,
		pisada = false,
		fase = math.random() * 6,
		hogar = op.hogar,
		correa = op.correa,
		soloFuera = op.soloFuera,
		etiqueta = op.etiqueta,
		ultimoAtaque = 0,
		lentoHasta = 0,
		ruta = nil,
		indice = 1,
		rutaTiempo = 0,
		rutaDestino = nil,
		calculando = false,
		ultimaPos = raiz.Position,
		ultimoMovimiento = os.clock(),
		path = PathfindingService:CreatePath({
			AgentRadius = (if datos.forma == "lobo" or datos.forma == "arana" then 2 else 1.6) * datos.escala,
			AgentHeight = (if datos.forma == "arana" then 3 else 5) * datos.escala,
			AgentCanJump = true,
			WaypointSpacing = 5,
			Costs = { Water = 20 },
		}),
	}
	activos[m] = e
	actualizarContador()

	if not patas and not vuela then
		local animator = hum:FindFirstChildOfClass("Animator")
		if animator then
			local ok, pista = pcall(function()
				local anim = Instance.new("Animation")
				anim.AnimationId = ANIM_ANDAR
				return animator:LoadAnimation(anim)
			end)
			if ok and pista then
				hum.Running:Connect(function(velocidad)
					if velocidad > 0.5 then
						if not pista.IsPlaying then
							pista:Play(0.2)
						end
						pista:AdjustSpeed(velocidad / 12)
					elseif pista.IsPlaying then
						pista:Stop(0.2)
					end
				end)
			end
		end
	end
	hum.Died:Connect(function()
		if e.tween then
			e.tween:Cancel()
		end
		morir(e)
	end)
	if vuela then
		tierra(pos + V(0, 2, 0), rgb(200, 220, 255))
	else
		tierra(pos)
	end
	return e
end

function Enemigos.ralentizar(modelo: Model, segundos: number)
	local e = activos[modelo]
	if e then
		e.lentoHasta = os.clock() + segundos
	end
end

local function elegirTipo(noche: number): string
	local candidatos = {}
	local total = 0
	for nombre, datos in CFG.TIPOS do
		local lleno = datos.maximo and contar(function(e)
			return e.tipo == nombre
		end) >= datos.maximo
		if not datos.jefe and not datos.especial and noche >= datos.desdeNoche and not lleno then
			table.insert(candidatos, { nombre, datos.peso })
			total += datos.peso
		end
	end
	local r = math.random() * total
	for _, c in candidatos do
		r -= c[2]
		if r <= 0 then
			return c[1]
		end
	end
	return if candidatos[1] then candidatos[1][1] else "Marchito"
end

local function puntoAparicion(etiqueta: string): Vector3?
	local lista = puntos[etiqueta]
	if not lista or #lista == 0 then
		lista = puntos.PuntoEnemigo
	end
	if not lista or #lista == 0 then
		return nil
	end
	local candidatos = {}
	local vivos = jugadoresVivos()
	for _, p in lista do
		local cerca = false
		for _, v in vivos do
			if (v.raiz.Position - p.Position).Magnitude < 25 then
				cerca = true
				break
			end
		end
		if not cerca and not Chimenea.estaProtegido(p.Position) then
			table.insert(candidatos, p)
		end
	end
	if #candidatos == 0 then
		candidatos = lista
	end
	return candidatos[math.random(1, #candidatos)].Position
end

local function oleada(total: number, duracion: number, fase: string, noche: number)
	local intervalo = duracion * 0.6 / math.max(total, 1)
	for _ = 1, total do
		while contar() >= CFG.MAXIMO_VIVOS do
			task.wait(1)
			if Estado.get("Fase") ~= fase then
				return
			end
		end
		if Estado.get("Fase") ~= fase then
			return
		end
		local tipo = elegirTipo(noche)
		local pos = puntoAparicion(CFG.TIPOS[tipo].aparece or "PuntoEnemigo")
		if pos then
			Enemigos.aparecer(tipo, pos)
		end
		task.wait(intervalo)
	end
end

local function puntoMasCercano(etiqueta: string, a: Vector3): Vector3?
	local mejor, mejorDist = nil, math.huge
	for _, p in puntos[etiqueta] or {} do
		local d = (p.Position - a).Magnitude
		if d < mejorDist then
			mejor, mejorDist = p.Position, d
		end
	end
	return mejor
end

local function aparecerJardinero()
	if Estado.get("Fase") ~= "UltimaNoche" then
		return
	end
	local pos = puntoMasCercano("PuntoEnemigo", V(-120, 0, -140))
	if pos then
		Enemigos.aparecer("Jardinero", pos)
		Estado.anunciar("EL JARDINERO HA DESPERTADO", "Viene a por vosotros... y la luz apenas le hace daño.")
	end
end

local function aparecerHuargo()
	local lista = puntos.PuntoGuarida
	if not lista or #lista == 0 then
		return
	end
	if contar(function(e)
		return e.tipo == "Huargo"
	end) > 0 then
		return
	end
	Enemigos.aparecer("Huargo", lista[1].Position)
	Estado.anunciar("🐺 UN AULLIDO EN EL BOSQUE", "El Huargo ha salido de su guarida... y viene hacia la mansión.")
end

local function esDelBosque(e): boolean
	return e.soloFuera == true
end

local function bosqueDeDia()
	if Estado.get("Fase") ~= "Dia" then
		return
	end
	local vivos = jugadoresVivos()
	local fuera = {}
	for _, v in vivos do
		if not Config.dentroDeFinca(v.raiz.Position) then
			table.insert(fuera, v)
		end
	end

	for _, e in activos do
		if esDelBosque(e) then
			local cerca = false
			for _, v in vivos do
				if (v.raiz.Position - e.raiz.Position).Magnitude < BOSQUE.DESAPARECER then
					cerca = true
					break
				end
			end
			if not cerca then
				esconder(e)
			end
		end
	end

	if #fuera == 0 or contar(esDelBosque) >= BOSQUE.MAX_DIA or contar() >= CFG.MAXIMO_VIVOS then
		return
	end
	local v = fuera[math.random(1, #fuera)]
	local candidatos = {}
	for _, etiqueta in { "PuntoBosque", "PuntoCueva" } do
		for _, p in puntos[etiqueta] or {} do
			local d = (p.Position - v.raiz.Position).Magnitude
			if d > BOSQUE.DISTANCIA_MIN and d < BOSQUE.DISTANCIA_MAX then
				table.insert(candidatos, { p.Position, etiqueta })
			end
		end
	end
	if #candidatos == 0 then
		return
	end
	local elegido = candidatos[math.random(1, #candidatos)]
	local tipo = if elegido[2] == "PuntoCueva" or math.random() < 0.3 then "Arana" else "Lobo"
	Enemigos.aparecer(tipo, elegido[1], { hogar = elegido[1], correa = BOSQUE.CORREA, soloFuera = true })
end

local ultimaDama = -math.huge
local function damaDelDesvan()
	local lista = puntos.PuntoDesvan
	if not lista or #lista == 0 then
		return
	end
	local fase = Estado.get("Fase")
	if fase == "Escape" then
		return
	end
	local hay = contar(function(e)
		return e.etiqueta == "Desvan"
	end) > 0
	if hay then
		ultimaDama = os.clock()
		return
	end
	if os.clock() - ultimaDama < BOSQUE.FANTASMA_DESVAN_RECARGA then
		return
	end
	ultimaDama = os.clock()
	local pos = lista[math.random(1, #lista)].Position
	Enemigos.aparecer("Espectro", pos, { hogar = pos, correa = 45, etiqueta = "Desvan" })
end

function Enemigos.iniciar()
	pcall(function()
		PhysicsService:RegisterCollisionGroup(GRUPO)
	end)
	pcall(function()
		PhysicsService:CollisionGroupSetCollidable(GRUPO, GRUPO, false)
	end)

	carpeta = Instance.new("Folder")
	carpeta.Name = "Enemigos"
	carpeta.Parent = workspace
	params.FilterDescendantsInstances = { carpeta, Recursos.carpeta }

	for _, etiqueta in { "PuntoEnemigo", "PuntoLinde", "PuntoBosque", "PuntoCueva", "PuntoGuarida", "PuntoFantasma", "PuntoDesvan" } do
		puntos[etiqueta] = {}
		for _, p in CollectionService:GetTagged(etiqueta) do
			table.insert(puntos[etiqueta], p :: BasePart)
		end
	end
	if #puntos.PuntoEnemigo == 0 then
		warn("[Enemigos] No hay puntos de aparición (etiqueta 'PuntoEnemigo')")
	end
	Estado.set("EnemigosVivos", 0)

	Estado.escuchar("NocheEmpieza", function(noche: number)
		for _, e in activos do
			if esDelBosque(e) then
				e.correa = nil
				e.soloFuera = nil
				e.hogar = nil
			end
		end
		if noche >= CFG.HUARGO_DESDE_NOCHE then
			task.delay(Config.DURACION_NOCHE * 0.2, function()
				if Estado.get("Fase") == "Noche" then
					aparecerHuargo()
				end
			end)
		end
		oleada(CFG.BASE + CFG.POR_NOCHE * (noche - 1), Config.DURACION_NOCHE, "Noche", noche)
	end)
	Estado.escuchar("UltimaNocheEmpieza", function()
		task.delay(Config.DURACION_ULTIMA_NOCHE * 0.25, aparecerJardinero)
		task.delay(Config.DURACION_ULTIMA_NOCHE * 0.1, aparecerHuargo)
		oleada(CFG.ULTIMA_NOCHE, Config.DURACION_ULTIMA_NOCHE, "UltimaNoche", math.max(6, Estado.get("NocheActual") or 1))
	end)
	Estado.escuchar("NocheSobrevivida", marchitarTodos)
	Estado.escuchar("Escape", marchitarTodos)

	local avisado = false
	task.spawn(function()
		while true do
			task.wait(TICK)
			local vivos = jugadoresVivos()
			for modelo, e in activos do
				if e.muerto or not modelo.Parent then
					activos[modelo] = nil
					continue
				end
				local ok, err = pcall(actualizar, e, vivos)
				if not ok and not avisado then
					avisado = true
					warn("[Enemigos] Error en la IA: " .. tostring(err))
				end
			end
		end
	end)

	task.spawn(function()
		while true do
			task.wait(4)
			local ok, err = pcall(bosqueDeDia)
			if not ok then
				warn("[Enemigos] Error en el bosque: " .. tostring(err))
			end
			pcall(damaDelDesvan)
		end
	end)
end

return Enemigos
