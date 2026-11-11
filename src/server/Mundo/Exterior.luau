local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local Util = require(script.Parent.Util)
local Props = require(script.Parent.Props)

local Exterior = {}

local M = Enum.Material
local V = Vector3.new
local rgb = Util.rgb
local DECO = Util.DECO
local C = Props.COLORES

local LADRILLO = rgb(150, 92, 72)
local PIEDRA = rgb(222, 212, 192)

local function letrero(parte: BasePart, cara: Enum.NormalId, texto: string, color: Color3)
	local gui = Instance.new("SurfaceGui")
	gui.Face = cara
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	local etiqueta = Instance.new("TextLabel")
	etiqueta.Size = UDim2.fromScale(1, 1)
	etiqueta.BackgroundTransparency = 1
	etiqueta.Font = Enum.Font.Garamond
	etiqueta.TextScaled = true
	etiqueta.Text = texto
	etiqueta.TextColor3 = color
	etiqueta.Parent = gui
	gui.Parent = parte
end

local function farolDePilar(padre, pos: Vector3)
	Util.bloque(padre, V(1.6, 2.2, 1.6), pos, rgb(255, 240, 210), M.Glass, { Deco = true, Transparency = 0.45 })
	local bombilla = Util.bola(padre, 1, pos, rgb(255, 236, 200), M.SmoothPlastic, DECO)
	Util.etiquetar(bombilla, "BombillaJardin")
	Util.bloque(padre, V(2, 0.4, 2), pos + V(0, 1.3, 0), C.metal, M.Metal, DECO)
	local luz = Util.luz(bombilla, rgb(255, 196, 125), 22, 1.8)
	luz.Enabled = false
	Util.etiquetar(luz, "LuzJardin")
end

local function tramoMuro(padre, a: Vector3, b: Vector3)
	local largo = (b - a).Magnitude
	local cf = CFrame.lookAt((a + b) / 2, b)
	Util.bloque(padre, V(2, 12, largo), cf * CFrame.new(0, 6, 0), LADRILLO, M.Brick)
	Util.bloque(padre, V(2.8, 0.8, largo + 0.8), cf * CFrame.new(0, 12.4, 0), PIEDRA, M.Limestone)
	local n = math.max(1, math.floor(largo / 30))
	for i = 0, n do
		local z = -largo / 2 + i * (largo / n)
		Util.bloque(padre, V(3.6, 14, 3.6), cf * CFrame.new(0, 7, z), LADRILLO, M.Brick)
		Util.bloque(padre, V(4.2, 0.8, 4.2), cf * CFrame.new(0, 14.4, z), PIEDRA, M.Limestone)
		Util.bola(padre, 1.6, (cf * CFrame.new(0, 15.6, z)).Position, PIEDRA, M.Limestone, DECO)
	end
	for _ = 1, math.floor(largo / 14) do
		local z = Util.entre(-largo / 2 + 3, largo / 2 - 3)
		local lado = if Util.azar:NextNumber() < 0.5 then -1.15 else 1.15
		local alto = Util.entre(4, 11)
		Util.bloque(padre, V(0.3, alto, Util.entre(2, 5)), cf * CFrame.new(lado, alto / 2, z), rgb(60, 115, 55), M.LeafyGrass, DECO)
	end
end

local ANCHO_BRECHA = 16

