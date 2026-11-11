local Util = require(script.Parent.Util)
local Props = require(script.Parent.Props)

local Bosque = {}

local M = Enum.Material
local V = Vector3.new
local rgb = Util.rgb
local DECO = Util.DECO
local C = Props.COLORES

local ARBOLES = { XMIN = -600, XMAX = 600, ZMIN = -580, ZMAX = 620 }
local NIEBLA = { XMIN = -640, XMAX = 640, ZMIN = -620, ZMAX = 660 }
local FINCA = { XMIN = -152, XMAX = 152, ZMIN = -180, ZMAX = 200 }

local L = {
	Cabana = V(-330, 0, -250),
	Torre = V(-370, 0, 60),
	Lago = V(-300, 0, 340),
	Campamento = V(330, 0, 110),
	Cueva = V(340, 0, -300),
	Capilla = V(290, 0, 420),
	Guarida = V(0, 0, -450),
}
Bosque.LUGARES = L

local CLAROS = {
	{ L.Cabana, 30 },
	{ L.Torre, 22 },
	{ L.Lago, 84 },
	{ L.Campamento, 30 },
	{ L.Cueva, 58 },
	{ L.Capilla, 34 },
	{ L.Guarida, 38 },
}

local SENDEROS = {
	{ 11, V(0, 0, 214), V(0, 0, 650) },
	{ 7, V(-162, 0, -35), V(-260, 0, -10), V(-350, 0, 40), L.Torre },
	{ 7, L.Torre, V(-360, 0, 180), V(-312, 0, 268) },
	{ 7, V(-170, 0, -45), V(-250, 0, -120), V(-305, 0, -240) },
	{ 7, V(-70, 0, -202), V(-120, 0, -300), V(-200, 0, -320), V(-305, 0, -255) },
	{ 7, V(70, 0, -190), V(40, 0, -300), V(5, 0, -415) },
	{ 7, V(-30, 0, -450), V(-150, 0, -380), V(-200, 0, -320) },
	{ 7, V(30, 0, -445), V(180, 0, -380), V(290, 0, -270), V(335, 0, -250) },
	{ 7, V(162, 0, -35), V(250, 0, 40), V(305, 0, 105) },
	{ 7, V(345, 0, 85), V(390, 0, -100), V(350, 0, -245) },
	{ 7, V(305, 0, 125), V(290, 0, 260), V(285, 0, 395) },
	{ 7, V(0, 0, 400), V(150, 0, 410), V(265, 0, 420) },
	{ 7, V(-41, 0, 210), V(-120, 0, 270), V(-236, 0, 322) },
}

local segmentos = {}
local soloTerreno = RaycastParams.new()
soloTerreno.FilterType = Enum.RaycastFilterType.Include

local function plano(v: Vector3): Vector3
	return V(v.X, 0, v.Z)
end

local function distSegmento(p: Vector3, a: Vector3, b: Vector3): number
	local ab = plano(b - a)
	local ap = plano(p - a)
	local t = math.clamp(ap:Dot(ab) / math.max(ab:Dot(ab), 0.001), 0, 1)
	return (ap - ab * t).Magnitude
end

local function distanciaFinca(p: Vector3): number
	local dx = math.max(FINCA.XMIN - p.X, p.X - FINCA.XMAX, 0)
	local dz = math.max(FINCA.ZMIN - p.Z, p.Z - FINCA.ZMAX, 0)
	return math.sqrt(dx * dx + dz * dz)
end

local function distSendero(p: Vector3): number
	local mejor = math.huge
	for _, s in segmentos do
		mejor = math.min(mejor, distSegmento(p, s.a, s.b) - s.ancho / 2)
	end
	return mejor
end

local function libre(p: Vector3, margen: number): boolean
	if p.X < ARBOLES.XMIN or p.X > ARBOLES.XMAX or p.Z < ARBOLES.ZMIN or p.Z > ARBOLES.ZMAX then
		return false
	end
	if distanciaFinca(p) < 14 + margen then
		return false
	end
	for _, claro in CLAROS do
		if (plano(p) - plano(claro[1])).Magnitude < claro[2] + margen then
			return false
		end
	end
	return distSendero(p) > 3 + margen
end

local function conSuelo(p: Vector3): Vector3
	local res = workspace:Raycast(V(p.X, 150, p.Z), V(0, -220, 0), soloTerreno)
	if res then
		return V(p.X, res.Position.Y, p.Z)
	end
	return V(p.X, 0, p.Z)
end

local function letrero(padre, pos: Vector3, mira: Vector3, texto: string)
	local m = Util.modelo("Letrero", padre)
	Util.cilindroV(m, 0.5, 6, pos + V(0, 3, 0), rgb(100, 72, 48), M.Wood)
	local tabla = Util.bloque(m, V(7, 1.8, 0.3), CFrame.lookAt(pos + V(0, 5, 0), V(mira.X, pos.Y + 5, mira.Z)), rgb(150, 110, 70), M.WoodPlanks, DECO)
	for _, cara in { Enum.NormalId.Front, Enum.NormalId.Back } do
		local gui = Instance.new("SurfaceGui")
		gui.Face = cara
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 40
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.Font = Enum.Font.Fantasy
		t.TextScaled = true
		t.Text = texto
		t.TextColor3 = rgb(45, 30, 20)
		t.Parent = gui
		gui.Parent = tabla
	end
	return m
end

local function prepararSenderos()
	for _, s in SENDEROS do
		for i = 2, #s - 1 do
			table.insert(segmentos, { a = s[i], b = s[i + 1], ancho = s[1] })
		end
	end
end

local function dibujarSenderos()
	local t = workspace.Terrain
	for _, s in segmentos do
		local a, b = plano(s.a), plano(s.b)
		local largo = (b - a).Magnitude
		local medio = (a + b) / 2
		t:FillBlock(CFrame.lookAt(medio + V(0, -2, 0), b + V(0, -2, 0)), V(s.ancho, 4, largo + s.ancho * 0.6), M.Mud)
	end
end

local function colinas()
	local t = workspace.Terrain
	local n, intentos = 0, 0
	while n < 28 and intentos < 600 do
		intentos += 1
		local r = Util.entre(28, 50)
		local p = V(Util.entre(ARBOLES.XMIN + 30, ARBOLES.XMAX - 30), 0, Util.entre(ARBOLES.ZMIN + 30, ARBOLES.ZMAX - 30))
		if libre(p, r + 12) then
			t:FillBall(V(p.X, -r * 0.72, p.Z), r, M.LeafyGrass)
			n += 1
		end
	end
