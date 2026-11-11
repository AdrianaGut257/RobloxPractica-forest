local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local Util = {}

Util.rgb = Color3.fromRGB
Util.azar = Random.new(1921)
Util.DECO = { Deco = true }

local M = Enum.Material

local ESPECIALES = {
	Parent = true,
	Clase = true,
	Etiqueta = true,
	Atributos = true,
	Deco = true,
	Shape = true,
	Size = true,
	CFrame = true,
	Position = true,
}

function Util.parte(props)
	local p = Instance.new(props.Clase or "Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = M.SmoothPlastic
	if props.Shape then
		p.Shape = props.Shape
	end
	if props.Size then
		p.Size = props.Size
	end
	if props.CFrame then
		p.CFrame = props.CFrame
	elseif props.Position then
		p.Position = props.Position
	end
	if props.Deco then
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
	end
	for clave, valor in props do
		if not ESPECIALES[clave] then
			p[clave] = valor
		end
	end
	if props.Etiqueta then
		CollectionService:AddTag(p, props.Etiqueta)
	end
	if props.Atributos then
		for nombre, valor in props.Atributos do
			p:SetAttribute(nombre, valor)
		end
	end
	p.Parent = props.Parent
	return p
end

local function aCFrame(cf)
	if typeof(cf) == "Vector3" then
		return CFrame.new(cf)
	end
	return cf
end

local function mezclar(base, extra)
	if extra then
		for clave, valor in extra do
			base[clave] = valor
		end
	end
	return base
end

function Util.bloque(padre, size: Vector3, cf, color: Color3, material, extra)
	return Util.parte(mezclar({
		Parent = padre,
		Size = size,
		CFrame = aCFrame(cf),
		Color = color,
		Material = material or M.SmoothPlastic,
	}, extra))
end

function Util.bola(padre, diametro: number, pos: Vector3, color: Color3, material, extra)
	return Util.parte(mezclar({
		Parent = padre,
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(diametro, diametro, diametro),
		CFrame = CFrame.new(pos),
		Color = color,
		Material = material or M.SmoothPlastic,
	}, extra))
end

function Util.elipsoide(padre, size: Vector3, cf, color: Color3, material, extra)
	local p = Util.parte(mezclar({
		Parent = padre,
		Size = size,
		CFrame = aCFrame(cf),
		Color = color,
		Material = material or M.SmoothPlastic,
	}, extra))
	local malla = Instance.new("SpecialMesh")
	malla.MeshType = Enum.MeshType.Sphere
	malla.Parent = p
	return p
end

function Util.cilindro(padre, diametro: number, largo: number, cf, color: Color3, material, extra)
	return Util.parte(mezclar({
		Parent = padre,
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(largo, diametro, diametro),
		CFrame = aCFrame(cf),
		Color = color,
		Material = material or M.SmoothPlastic,
	}, extra))
end

function Util.cilindroV(padre, diametro: number, alto: number, centro: Vector3, color: Color3, material, extra)
	return Util.cilindro(padre, diametro, alto, CFrame.new(centro) * CFrame.Angles(0, 0, math.pi / 2), color, material, extra)
end

function Util.cuna(padre, size: Vector3, cf, color: Color3, material, extra)
	return Util.parte(mezclar({
		Clase = "WedgePart",
		Parent = padre,
		Size = size,
		CFrame = aCFrame(cf),
		Color = color,
		Material = material or M.SmoothPlastic,
	}, extra))
end

function Util.rampa(padre, ancho: number, a: Vector3, b: Vector3, color: Color3, material, extra, grosor: number?)
	local g = grosor or 1
	local largo = (b - a).Magnitude
	local cf = CFrame.lookAt((a + b) / 2, b) * CFrame.new(0, -g / 2, 0)
	return Util.bloque(padre, Vector3.new(ancho, g, largo), cf, color, material, extra)
end

function Util.barra(padre, grosor: number, a: Vector3, b: Vector3, color: Color3, material, extra)
	local largo = (b - a).Magnitude
	local cf = CFrame.lookAt((a + b) / 2, b)
	return Util.bloque(padre, Vector3.new(grosor, grosor, largo), cf, color, material, extra)
end

function Util.fronton(padre, centroBase: Vector3, ancho: number, alto: number, fondo: number, color: Color3, material, extra)
	local mitad = ancho / 2
	Util.cuna(
		padre,
		Vector3.new(fondo, alto, mitad),
		CFrame.new(centroBase + Vector3.new(-mitad / 2, alto / 2, 0)) * CFrame.Angles(0, math.pi / 2, 0),
		color,
		material,
		extra
	)
	Util.cuna(
		padre,
		Vector3.new(fondo, alto, mitad),
		CFrame.new(centroBase + Vector3.new(mitad / 2, alto / 2, 0)) * CFrame.Angles(0, -math.pi / 2, 0),
		color,
		material,
		extra
	)
end

function Util.carpeta(nombre: string, padre: Instance?)
	local c = Instance.new("Folder")
	c.Name = nombre
	c.Parent = padre
	return c
end

function Util.modelo(nombre: string, padre: Instance?)
	local m = Instance.new("Model")
	m.Name = nombre
	m.Parent = padre
	return m
end

function Util.etiquetar(objeto: Instance, etiqueta: string)
	CollectionService:AddTag(objeto, etiqueta)
	return objeto
end

function Util.luz(parte: Instance, color: Color3, rango: number, brillo: number, sombras: boolean?)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = rango
	l.Brightness = brillo
	l.Shadows = sombras == true
	l.Parent = parte
	return l
end

function Util.prompt(parte: Instance, accion: string, objeto: string, duracion: number?, distancia: number?)
	local p = Instance.new("ProximityPrompt")
	p.ActionText = accion
	p.ObjectText = objeto
	p.HoldDuration = duracion or 0
	p.MaxActivationDistance = distancia or 10
	p.RequiresLineOfSight = false
	p.Parent = parte
	return p
end

function Util.particulas(parte: Instance, props)
	local e = Instance.new("ParticleEmitter")
	for clave, valor in props do
		e[clave] = valor
	end
	e.Parent = parte
	return e
end

function Util.soldar(a: BasePart, b: BasePart)
	local w = Instance.new("WeldConstraint")
	w.Part0 = a
	w.Part1 = b
	w.Parent = a
	return w
end

function Util.pivotar(modelo: Model, destino: CFrame, duracion: number)
	local inicio = modelo:GetPivot()
	local valor = Instance.new("NumberValue")
	local conexion = valor.Changed:Connect(function(alfa)
		modelo:PivotTo(inicio:Lerp(destino, alfa))
	end)
	local tween = TweenService:Create(
		valor,
		TweenInfo.new(duracion, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{ Value = 1 }
	)
	tween.Completed:Connect(function()
		conexion:Disconnect()
		valor:Destroy()
		modelo:PivotTo(destino)
	end)
	tween:Play()
	return tween
end

function Util.desvanecer(objeto: Instance, duracion: number)
	local partes = {}
	if objeto:IsA("BasePart") then
		table.insert(partes, objeto)
	end
	for _, d in objeto:GetDescendants() do
		if d:IsA("BasePart") then
			table.insert(partes, d)
		elseif d:IsA("Decal") then
			d:Destroy()
		end
	end
	for _, p in partes do
		p.CanCollide = false
		TweenService:Create(p, TweenInfo.new(duracion), { Transparency = 1 }):Play()
	end
	task.delay(duracion, function()
		objeto:Destroy()
	end)
end

function Util.elegir(lista)
	return lista[Util.azar:NextInteger(1, #lista)]
end

function Util.entre(a: number, b: number): number
	return Util.azar:NextNumber(a, b)
end

function Util.terreno(centro: Vector3, size: Vector3, material: Enum.Material)
	workspace.Terrain:FillBlock(CFrame.new(centro), size, material)
end

function Util.terrenoCilindro(centro: Vector3, alto: number, radio: number, material: Enum.Material)
	workspace.Terrain:FillCylinder(CFrame.new(centro), alto, radio, material)
end

return Util