local function brecha(padre, cf: CFrame)
	local m = Util.modelo("Brecha", padre)
	for _, lado in { -1, 1 } do
		for k = 0, 2 do
			local h = 10.5 - k * 3.2 - Util.entre(0, 1.2)
			local z = lado * (ANCHO_BRECHA / 2 - 0.45 - k * 0.9)
			Util.bloque(m, V(2, h, 0.9), cf * CFrame.new(0, h / 2, z) * CFrame.Angles(0, 0, Util.entre(-0.04, 0.04)), LADRILLO, M.Brick)
		end
	end
	local ancho = ANCHO_BRECHA - 5
	Util.rampa(m, ancho, (cf * CFrame.new(-5, 0, 0)).Position, (cf * CFrame.new(0, 1.8, 0)).Position, Color3.new(), M.SmoothPlastic, { Transparency = 1 })
	Util.rampa(m, ancho, (cf * CFrame.new(5, 0, 0)).Position, (cf * CFrame.new(0, 1.8, 0)).Position, Color3.new(), M.SmoothPlastic, { Transparency = 1 })
	Util.elipsoide(m, V(9, 3, ancho + 2), cf * CFrame.new(0, 0.2, 0), rgb(110, 90, 75), M.Ground, DECO)
	for _ = 1, 22 do
		local x = Util.entre(-5, 5)
		local y = math.max(0.3, 1.8 * (1 - math.abs(x) / 5)) + Util.entre(-0.2, 0.4)
		local color = if Util.azar:NextNumber() < 0.75 then LADRILLO:Lerp(rgb(110, 70, 55), Util.entre(0, 1)) else PIEDRA
		Util.bloque(m, V(1.6, 0.7, 0.8), cf * CFrame.new(x, y, Util.entre(-ancho / 2, ancho / 2)) * CFrame.Angles(Util.entre(-0.5, 0.5), Util.entre(0, 3), Util.entre(-0.5, 0.5)), color, M.Brick, DECO)
	end
	Util.bola(m, 1.6, (cf * CFrame.new(3.5, 0.8, Util.entre(-3, 3))).Position, PIEDRA, M.Limestone, DECO)
	Util.bloque(m, V(0.3, 5, 3), cf * CFrame.new(1.15, 2.5, ANCHO_BRECHA / 2 - 1.5), rgb(60, 115, 55), M.LeafyGrass, DECO)
	return m
end

local function muroConBrechas(padre, a: Vector3, b: Vector3, cortes: { number })
	local dir = (b - a).Unit
	local largo = (b - a).Magnitude
	table.sort(cortes)
	local desde = 0
	for _, d in cortes do
		tramoMuro(padre, a + dir * desde, a + dir * (d - ANCHO_BRECHA / 2))
		local centro = a + dir * d
		brecha(padre, CFrame.lookAt(centro, centro + dir))
		desde = d + ANCHO_BRECHA / 2
	end
	tramoMuro(padre, a + dir * desde, a + dir * largo)
end

local function arbolCaido(padre, x: number)
	local m = Util.modelo("ArbolCaido", padre)
	local base = V(x, 1.3, -156)
	local cima = V(x + 1.5, 14.2, -181)
	local punta = V(x + 3, 1.6, -199)
	local corteza = rgb(85, 64, 48)
	local function tronco(a: Vector3, b: Vector3, diametro: number)
		Util.cilindro(m, diametro, (b - a).Magnitude, CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(0, math.pi / 2, 0), corteza, M.Wood)
		Util.rampa(m, 2.4, a + V(0, diametro / 2, 0), b + V(0, diametro / 2, 0), Color3.new(), M.SmoothPlastic, { Transparency = 1 })
	end
	tronco(base, cima, 2.6)
	tronco(cima, punta, 2.2)
	for i = 0, 6 do
		local a = i * (math.pi * 2 / 7)
		Util.barra(m, 0.6, base + V(0, 0.2, 1), base + V(math.cos(a) * 4, math.sin(a) * 3 + 1, 2.5), rgb(70, 50, 36), M.Wood, DECO)
	end
	Util.elipsoide(m, V(7, 4, 3), base + V(0, 0.5, 2.5), C.tierra, M.Ground, DECO)
	for i = 1, 5 do
		local desde = cima:Lerp(punta, 0.4 + i * 0.1)
		Util.barra(m, 0.4, desde, desde + V(Util.entre(-5, 5), Util.entre(1, 4), Util.entre(-2, 2)), corteza, M.Wood, DECO)
	end
	Util.elipsoide(m, V(9, 5, 9), punta + V(0, 2, -2), rgb(110, 95, 50), M.LeafyGrass, DECO)
	for _ = 1, 8 do
		Util.bloque(m, V(1.6, 0.7, 0.8), CFrame.new(x + Util.entre(-3, 3), Util.entre(0.3, 0.8), -180 + Util.entre(-3, 3)) * CFrame.Angles(Util.entre(-0.5, 0.5), Util.entre(0, 3), 0), LADRILLO, M.Brick, DECO)
	end
	return m