end

local function pino(padre, base: Vector3, t: number)
	Util.cilindroV(padre, 1.3 * t, 9 * t, base + V(0, 4.5 * t, 0), C.troncoOscuro, M.Wood)
	local verde = rgb(28, 56, 40):Lerp(rgb(48, 82, 52), Util.azar:NextNumber())
	Util.elipsoide(padre, V(11, 9, 11) * t, base + V(0, 9 * t, 0), verde, M.LeafyGrass, DECO)
	Util.elipsoide(padre, V(8, 8, 8) * t, base + V(0, 14 * t, 0), verde, M.LeafyGrass, DECO)
	Util.elipsoide(padre, V(4, 7, 4) * t, base + V(0, 19 * t, 0), verde, M.LeafyGrass, DECO)
end

local function roble(padre, base: Vector3, t: number)
	Util.cilindroV(padre, 2.2 * t, 10 * t, base + V(0, 5 * t, 0), C.tronco:Lerp(C.troncoOscuro, 0.5), M.Wood)
	local verde = rgb(50, 88, 48):Lerp(rgb(76, 110, 56), Util.azar:NextNumber())
	Util.elipsoide(padre, V(17, 11, 17) * t, base + V(0, 13 * t, 0), verde, M.LeafyGrass, DECO)
	Util.elipsoide(padre, V(11, 8, 11) * t, base + V(Util.entre(-4, 4) * t, 17 * t, Util.entre(-4, 4) * t), verde:Lerp(rgb(95, 130, 70), 0.3), M.LeafyGrass, DECO)
end

local function abedul(padre, base: Vector3, t: number)
	Util.cilindroV(padre, 1 * t, 13 * t, base + V(0, 6.5 * t, 0), rgb(228, 224, 212), M.Wood)
	Util.elipsoide(padre, V(8, 10, 8) * t, base + V(0, 14 * t, 0), rgb(115, 148, 68):Lerp(rgb(170, 160, 70), Util.azar:NextNumber()), M.LeafyGrass, DECO)
end

local function arbusto(padre, p: Vector3)
	Util.elipsoide(padre, V(Util.entre(4, 7), Util.entre(2.5, 4), Util.entre(4, 7)), p + V(0, 1, 0), rgb(36, 70, 40):Lerp(rgb(62, 96, 50), Util.azar:NextNumber()), M.LeafyGrass, DECO)
end

local function helecho(padre, p: Vector3)
	local verde = rgb(60, 120, 55)
	for i = 0, 1 do
		Util.elipsoide(padre, V(5, 0.5, 1.6), CFrame.new(p + V(0, 0.8, 0)) * CFrame.Angles(0, i * 1.6 + Util.entre(0, 1), 0.25), verde, M.LeafyGrass, DECO)
	end
end

local function setas(padre, p: Vector3, brillan: boolean)
	local sombrero = if brillan then rgb(90, 190, 255) else rgb(190, 50, 40)
	for i = 1, 2 do
		local q = p + V(Util.entre(-1.2, 1.2), 0, Util.entre(-1.2, 1.2))
		local alto = Util.entre(0.6, 1.3)
		Util.cilindroV(padre, 0.35, alto, q + V(0, alto / 2, 0), rgb(235, 228, 210), M.SmoothPlastic, DECO)
		local cap = Util.elipsoide(padre, V(1.5, 0.6, 1.5), q + V(0, alto, 0), sombrero, M.SmoothPlastic, DECO)
		if brillan then
			Util.etiquetar(cap, "BombillaJardin")
			if i == 1 then
				local luz = Util.luz(cap, rgb(110, 200, 255), 12, 1)
				luz.Enabled = false
				Util.etiquetar(luz, "LuzJardin")
			end
		end
	end
end

local function troncoCaido(padre, p: Vector3)
	local d = Util.entre(1.4, 2.2)
	local cf = CFrame.new(p + V(0, d / 2 - 0.1, 0)) * CFrame.Angles(0, Util.entre(0, 3), 0)
	Util.cilindro(padre, d, Util.entre(8, 13), cf, rgb(90, 66, 48), M.Wood)
	Util.bloque(padre, V(3, 0.3, d * 0.8), cf * CFrame.new(Util.entre(-2, 2), d / 2, 0), rgb(70, 115, 55), M.LeafyGrass, DECO)
end

local function poblar(padre): number
	local paso = 26
	local n = 0
	for x = ARBOLES.XMIN, ARBOLES.XMAX, paso do
		for z = ARBOLES.ZMIN, ARBOLES.ZMAX, paso do
			local p = V(x + Util.entre(-10, 10), 0, z + Util.entre(-10, 10))
			if Util.azar:NextNumber() < 0.88 and libre(p, 2) then
				p = conSuelo(p)
				local r = Util.azar:NextNumber()
				if distanciaFinca(p) < 70 and r < 0.3 then
					Props.arbolSeco(padre, p, false)
				elseif r < 0.5 then
					pino(padre, p, Util.entre(1, 1.7))
				elseif r < 0.8 then
					roble(padre, p, Util.entre(0.9, 1.4))
				else
					abedul(padre, p, Util.entre(0.9, 1.3))
				end
				n += 1
				local q = V(p.X + Util.entre(-10, 10), 0, p.Z + Util.entre(-10, 10))
				if libre(q, 1) then
					q = conSuelo(q)
					local u = Util.azar:NextNumber()
					if u < 0.32 then
						arbusto(padre, q)
					elseif u < 0.42 then
						helecho(padre, q)
					elseif u < 0.49 then
						setas(padre, q, Util.azar:NextNumber() < 0.35)
					elseif u < 0.53 then
						Props.roca(padre, q + V(0, 0.6, 0), Util.entre(2.5, 5))
					elseif u < 0.56 then
						troncoCaido(padre, q)
					end
				end
			end
		end
	end
	return n
end

local function lenera(padre, cf: CFrame)
	local m = Util.modelo("Lenera", padre)
	local base = Util.bloque(m, V(3, 0.4, 6), cf * CFrame.new(0, 0.2, 0), rgb(90, 65, 45), M.WoodPlanks)
	base.Name = "Base"
	local i = 0
	for fila = 0, 2 do
		for col = 0, 3 do
			i += 1
			if i <= 10 then
				local leno = Util.cilindro(m, 1, 2.6, cf * CFrame.new(0, 0.9 + fila * 0.9, -2 + col * 1.3 + (fila % 2) * 0.6), rgb(130, 90, 55), M.Wood, DECO)
				leno.Name = "Leno"
			end
		end
	end
	m.PrimaryPart = base
	Util.etiquetar(m, "Lenera")
	return m