end

local function verja(padre)
	local m = Util.modelo("Verja", padre)
	for _, x in { -12.5, 12.5 } do
		Util.bloque(m, V(5, 16, 5), V(x, 8, 200), LADRILLO, M.Brick)
		Util.bloque(m, V(5.8, 1, 5.8), V(x, 16.5, 200), PIEDRA, M.Limestone)
		farolDePilar(m, V(x, 18.2, 200))
	end
	Util.bloque(m, V(20, 0.5, 0.5), V(0, 12.6, 200), C.metal, M.Metal, DECO)
	local cartel = Util.bloque(m, V(13, 2.4, 0.4), V(0, 14.4, 200), C.metal, M.Metal, DECO)
	letrero(cartel, Enum.NormalId.Front, "VILLA VELARDE", C.oro)
	letrero(cartel, Enum.NormalId.Back, "VILLA VELARDE", C.oro)

	local function hoja(nombre: string, xBisagra: number, signo: number)
		local h = Util.modelo(nombre, m)
		local cx = xBisagra + signo * 5
		Util.bloque(h, V(10, 12, 0.6), V(cx, 6.2, 200), C.metal, M.Metal, { Transparency = 1 })
		for _, y in { 0.8, 6, 11.6 } do
			Util.bloque(h, V(10, 0.35, 0.35), V(cx, y, 200), C.metal, M.Metal, DECO)
		end
		for i = 0, 12 do
			local x = xBisagra + signo * (0.3 + i * (9.4 / 12))
			Util.bloque(h, V(0.2, 11.6, 0.2), V(x, 6.2, 200), C.metal, M.Metal, DECO)
			Util.bola(h, 0.4, V(x, 12.2, 200), C.oro, M.Metal, DECO)
		end
		for _, y in { 3.4, 8.8 } do
			Util.cilindro(h, 1.6, 0.3, CFrame.new(cx, y, 200) * CFrame.Angles(0, math.pi / 2, 0), C.oro, M.Metal, DECO)
		end
		h.WorldPivot = CFrame.new(xBisagra, 6, 200)
		return h
	end
	hoja("HojaIzq", -10, 1)
	hoja("HojaDer", 10, -1)
	local cerradura = Util.bloque(m, V(1.4, 1.8, 1.2), V(0, 5, 199.2), C.oro, M.Metal)
	cerradura.Name = "Cerradura"
	Util.etiquetar(m, "Verja")

	Util.bloque(padre, V(26, 14, 10), V(0, 7, 216), Color3.new(), M.SmoothPlastic, {
		Name = "Salida",
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		Etiqueta = "Salida",
	})
	return m
end

local function cripta(padre)
	local m = Util.modelo("Cripta", padre)
	local piedra = rgb(150, 148, 142)
	local oscura = rgb(105, 104, 100)

	Util.bloque(m, V(24, 0.4, 20), V(-120, 0.2, -166), oscura, M.Slate)
	Util.bloque(m, V(24, 12, 1), V(-120, 6, -175.5), piedra, M.Granite)
	Util.bloque(m, V(1, 12, 20), V(-131.5, 6, -166), piedra, M.Granite)
	Util.bloque(m, V(1, 12, 20), V(-108.5, 6, -166), piedra, M.Granite)
	Util.bloque(m, V(9.5, 12, 1), V(-127.25, 6, -156.5), piedra, M.Granite)
	Util.bloque(m, V(9.5, 12, 1), V(-112.75, 6, -156.5), piedra, M.Granite)
	Util.bloque(m, V(5, 3.6, 1), V(-120, 10.2, -156.5), piedra, M.Granite)
	Util.bloque(m, V(26, 1, 23), V(-120, 12.5, -165.5), oscura, M.Slate)
	for _, x in { -129, -124, -116, -111 } do
		Util.cilindroV(m, 1.4, 11.2, V(x, 6, -153.5), rgb(200, 198, 190), M.Marble)
	end
	Util.bloque(m, V(26, 1, 5), V(-120, 12.1, -154), oscura, M.Slate)
	Util.fronton(m, V(-120, 12.6, -154), 26, 5, 4, piedra, M.Granite)
	Util.bloque(m, V(14, 0.4, 3), V(-120, 0.2, -153.5), oscura, M.Slate)
	local placa = Util.bloque(m, V(8, 1.4, 0.2), V(-120, 10.6, -155.9), rgb(60, 58, 55), M.Slate, DECO)
	letrero(placa, Enum.NormalId.Back, "FAMILIA VELARDE", rgb(220, 215, 200))

	Props.puerta(m, CFrame.new(-120, 4.4, -156.5), 5, 8, "Cripta", "Cripta", Config.NOCHE_CRIPTA)

	local raices = Util.modelo("Raices", m)
	for _ = 1, 7 do
		local desde = V(-123.8 + Util.entre(-0.5, 0.5), Util.entre(0, 8.5), -155.6)
		local hasta = V(-116.2 + Util.entre(-0.5, 0.5), Util.entre(0, 8.5), -155.6)
		if Util.azar:NextNumber() < 0.5 then
			desde, hasta = hasta, desde
		end
		Util.barra(raices, Util.entre(0.7, 1.2), desde, hasta, rgb(78, 56, 38), M.Wood)
	end
	for _ = 1, 10 do
		Util.bola(raices, Util.entre(0.5, 0.9), V(Util.entre(-123, -117), Util.entre(0.5, 8), -155.2), rgb(60, 105, 50), M.LeafyGrass, DECO)
	end
	Util.etiquetar(raices, "Raices")

	for _, x in { -126, -114 } do
		Util.cilindroV(m, 0.6, 3, V(x, 1.5, -150.5), C.metal, M.Metal)
		local cuenco = Util.cilindroV(m, 2, 0.6, V(x, 3.2, -150.5), C.metal, M.Metal)
		local fuego = Instance.new("Fire")
		fuego.Color = rgb(90, 255, 140)
		fuego.SecondaryColor = rgb(20, 120, 60)
		fuego.Size = 3
		fuego.Heat = 6
		fuego.Parent = cuenco
		Util.luz(cuenco, rgb(110, 255, 150), 16, 1.2)
	end

	Util.bloque(m, V(4, 2.6, 7), V(-120, 1.7, -168), C.marmol, M.Marble)
	Util.bloque(m, V(4.4, 0.5, 7.4), V(-120, 3.25, -168), C.marmol, M.Marble)
	Props.llave(padre, V(-120.6, 3.68, -166.8), "Verja")
	Props.pagina(padre, V(-119.3, 3.55, -169.2), 9)
	for _, p in { V(-124, 0.4, -164), V(-116, 0.4, -164), V(-124, 0.4, -172), V(-116, 0.4, -172) } do
		Util.cilindroV(m, 0.5, 2.4, p + V(0, 1.2, 0), rgb(240, 235, 220), M.SmoothPlastic, DECO)
		local llama = Util.bola(m, 0.35, p + V(0, 2.6, 0), rgb(255, 200, 110), M.Neon, DECO)
		Util.luz(llama, rgb(255, 180, 100), 10, 1)
	end
	for _, x in { -131, -109 } do
		for _, z in { -161, -167, -173 } do
			Util.bloque(m, V(0.2, 2, 3), V(x + (if x < -120 then 0.4 else -0.4), 6, z), rgb(90, 88, 84), M.Slate, DECO)
		end
	end
	return m
end