end

local function cabana(padre)
	local m = Util.modelo("CabanaLenador", padre)
	local cf = CFrame.new(L.Cabana) * CFrame.Angles(0, math.pi / 2, 0)
	local function en(x: number, y: number, z: number): CFrame
		return cf * CFrame.new(x, y, z)
	end
	local madera = rgb(122, 84, 54)
	local oscura = rgb(84, 58, 38)
	local tejado = rgb(110, 64, 50)

	Util.bloque(m, V(18, 1, 14), en(0, 0.5, 0), rgb(100, 72, 48), M.WoodPlanks)
	Util.bloque(m, V(18, 9, 1), en(0, 5.5, -6.5), madera, M.Wood)
	Util.bloque(m, V(1, 9, 14), en(-8.5, 5.5, 0), madera, M.Wood)
	Util.bloque(m, V(1, 9, 14), en(8.5, 5.5, 0), madera, M.Wood)
	Util.bloque(m, V(7, 9, 1), en(-5.5, 5.5, 6.5), madera, M.Wood)
	Util.bloque(m, V(7, 9, 1), en(5.5, 5.5, 6.5), madera, M.Wood)
	Util.bloque(m, V(4, 2, 1), en(0, 9, 6.5), madera, M.Wood)
	for _, x in { -8.6, 8.6 } do
		for _, z in { -6.6, 6.6 } do
			Util.cilindroV(m, 1.5, 10, en(x, 5, z).Position, oscura, M.Wood, DECO)
		end
		for y = 1.8, 9.2, 1.5 do
			Util.cilindro(m, 1, 13, en(x * 1.03, y, 0) * CFrame.Angles(0, math.pi / 2, 0), oscura, M.Wood, DECO)
		end
	end
	Util.cuna(m, V(20, 4, 8), en(0, 12, 4) * CFrame.Angles(0, math.pi, 0), tejado, M.ClayRoofTiles)
	Util.cuna(m, V(20, 4, 8), en(0, 12, -4), tejado, M.ClayRoofTiles)
	for _, x in { -8.5, 8.5 } do
		Util.cuna(m, V(1, 4, 7), en(x, 12, 3.5) * CFrame.Angles(0, math.pi, 0), madera, M.Wood)
		Util.cuna(m, V(1, 4, 7), en(x, 12, -3.5), madera, M.Wood)
	end
	Util.bloque(m, V(2.4, 9, 2.4), en(6, 11, -5), rgb(120, 115, 110), M.Cobblestone)
	for _, x in { -9.05, 9.05 } do
		Util.bloque(m, V(0.2, 2.6, 3.2), en(x, 5.5, 0), rgb(255, 210, 140), M.Glass, { Deco = true, Transparency = 0.3 })
	end
	Util.bloque(m, V(3, 2.6, 0.2), en(5.5, 5.5, 7.05), rgb(255, 210, 140), M.Glass, { Deco = true, Transparency = 0.3 })

	Util.bloque(m, V(3.5, 1.4, 7), en(-6.3, 1.7, -2.5), rgb(100, 68, 44), M.Wood)
	Util.bloque(m, V(3.2, 0.4, 5), en(-6.3, 2.6, -1.5), rgb(130, 60, 50), M.Fabric, DECO)
	Util.bloque(m, V(4, 0.3, 2.6), en(1, 4, -3.5), madera, M.WoodPlanks)
	for _, sx in { -1.7, 1.7 } do
		for _, sz in { -1, 1 } do
			Util.bloque(m, V(0.3, 2.85, 0.3), en(1 + sx, 2.45, -3.5 + sz), oscura, M.Wood, DECO)
		end
	end
	Util.bloque(m, V(1.6, 0.3, 1.6), en(1, 2.6, -0.8), oscura, M.Wood)
	Props.pagina(m, en(1.4, 4.2, -3.5).Position, 12)
	Util.bloque(m, V(2.5, 3, 2.5), en(6, 2.5, -4.8), rgb(35, 35, 38), M.Metal)
	Util.cilindroV(m, 0.6, 7, en(6, 7.5, -4.8).Position, rgb(35, 35, 38), M.Metal, DECO)
	local brasa = Util.bloque(m, V(1.6, 0.6, 0.1), en(6, 2.2, -3.5), rgb(255, 120, 40), M.Neon, DECO)
	Util.luz(brasa, rgb(255, 150, 70), 16, 1.2)
	Util.bloque(m, V(5, 0.3, 1.2), en(-2, 6.5, -5.8), oscura, M.WoodPlanks, DECO)
	for k = 0, 3 do
		Util.cilindroV(m, 0.6, 0.9, en(-3.6 + k * 1.1, 7.1, -5.8).Position, Util.elegir({ rgb(200, 60, 50), rgb(230, 180, 60), rgb(110, 160, 80) }), M.Glass, DECO)
	end
	Util.bloque(m, V(0.3, 3.6, 0.3), en(3.5, 5.5, -5.85) * CFrame.Angles(0, 0, 0.4), rgb(110, 75, 45), M.Wood, DECO)
	Util.bloque(m, V(1.4, 1, 0.2), en(4.2, 7, -5.85) * CFrame.Angles(0, 0, 0.4), rgb(150, 152, 160), M.Metal, DECO)
	Props.caja(m, en(-6, 1, 4))
	local lampara = Util.bola(m, 0.7, en(0, 8.6, 0).Position, rgb(255, 220, 160), M.Neon, DECO)
	Util.luz(lampara, rgb(255, 196, 125), 20, 1)

	lenera(m, en(11, 0, -2))
	Util.cilindroV(m, 2.4, 2, en(10, 1, 6).Position, rgb(120, 85, 55), M.Wood)
	Util.bloque(m, V(0.3, 3, 0.3), en(10.3, 2.8, 6) * CFrame.Angles(0, 0, -0.5), rgb(110, 75, 45), M.Wood, DECO)
	Util.bloque(m, V(1.2, 0.9, 0.2), en(10.1, 2.05, 6) * CFrame.Angles(0, 0, -0.5), rgb(150, 152, 160), M.Metal, DECO)
	for k = 0, 2 do
		Util.cilindro(m, 1.2, 5, en(-11.5, 0.6 + k * 1.05, -2 + k * 0.4) * CFrame.Angles(0, math.pi / 2, 0), rgb(120, 85, 55), M.Wood)
	end
	Props.caja(m, en(-11, 0, 5) * CFrame.Angles(0, 0.4, 0))
	for _, p in { en(-18, 0, -14), en(17, 0, -15), en(-16, 0, 16) } do
		Props.arbolSeco(m, p.Position, true)
	end
	Props.marcador(en(0, 3, 14).Position, "PuntoBosque")
	Props.marcador(en(-18, 3, 0).Position, "PuntoBosque")