local function cementerio(padre)
	local m = Util.modelo("Cementerio", padre)
	Props.vallaHierro(m, V(-152, 0, -100), V(-124, 0, -100), 5)
	Props.vallaHierro(m, V(-116, 0, -100), V(-92, 0, -100), 5)
	Props.vallaHierro(m, V(-92, 0, -100), V(-92, 0, -180), 5)
	for _, x in { -125, -115 } do
		Util.bloque(m, V(1.6, 7, 1.6), V(x, 3.5, -100), rgb(120, 118, 112), M.Slate)
		Util.bola(m, 1.2, V(x, 7.6, -100), rgb(120, 118, 112), M.Slate, DECO)
	end
	local anterior = nil
	for i = 0, 8 do
		local a = math.pi * i / 8
		local p = V(-120 + math.cos(a) * 5, 7 + math.sin(a) * 3, -100)
		if anterior then
			Util.barra(m, 0.25, anterior, p, C.metal, M.Metal, DECO)
		end
		anterior = p
	end

	for _, z in { -110, -121, -132, -143 } do
		for _, x in { -145, -138, -131, -109, -102, -96 } do
			Props.lapida(m, V(x + Util.entre(-0.6, 0.6), 0, z + Util.entre(-0.6, 0.6)), Util.entre(-0.12, 0.12), Util.azar:NextNumber() < 0.35)
		end
	end
	cripta(m)
	Props.caja(m, CFrame.new(-98, 0, -172) * CFrame.Angles(0, 0.5, 0))

	local niebla = Util.bloque(m, V(56, 1, 76), V(-122, 0.8, -140), Color3.new(), M.SmoothPlastic, {
		Deco = true,
		Transparency = 1,
	})
	Util.particulas(niebla, {
		Texture = "rbxasset://textures/particles/smoke_main.dds",
		Color = ColorSequence.new(rgb(200, 205, 215)),
		Size = NumberSequence.new(7, 10),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.3, 0.86),
			NumberSequenceKeypoint.new(0.7, 0.86),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Lifetime = NumberRange.new(8, 12),
		Rate = 4,
		Speed = NumberRange.new(0.3, 0.8),
		SpreadAngle = Vector2.new(180, 10),
		RotSpeed = NumberRange.new(-10, 10),
	})
	Props.luciernagas(m, V(-122, 3, -140), V(56, 4, 76))
	for _, p in { V(-142, 3, -115), V(-100, 3, -118), V(-142, 3, -160), V(-100, 3, -150), V(-120, 3, -128) } do
		Props.marcador(p, "PuntoEnemigo")
	end
	return m
end