end

local function torre(padre)
	local m = Util.modelo("TorreVigilancia", padre)
	local c = L.Torre
	local madera = rgb(115, 82, 55)
	local tablas = rgb(135, 98, 64)
	local H = 30
	for _, sx in { -5, 5 } do
		for _, sz in { -5, 5 } do
			Util.cilindroV(m, 1.4, H + 8, c + V(sx, (H + 8) / 2, sz), madera, M.Wood)
		end
	end
	for y = 4, 24, 10 do
		for _, lado in { { V(-5, 0, -5), V(5, 0, -5) }, { V(5, 0, -5), V(5, 0, 5) }, { V(5, 0, 5), V(-5, 0, 5) }, { V(-5, 0, 5), V(-5, 0, -5) } } do
			Util.barra(m, 0.5, c + lado[1] + V(0, y, 0), c + lado[2] + V(0, y + 9, 0), madera, M.Wood, DECO)
			Util.barra(m, 0.5, c + lado[2] + V(0, y, 0), c + lado[1] + V(0, y + 9, 0), madera, M.Wood, DECO)
		end
	end
	local y = H + 0.4
	Util.bloque(m, V(13, 0.8, 13), c + V(0, H, 0), tablas, M.WoodPlanks)
	local function baranda(a: Vector3, b: Vector3)
		local medio = (a + b) / 2
		local largo = (b - a).Magnitude
		local cf = CFrame.lookAt(medio, b)
		Util.bloque(m, V(0.4, 3, largo), cf * CFrame.new(0, 1.5, 0), madera, M.Wood, { Transparency = 1 })
		Util.bloque(m, V(0.4, 0.4, largo), cf * CFrame.new(0, 3, 0), madera, M.Wood, DECO)
		for k = 0, math.floor(largo / 1.5) do
			Util.bloque(m, V(0.25, 3, 0.25), cf * CFrame.new(0, 1.5, -largo / 2 + k * 1.5), madera, M.Wood, DECO)
		end
	end
	baranda(c + V(-6.3, y, -6.3), c + V(6.3, y, -6.3))
	baranda(c + V(-6.3, y, 6.3), c + V(6.3, y, 6.3))
	baranda(c + V(-6.3, y, -6.3), c + V(-6.3, y, 6.3))
	baranda(c + V(6.3, y, -6.3), c + V(6.3, y, -1.6))
	baranda(c + V(6.3, y, 1.6), c + V(6.3, y, 6.3))
	Util.parte({
		Clase = "TrussPart",
		Parent = m,
		Name = "Escalera",
		Size = V(2, H + 2, 2),
		CFrame = CFrame.new(c + V(7.5, (H + 2) / 2, 0)),
		Color = madera,
		Material = M.Wood,
	})
	Util.cuna(m, V(14, 3, 7), CFrame.new(c + V(0, H + 9.5, 3.5)) * CFrame.Angles(0, math.pi, 0), rgb(90, 64, 44), M.WoodPlanks)
	Util.cuna(m, V(14, 3, 7), CFrame.new(c + V(0, H + 9.5, -3.5)), rgb(90, 64, 44), M.WoodPlanks)
	Util.bloque(m, V(3, 0.3, 2), c + V(2.5, y + 2.6, -3.5), tablas, M.WoodPlanks)
	for _, sx in { -1.2, 1.2 } do
		Util.bloque(m, V(0.3, 2.5, 0.3), c + V(2.5 + sx, y + 1.25, -3.5), madera, M.Wood, DECO)
	end
	Props.hallazgo(m, c + V(2.5, y + 3.05, -3.5), "Planos_Ballesta")
	Props.caja(m, CFrame.new(c + V(-3.5, y, -3)))
	local farol = Util.bola(m, 0.9, c + V(0, H + 6.5, 0), rgb(255, 220, 160), M.Neon, DECO)
	Util.luz(farol, rgb(255, 196, 125), 26, 1.2)
	letrero(m, c + V(12, 0, 8), c + V(30, 0, 8), "🗼 TORRE DE VIGILANCIA")
	for k = 0, 2 do
		Util.cilindro(m, 1.2, 5, CFrame.new(c + V(-9, 0.6 + k * 1.05, 6 - k * 0.4)) * CFrame.Angles(0, math.pi / 2, 0), rgb(120, 85, 55), M.Wood)
	end
	Props.marcador(c + V(-14, 3, -10), "PuntoBosque")
end

local function lago(padre)
	local m = Util.modelo("Lago", padre)
	local t = workspace.Terrain
	local c = L.Lago
	local lobulos = { { c, 52 }, { c + V(34, 0, -26), 30 }, { c + V(-30, 0, 30), 26 } }
	for _, l in lobulos do
		t:FillCylinder(CFrame.new(l[1].X, -3, l[1].Z), 6, l[2] + 8, M.Sand)
	end
	for _, l in lobulos do
		t:FillCylinder(CFrame.new(l[1].X, -5, l[1].Z), 10, l[2], M.Air)
	end
	for _, l in lobulos do
		t:FillCylinder(CFrame.new(l[1].X, -11, l[1].Z), 2, l[2], M.Mud)
		t:FillCylinder(CFrame.new(l[1].X, -5.5, l[1].Z), 9, l[2], M.Water)
	end

	local x0 = c.X + 52
	local z = c.Z - 10
	Util.bloque(m, V(24, 0.5, 5), V(x0 - 10, 0.75, z), rgb(130, 95, 62), M.WoodPlanks)
	for x = x0 - 2, x0 - 21, -5 do
		for _, dz in { -2.2, 2.2 } do
			Util.cilindroV(m, 0.6, 12, V(x, -5, z + dz), rgb(90, 66, 46), M.Wood)
		end
	end
	local cfBarca = CFrame.new(x0 - 17, -0.7, z + 6) * CFrame.Angles(0, 0.25, 0)
	Util.bloque(m, V(3.6, 1.2, 8), cfBarca, rgb(120, 80, 50), M.WoodPlanks)
	Util.bloque(m, V(3, 0.3, 7.2), cfBarca * CFrame.new(0, 0.5, 0), rgb(80, 55, 35), M.WoodPlanks, DECO)
	Util.cuna(m, V(3.6, 1.2, 2), cfBarca * CFrame.new(0, 0, -5) * CFrame.Angles(0, math.pi, 0), rgb(120, 80, 50), M.WoodPlanks)
	for _, sx in { -1.4, 1.4 } do
		Util.barra(m, 0.25, (cfBarca * CFrame.new(sx * 0.5, 0.8, 1)).Position, (cfBarca * CFrame.new(sx * 3, 0.1, 2.5)).Position, rgb(150, 110, 70), M.Wood, DECO)
	end
	Props.caja(m, CFrame.new(x0 - 20, 1, z))
	for _ = 1, 26 do
		local a = Util.entre(0, math.pi * 2)
		local r = Util.entre(4, 44)
		Props.nenufar(m, V(c.X + math.cos(a) * r, -0.95, c.Z + math.sin(a) * r), Util.entre(2, 3.4), Util.azar:NextNumber() < 0.3)
	end
	local aEmbarcadero = math.atan2(z - c.Z, x0 - c.X) % (math.pi * 2)
	for i = 0, 17 do
		local a = i * (math.pi * 2 / 18) + Util.entre(-0.1, 0.1)
		local orilla = c + V(math.cos(a) * 55, 0, math.sin(a) * 55)
		local diferencia = math.abs((a - aEmbarcadero + math.pi) % (math.pi * 2) - math.pi)
		if diferencia > 0.35 then
			if i % 3 == 0 then
				Props.roca(m, orilla + V(0, 0.4, 0), Util.entre(2.5, 4.5))
			else
				for _ = 1, 5 do
					local alto = Util.entre(2, 4)
					Util.bloque(m, V(0.2, alto, 0.2), orilla + V(Util.entre(-1.5, 1.5), alto / 2 - 0.5, Util.entre(-1.5, 1.5)), rgb(90, 130, 60), M.Grass, DECO)
				end
			end
		end
	end
	Props.luciernagas(m, V(c.X, 3, c.Z), V(110, 5, 110))
	for _, p in { V(x0 + 6, 3, z + 14), V(c.X - 40, 3, c.Z - 62), V(c.X + 10, 3, c.Z + 66) } do
		Props.marcador(p, "PuntoBosque")
	end
end

local function tienda(padre, centro: Vector3, yaw: number, color: Color3)
	local cf = CFrame.new(centro) * CFrame.Angles(0, yaw, 0)
	local cumbre = (cf * CFrame.new(0, 4.5, 0)).Position
	for _, lado in { -1, 1 } do
		Util.rampa(padre, 7, (cf * CFrame.new(lado * 3.2, 0.1, 0)).Position, cumbre, color, M.Fabric, nil, 0.3)
	end
	Util.barra(padre, 0.25, (cf * CFrame.new(0, 4.4, -3.7)).Position, (cf * CFrame.new(0, 4.4, 3.7)).Position, rgb(90, 70, 50), M.Wood, DECO)
	Util.bloque(padre, V(1.8, 0.4, 5.5), cf * CFrame.new(0, 0.2, 0), rgb(60, 80, 120), M.Fabric, DECO)
end

local function campamento(padre)
	local m = Util.modelo("Campamento", padre)
	local c = L.Campamento
	local colores = { rgb(175, 145, 95), rgb(80, 110, 70), rgb(150, 60, 50) }
	for i = 0, 2 do
		local a = i * (math.pi * 2 / 3) + 0.5
		tienda(m, c + V(math.cos(a) * 11, 0, math.sin(a) * 11), -a, colores[i + 1])
	end
	for i = 0, 7 do
		local a = i * (math.pi / 4)
		Util.bola(m, 1, c + V(math.cos(a) * 1.8, 0.3, math.sin(a) * 1.8), rgb(120, 118, 112), M.Slate)
	end
	Util.cilindro(m, 0.6, 3, CFrame.new(c + V(0, 0.4, 0)) * CFrame.Angles(0, 0.6, 0), rgb(40, 30, 25), M.Wood, DECO)
	Util.cilindro(m, 0.6, 3, CFrame.new(c + V(0, 0.6, 0)) * CFrame.Angles(0, -0.6, 0), rgb(40, 30, 25), M.Wood, DECO)
	local fuego = Util.bloque(m, V(1, 1, 1), c + V(0, 0.8, 0), Color3.new(), M.SmoothPlastic, { Deco = true, Transparency = 1 })
	local llamas = Instance.new("Fire")
	llamas.Size = 2.5
	llamas.Heat = 4
	llamas.Color = rgb(255, 130, 40)
	llamas.SecondaryColor = rgb(255, 60, 10)
	llamas.Parent = fuego
	local humo = Instance.new("Smoke")
	humo.Color = rgb(120, 120, 125)
	humo.Opacity = 0.15
	humo.RiseVelocity = 4
	humo.Size = 2
	humo.Parent = fuego
	Util.luz(fuego, rgb(255, 150, 70), 24, 1.5)
	for i = 0, 2 do
		local a = i * (math.pi * 2 / 3) + 0.5 + math.pi / 3
		Util.cilindro(m, 1.2, 4, CFrame.new(c + V(math.cos(a) * 5.5, 0.6, math.sin(a) * 5.5)) * CFrame.Angles(0, -a + math.pi / 2, 0), rgb(110, 80, 52), M.Wood)
	end
	local aPag = 0.5 + math.pi / 3
	Props.pagina(m, c + V(math.cos(aPag) * 5.5, 1.25, math.sin(aPag) * 5.5), 11)
	Util.bloque(m, V(1.6, 2, 1), CFrame.new(c + V(-6, 1, -6)) * CFrame.Angles(0.2, 0.5, 0), rgb(90, 110, 70), M.Fabric)
	Util.cilindroV(m, 0.2, 5, c + V(7, 2.5, -7), rgb(90, 70, 50), M.Wood, DECO)
	local farol = Util.bola(m, 0.6, c + V(7, 4.6, -6.4), rgb(255, 220, 160), M.Neon, DECO)
	Util.luz(farol, rgb(255, 196, 125), 14, 0.8)
	Util.barra(m, 0.08, c + V(-16, 6, 8), c + V(-4, 6, 17), rgb(220, 210, 190), M.Fabric, DECO)
	for k = 1, 3 do
		local p = (c + V(-16, 6, 8)):Lerp(c + V(-4, 6, 17), k / 4)
		Util.bloque(m, V(1.6, 2, 0.1), CFrame.lookAt(p - V(0, 1, 0), p - V(0, 1, 0) + V(0.6, 0, -0.8)), Util.elegir(colores), M.Fabric, DECO)
	end
	Props.arbolSeco(m, c + V(-17, 0, 7), false)
	Props.arbolSeco(m, c + V(-3, 0, 18.5), false)
	for _, p in { CFrame.new(c + V(8, 0, 9)), CFrame.new(c + V(-9, 0, -2)) * CFrame.Angles(0, 0.7, 0), CFrame.new(c + V(3, 0, -12)) } do
		Props.caja(m, p)
	end
	Props.luciernagas(m, c + V(0, 3, 0), V(40, 4, 40))
	for _, p in { c + V(22, 3, 0), c + V(-22, 3, -12), c + V(0, 3, 24) } do
		Props.marcador(p, "PuntoBosque")
	end