local function cobertizo(padre)
	local m = Util.modelo("Cobertizo", padre)
	local madera = rgb(125, 88, 58)
	local tejado = rgb(130, 62, 48)
	Util.bloque(m, V(20, 0.3, 18), V(124, 0.15, -119), rgb(100, 75, 50), M.WoodPlanks)
	Util.bloque(m, V(20, 9, 0.8), V(124, 4.5, -127.6), madera, M.WoodPlanks)
	Util.bloque(m, V(0.8, 9, 18), V(114.4, 4.5, -119), madera, M.WoodPlanks)
	Util.bloque(m, V(0.8, 9, 18), V(133.6, 4.5, -119), madera, M.WoodPlanks)
	Util.bloque(m, V(7, 9, 0.8), V(117.5, 4.5, -110.4), madera, M.WoodPlanks)
	Util.bloque(m, V(7, 9, 0.8), V(130.5, 4.5, -110.4), madera, M.WoodPlanks)
	Util.bloque(m, V(6, 1.5, 0.8), V(124, 8.25, -110.4), madera, M.WoodPlanks)
	Util.cuna(m, V(22, 4, 10), CFrame.new(124, 11, -114) * CFrame.Angles(0, math.pi, 0), tejado, M.ClayRoofTiles)
	Util.cuna(m, V(22, 4, 10), CFrame.new(124, 11, -124), tejado, M.ClayRoofTiles)
	Util.bloque(m, V(20, 0.6, 18), V(124, 9.1, -119), madera, M.WoodPlanks)

	Util.bloque(m, V(10, 0.5, 2.5), V(124, 3.5, -126), rgb(150, 110, 70), M.WoodPlanks)
	for _, x in { 119.5, 128.5 } do
		Util.bloque(m, V(0.5, 3.3, 2.3), V(x, 1.65, -126), rgb(120, 85, 55), M.Wood, DECO)
	end
	Util.bloque(m, V(0.3, 4, 0.3), V(120, 6, -127), C.tronco, M.Wood, DECO)
	Util.bloque(m, V(1, 1.2, 0.2), V(120, 3.9, -127), rgb(150, 150, 155), M.Metal, DECO)
	Util.bloque(m, V(0.3, 4.5, 0.3), V(122, 6.2, -127), C.tronco, M.Wood, DECO)
	Util.bloque(m, V(1.4, 0.3, 0.2), V(122, 8.4, -127), rgb(150, 150, 155), M.Metal, DECO)
	local lampara = Util.bola(m, 0.8, V(124, 8, -119), rgb(255, 220, 160), M.Neon, DECO)
	Util.luz(lampara, rgb(255, 196, 125), 18, 1)

	local lenera = Util.modelo("Lenera", m)
	local base = Util.bloque(lenera, V(6, 0.4, 3), V(130, 0.5, -124.5), rgb(90, 65, 45), M.WoodPlanks)
	base.Name = "Base"
	local i = 0
	for fila = 0, 2 do
		for col = 0, 3 do
			i += 1
			if i <= Config.RECURSOS.LENERA_MAXIMO then
				local leno = Util.cilindro(
					lenera,
					1,
					3,
					CFrame.new(128 + col * 1.3 + (fila % 2) * 0.6, 1.2 + fila * 0.9, -124.5) * CFrame.Angles(0, math.pi / 2, 0),
					rgb(130, 90, 55),
					M.Wood,
					DECO
				)
				leno.Name = "Leno"
			end
		end
	end
	lenera.PrimaryPart = base
	Util.etiquetar(lenera, "Lenera")

	Props.caja(m, CFrame.new(117, 0.3, -125))
	Props.caja(m, CFrame.new(117, 0.3, -114) * CFrame.Angles(0, 0.3, 0))
	for k = 0, 2 do
		Util.cilindro(m, 1.2, 4, CFrame.new(136.5, 0.6 + k * 1.05, -112 - k * 0.3) * CFrame.Angles(0, math.pi / 2, 0), rgb(120, 85, 55), M.Wood)
	end
	for _, x in { 119, 129 } do
		Util.cilindroV(m, 1.4, 1.2, V(x, 0.6, -108.5), rgb(185, 100, 70), M.Brick)
		Props.arbusto(m, V(x, 1.2, -108.5), V(1.6, 1.4, 1.6), C.hojas, Props.FLORES, 5)
	end
	Props.ramasAlrededor(V(124, 0, -119), 4, 13, 18)
	return m
end

function Exterior.construir(raiz: Instance)
	local muros = Util.carpeta("Muros", raiz)
	muroConBrechas(muros, V(-152, 0, -180), V(152, 0, -180), { 222 })
	muroConBrechas(muros, V(-152, 0, -180), V(-152, 0, 200), { 145 })
	muroConBrechas(muros, V(152, 0, -180), V(152, 0, 200), { 145 })
	muroConBrechas(muros, V(-152, 0, 200), V(-15, 0, 200), { 111 })
	tramoMuro(muros, V(15, 0, 200), V(152, 0, 200))
	verja(muros)
	arbolCaido(muros, -70)

	local exterior = Util.carpeta("Exterior", raiz)
	cementerio(exterior)
	cobertizo(exterior)

	local secos = Util.carpeta("ArbolesSecos", exterior)
	for _, p in {
		V(-40, 0, -168),
		V(-8, 0, -172),
		V(26, 0, -166),
		V(58, 0, -172),
		V(96, 0, -170),
		V(140, 0, -160),
		V(142, 0, -140),
		V(-146, 0, -170),
		V(-98, 0, -172),
	} do
		Props.arbolSeco(secos, p, true)
	end
	for _, p in { V(0, 3, -168), V(90, 3, -160), V(130, 3, -150) } do
		Props.marcador(p, "PuntoEnemigo")
	end
end

return Exterior