end

local function telarana(padre, centro: Vector3, cf: CFrame, radio: number)
	local blanco = rgb(235, 235, 240)
	local extra = { Deco = true, Transparency = 0.35 }
	local puntas = {}
	for i = 0, 7 do
		local a = i * (math.pi / 4)
		local punta = (cf * CFrame.new(math.cos(a) * radio, math.sin(a) * radio, 0)).Position
		table.insert(puntas, punta)
		Util.barra(padre, 0.06, centro, punta, blanco, M.SmoothPlastic, extra)
	end
	for _, f in { 0.4, 0.75 } do
		for i = 1, 8 do
			local a = centro:Lerp(puntas[i], f)
			local b = centro:Lerp(puntas[(i % 8) + 1], f)
			Util.barra(padre, 0.05, a, b, blanco, M.SmoothPlastic, extra)
		end
	end
end

local function cueva(padre)
	local m = Util.modelo("CuevaAranas", padre)
	local t = workspace.Terrain
	local c = L.Cueva
	t:FillBall(V(c.X, -16, c.Z), 46, M.Rock)
	t:FillBall(V(c.X - 25, -10, c.Z - 15), 26, M.Rock)
	t:FillBall(V(c.X + 22, -12, c.Z - 20), 28, M.Rock)
	t:FillBall(V(c.X, 8, c.Z - 6), 17, M.Air)
	t:FillBlock(CFrame.new(c.X, -6, c.Z - 6), V(40, 12, 40), M.Ground)
	t:FillBlock(CFrame.new(c.X, 6, c.Z + 25), V(11, 12, 46), M.Air)

	local sala = c + V(0, 0, -6)
	telarana(m, c + V(0, 7, 44), CFrame.new(c + V(0, 7, 44)), 5)
	telarana(m, sala + V(-12, 9, 2), CFrame.lookAt(sala + V(-12, 9, 2), sala + V(0, 9, 2)), 5)
	telarana(m, sala + V(11, 8, -6), CFrame.lookAt(sala + V(11, 8, -6), sala + V(0, 8, -6)), 4.5)
	telarana(m, sala + V(0, 12, -13), CFrame.lookAt(sala + V(0, 12, -13), sala + V(0, 12, 0)), 6)
	for i = 1, 9 do
		local a = i * 0.7
		local p = sala + V(math.cos(a) * Util.entre(7, 12), 0, math.sin(a) * Util.entre(7, 12))
		local huevo = Util.bola(m, Util.entre(1.4, 2.4), p + V(0, 0.9, 0), rgb(230, 225, 210), M.Fabric, DECO)
		if i % 3 == 0 then
			huevo.Material = M.Neon
			huevo.Color = rgb(170, 230, 140)
			huevo.Transparency = 0.3
		end
	end
	for _ = 1, 10 do
		Util.cilindro(m, 0.3, Util.entre(1.2, 2.6), CFrame.new(sala + V(Util.entre(-9, 9), 0.2, Util.entre(-9, 9))) * CFrame.Angles(0, Util.entre(0, 3), 0), rgb(225, 215, 195), M.SmoothPlastic, DECO)
	end
	Util.bloque(m, V(1.6, 2, 1), CFrame.new(sala + V(4, 1, 5)) * CFrame.Angles(0, 0.5, 0.3), rgb(90, 110, 70), M.Fabric)
	for i = 0, 5 do
		local a = i * (math.pi / 3) + 0.3
		local p = sala + V(math.cos(a) * 13, 0, math.sin(a) * 13)
		local cap = Util.elipsoide(m, V(1.8, 0.7, 1.8), p + V(0, 1.2, 0), rgb(180, 90, 255), M.Neon, DECO)
		Util.cilindroV(m, 0.4, 1.2, p + V(0, 0.6, 0), rgb(235, 228, 210), M.SmoothPlastic, DECO)
		if i % 2 == 0 then
			Util.luz(cap, rgb(180, 110, 255), 18, 1.2)
		end
	end
	for _ = 1, 8 do
		local p = sala + V(Util.entre(-10, 10), Util.entre(15, 19), Util.entre(-10, 10))
		Util.elipsoide(m, V(1.2, Util.entre(3, 5), 1.2), p, rgb(90, 88, 92), M.Slate, DECO)
	end
	for _, p in { sala + V(-6, 0, -8), sala + V(7, 0, -5), sala + V(0, 0, -12) } do
		Props.caja(m, CFrame.new(p) * CFrame.Angles(0, Util.entre(0, 3), 0))
	end
	letrero(m, c + V(9, 0, 52), c + V(9, 0, 70), "🕷️ ¡NO ENTRAR!")
	for _, p in { sala + V(-8, 3, -6), sala + V(8, 3, 0), sala + V(0, 3, -12), c + V(-8, 3, 54), c + V(10, 3, 58) } do
		Props.marcador(p, "PuntoCueva")
	end
end

local function capilla(padre)
	local m = Util.modelo("CapillaRuinas", padre)
	local c = L.Capilla
	local piedra = rgb(150, 146, 138)
	local oscura = rgb(110, 106, 100)
	Util.bloque(m, V(20, 0.6, 32), c + V(0, 0.3, 0), oscura, M.Slate)
	for _, x in { -9.5, 9.5 } do
		for i = 0, 6 do
			local z = -14 + i * 4.67
			local h = if i % 3 == 1 then Util.entre(2, 4.5) else Util.entre(6, 12)
			Util.bloque(m, V(1.4, h, 4.7), c + V(x, 0.6 + h / 2, z), piedra, M.Cobblestone)
			if Util.azar:NextNumber() < 0.5 then
				Util.bloque(m, V(0.3, h * 0.7, 2.5), c + V(x + (if x < 0 then -0.85 else 0.85), 0.6 + h * 0.35, z), rgb(60, 115, 55), M.LeafyGrass, DECO)
			end
		end
	end
	Util.bloque(m, V(20, 14, 1.4), c + V(0, 7.6, -15.5), piedra, M.Cobblestone)
	Util.fronton(m, c + V(0, 14.6, -15.5), 20, 6, 1.4, piedra, M.Cobblestone)
	Util.cilindro(m, 4.6, 1.6, CFrame.new(c + V(0, 10, -15.5)) * CFrame.Angles(0, math.pi / 2, 0), oscura, M.Slate, DECO)
	Util.cilindro(m, 3.6, 1.7, CFrame.new(c + V(0, 10, -15.5)) * CFrame.Angles(0, math.pi / 2, 0), rgb(120, 60, 160), M.Glass, { Deco = true, Transparency = 0.3 })
	for _, x in { -7, 7 } do
		Util.cilindroV(m, 1.8, 10, c + V(x, 5.6, 15), piedra, M.Marble)
	end
	Util.cilindro(m, 1.8, 9, CFrame.new(c + V(4, 1.5, 8)) * CFrame.Angles(0, 0.7, 0), piedra, M.Marble)
	Util.barra(m, 0.8, c + V(-9, 11, -6), c + V(3, 1, -2), rgb(80, 60, 45), M.Wood, DECO)
	Util.barra(m, 0.8, c + V(9, 9, 4), c + V(-2, 1, 9), rgb(80, 60, 45), M.Wood, DECO)
	for i = 0, 3 do
		local z = -4 + i * 4
		Util.bloque(m, V(6, 0.5, 1.4), CFrame.new(c + V(-4, 1.9, z)) * CFrame.Angles(0, 0, if i == 2 then 0.3 else 0), rgb(100, 72, 48), M.WoodPlanks)
		for _, dx in { -2.5, 2.5 } do
			Util.bloque(m, V(0.4, 1.1, 1.2), c + V(-4 + dx, 1.15, z), rgb(80, 58, 40), M.Wood, DECO)
		end
	end
	Util.bloque(m, V(6, 3, 2.5), c + V(0, 2.1, -12.5), rgb(200, 196, 188), M.Marble)
	for _, x in { -2.2, -1, 1, 2.2 } do
		Util.cilindroV(m, 0.3, 0.9, c + V(x, 4.05, -13), rgb(245, 240, 225), M.SmoothPlastic, DECO)
		Util.bola(m, 0.22, c + V(x, 4.6, -13), rgb(255, 200, 110), M.Neon, DECO)
	end
	local velas = Util.bloque(m, V(0.2, 0.2, 0.2), c + V(0, 5, -12.5), Color3.new(), M.SmoothPlastic, { Deco = true, Transparency = 1 })
	Util.luz(velas, rgb(255, 180, 100), 16, 1)
	Props.pagina(m, c + V(1.4, 3.65, -12.2), 13)
	Props.lapida(m, c + V(0, 0.6, -7), 0, false)
	local perro = c + V(2.5, 0.6, -7.5)
	Util.elipsoide(m, V(1.2, 1.4, 2.2), perro + V(0, 0.8, 0), piedra, M.Marble, DECO)
	Util.bola(m, 1, perro + V(0, 1.8, -0.9), piedra, M.Marble, DECO)
	Props.caja(m, CFrame.new(c + V(-6, 0.6, -11)))
	local cb = c + V(15, 0, 6)
	for _, dz in { -2, 2 } do
		Util.cilindroV(m, 0.6, 9, cb + V(0, 4.5, dz), rgb(100, 72, 48), M.Wood)
	end
	Util.bloque(m, V(0.6, 0.6, 5), cb + V(0, 8.8, 0), rgb(100, 72, 48), M.Wood, DECO)
	Util.cilindroV(m, 2, 2.2, cb + V(0, 7.3, 0), rgb(110, 90, 50), M.Metal, DECO)
	Util.bola(m, 0.5, cb + V(0, 6, 0), rgb(60, 50, 30), M.Metal, DECO)
	for _, p in { V(-16, 0, -8), V(-17, 0, 2), V(-15, 0, 11), V(17, 0, -10), V(18, 0, -2) } do
		Props.lapida(m, c + p, Util.entre(-0.3, 0.3), Util.azar:NextNumber() < 0.5)
	end
	Props.luciernagas(m, c + V(0, 3, 0), V(40, 4, 44))
	for _, p in { c + V(0, 3, 26), c + V(-24, 3, 0), c + V(24, 3, -18) } do
		Props.marcador(p, "PuntoBosque")
	end
end

local function guarida(padre)
	local m = Util.modelo("GuaridaLobos", padre)
	local c = L.Guarida
	local rocaColor = rgb(105, 102, 100)
	for grados = 200, 340, 20 do
		local a = math.rad(grados)
		local r = Util.entre(22, 28)
		Props.roca(m, c + V(math.cos(a) * r, Util.entre(1, 3), math.sin(a) * r), Util.entre(8, 13))
	end
	for _, grados in { 50, 130 } do
		local a = math.rad(grados)
		Props.roca(m, c + V(math.cos(a) * 26, 1.5, math.sin(a) * 26), Util.entre(6, 9))
	end
	Props.roca(m, c + V(-7, 3, -19), 13)
	Props.roca(m, c + V(7, 3, -19), 13)
	Util.elipsoide(m, V(24, 6, 12), c + V(0, 10, -18), rocaColor, M.Slate)
	Util.bloque(m, V(9, 7, 0.5), c + V(0, 3.5, -23), rgb(8, 8, 10), M.SmoothPlastic, DECO)
	for _ = 1, 3 do
		local p = c + V(Util.entre(-3.5, 3.5), Util.entre(1.5, 4.5), -22.6)
		for _, dx in { -0.35, 0.35 } do
			Util.bola(m, 0.25, p + V(dx, 0, 0), rgb(255, 60, 40), M.Neon, DECO)
		end
	end
	local hueso = rgb(225, 215, 195)
	for _ = 1, 16 do
		Util.cilindro(m, 0.35, Util.entre(1.5, 3), CFrame.new(c + V(Util.entre(-12, 12), 0.2, Util.entre(-15, 8))) * CFrame.Angles(0, Util.entre(0, 3), 0), hueso, M.SmoothPlastic, DECO)
	end
	local craneo = c + V(4, 0.7, -5)
	Util.bola(m, 1.4, craneo, hueso, M.SmoothPlastic, DECO)
	for _, dx in { -0.3, 0.3 } do
		Util.bola(m, 0.35, craneo + V(dx, 0.1, -0.6), rgb(20, 20, 20), M.SmoothPlastic, DECO)
	end
	Props.caja(m, CFrame.new(c + V(9, 0, -12)) * CFrame.Angles(0, 0.6, 0))
	Props.caja(m, CFrame.new(c + V(-10, 0, -7)))
	letrero(m, c + V(10, 0, 30), c + V(10, 0, 50), "🐺 GUARIDA · ¡VUELVE ATRÁS!")
	Props.marcador(c + V(0, 3, -10), "PuntoGuarida")
	for _, p in { c + V(30, 3, 10), c + V(-30, 3, 6), c + V(0, 3, 34) } do
		Props.marcador(p, "PuntoBosque")
	end
end

local function extrasSenderos(padre)
	local secos = Util.carpeta("ArbolesSecosBosque", padre)
	local recorrido = 0
	for _, s in segmentos do
		local a, b = plano(s.a), plano(s.b)
		local largo = (b - a).Magnitude
		local dir = (b - a).Unit
		local lado = V(-dir.Z, 0, dir.X)
		local d = 20
		while d < largo do
			local p = a + dir * d
			recorrido += 1
			if recorrido % 2 == 0 then
				Props.marcador(p + lado * Util.entre(4.5, 6) * (if recorrido % 4 == 0 then 1 else -1) + V(0, 0.4, 0), "PuntoRama")
			end
			local q = p + lado * 12 * (if recorrido % 2 == 0 then 1 else -1)
			if distanciaFinca(q) > 30 then
				Props.marcador(conSuelo(q) + V(0, 3, 0), "PuntoBosque")
			end
			if recorrido % 5 == 0 then
				local r = p + lado * Util.entre(11, 15) * (if recorrido % 10 == 0 then 1 else -1)
				if libre(r, -3) then
					Props.arbolSeco(secos, conSuelo(r), true)
				end
			end
			d += 34
		end
	end

	letrero(padre, V(-168, 0, -26), V(-150, 0, -26), "🗼 Torre  ·  🏚️ Cabaña")
	letrero(padre, V(168, 0, -26), V(150, 0, -26), "⛺ Campamento  ·  🕷️ Cueva")
	letrero(padre, V(80, 0, -196), V(80, 0, -178), "🐺 Guarida de los lobos")
	letrero(padre, V(-60, 0, -208), V(-60, 0, -190), "🏚️ Cabaña del leñador")
	letrero(padre, V(-52, 0, 214), V(-52, 0, 196), "🌊 Lago")
	letrero(padre, V(9, 0, 392), V(9, 0, 374), "⛪ Capilla en ruinas")
	letrero(padre, V(9, 0, 590), V(9, 0, 572), "🌫️ No hay salida...")
end

local function linde()
	for x = -140, 140, 35 do
		Props.marcador(V(x, 3, FINCA.ZMIN - 24), "PuntoLinde")
		if math.abs(x) > 20 then
			Props.marcador(V(x, 3, FINCA.ZMAX + 24), "PuntoLinde")
		end
	end
	for z = -170, 190, 40 do
		Props.marcador(V(FINCA.XMIN - 24, 3, z), "PuntoLinde")
		Props.marcador(V(FINCA.XMAX + 24, 3, z), "PuntoLinde")
	end
end

local function niebla(padre)
	local f = Util.carpeta("Niebla", padre)
	local W = NIEBLA
	local ancho = W.XMAX - W.XMIN
	local fondo = W.ZMAX - W.ZMIN
	local cz = (W.ZMIN + W.ZMAX) / 2
	for _, p in {
		{ V(ancho + 8, 120, 4), V(0, 50, W.ZMIN) },
		{ V(ancho + 8, 120, 4), V(0, 50, W.ZMAX) },
		{ V(4, 120, fondo + 8), V(W.XMIN, 50, cz) },
		{ V(4, 120, fondo + 8), V(W.XMAX, 50, cz) },
	} do
		Util.parte({
			Parent = f,
			Name = "ParedNiebla",
			Size = p[1],
			Position = p[2],
			Transparency = 1,
			CanCollide = true,
			CanTouch = true,
			CanQuery = false,
			Etiqueta = "Niebla",
		})
	end
	local function bruma(pos: Vector3, size: Vector3)
		local b = Util.bloque(f, size, pos, Color3.new(), M.SmoothPlastic, { Deco = true, Transparency = 1 })
		Util.particulas(b, {
			Texture = "rbxasset://textures/particles/smoke_main.dds",
			Color = ColorSequence.new(rgb(200, 205, 215)),
			Size = NumberSequence.new(28, 40),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.3, 0.7),
				NumberSequenceKeypoint.new(0.7, 0.7),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Lifetime = NumberRange.new(10, 14),
			Rate = 1.2,
			Speed = NumberRange.new(0.5, 1.5),
			SpreadAngle = Vector2.new(180, 10),
		})
	end
	for x = W.XMIN + 50, W.XMAX - 50, 100 do
		bruma(V(x, 8, W.ZMIN + 16), V(100, 4, 24))
		bruma(V(x, 8, W.ZMAX - 16), V(100, 4, 24))
	end
	for z = W.ZMIN + 50, W.ZMAX - 50, 100 do
		bruma(V(W.XMIN + 16, 8, z), V(24, 4, 100))
		bruma(V(W.XMAX - 16, 8, z), V(24, 4, 100))
	end
	Props.marcador(V(0, 3, 230), "PuntoRetorno")
end

function Bosque.construir(raiz: Instance)
	soloTerreno.FilterDescendantsInstances = { workspace.Terrain }
	local carpeta = Util.carpeta("Bosque", raiz)
	prepararSenderos()

	colinas()
	dibujarSenderos()
	lago(carpeta)
	cueva(carpeta)

	local n = poblar(Util.carpeta("Arboles", carpeta))
	cabana(carpeta)
	torre(carpeta)
	campamento(carpeta)
	capilla(carpeta)
	guarida(carpeta)
	extrasSenderos(carpeta)
	linde()
	niebla(carpeta)
	print(string.format("[Bosque] %d árboles plantados", n))
end

return Bosque
