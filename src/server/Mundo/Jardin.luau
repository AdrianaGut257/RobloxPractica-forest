local Util = require(script.Parent.Util)
local Props = require(script.Parent.Props)

local Jardin = {}

local M = Enum.Material
local V = Vector3.new
local rgb = Util.rgb
local DECO = Util.DECO
local C = Props.COLORES

local PALETA_ROSA = { rgb(255, 125, 175), rgb(250, 250, 244), rgb(225, 45, 70), rgb(255, 185, 210) }
local PALETA_SOL = { rgb(255, 214, 70), rgb(255, 150, 60), rgb(250, 250, 244), rgb(255, 235, 140) }
local PALETA_AZUL = { rgb(160, 95, 210), rgb(95, 145, 235), rgb(250, 250, 244), rgb(190, 160, 240) }

local function parterre(padre, centro: Vector3, radio: number, colores)
	Util.cilindroV(padre, radio * 2, 0.3, centro + V(0, 0.15, 0), C.tierra, M.Mud, DECO)
	Util.cilindroV(padre, radio * 2 + 1, 0.4, centro + V(0, 0.1, 0), rgb(220, 214, 198), M.Limestone, DECO)
	local anillo = 0
	local r = 0.8
	while r < radio - 0.3 do
		anillo += 1
		local n = math.max(3, math.floor(2 * math.pi * r / 1.1))
		local color = colores[(anillo - 1) % #colores + 1]
		for i = 1, n do
			local a = i * (2 * math.pi / n) + anillo * 0.3
			Props.flor(padre, centro + V(math.cos(a) * r, 0.3, math.sin(a) * r), color, 1.6 - anillo * 0.15)
		end
		r += 1.2
	end
	Props.flor(padre, centro + V(0, 0.3, 0), colores[1], 1.9)
end

local function fuente(padre, c: Vector3)
	local m = Util.modelo("Fuente", padre)
	local marmol = C.marmol
	local agua = rgb(110, 185, 215)
	local aguaProps = { Transparency = 0.3, Reflectance = 0.15, CanCollide = false, CanQuery = false }

	Util.cilindroV(m, 23, 0.6, c + V(0, 0.3, 0), rgb(205, 200, 190), M.Marble)
	local estanque = Util.cilindroV(m, 20.6, 0.3, c + V(0, 1.65, 0), agua, M.Glass, aguaProps)
	for i = 0, 23 do
		local a = i * (math.pi * 2 / 24)
		local cf = CFrame.new(c + V(math.cos(a) * 10.8, 1.1, math.sin(a) * 10.8)) * CFrame.Angles(0, -a, 0)
		Util.bloque(m, V(1.3, 2.2, 3), cf, marmol, M.Marble)
	end
	Util.cilindroV(m, 3, 5, c + V(0, 3.1, 0), marmol, M.Marble)
	Util.cilindroV(m, 10, 0.8, c + V(0, 5.9, 0), marmol, M.Marble)
	Util.cilindroV(m, 9, 0.2, c + V(0, 6.35, 0), agua, M.Glass, aguaProps)
	Util.cilindroV(m, 1.6, 3.6, c + V(0, 8.1, 0), marmol, M.Marble, DECO)
	Util.cilindroV(m, 5, 0.6, c + V(0, 10.2, 0), marmol, M.Marble, DECO)
	Util.cilindroV(m, 4.2, 0.15, c + V(0, 10.55, 0), agua, M.Glass, aguaProps)
	Util.bola(m, 1.4, c + V(0, 11.2, 0), marmol, M.Marble, DECO)

	local chorro = Util.bloque(m, V(0.5, 0.5, 0.5), c + V(0, 11.9, 0), agua, M.SmoothPlastic, {
		Deco = true,
		Transparency = 1,
	})
	Util.particulas(chorro, {
		Color = ColorSequence.new(rgb(200, 235, 255)),
		LightEmission = 0.2,
		Size = NumberSequence.new(0.35, 0.15),
		Transparency = NumberSequence.new(0.1, 0.6),
		Lifetime = NumberRange.new(1.1, 1.3),
		Rate = 70,
		Speed = NumberRange.new(9, 11),
		SpreadAngle = Vector2.new(16, 16),
		Acceleration = V(0, -26, 0),
		EmissionDirection = Enum.NormalId.Top,
	})
	for i = 0, 7 do
		local a = i * (math.pi / 4)
		local cascada = Util.bloque(m, V(0.4, 0.4, 0.4), c + V(math.cos(a) * 4.9, 6.1, math.sin(a) * 4.9), agua, M.SmoothPlastic, {
			Deco = true,
			Transparency = 1,
		})
		Util.particulas(cascada, {
			Color = ColorSequence.new(rgb(200, 235, 255)),
			LightEmission = 0.2,
			Size = NumberSequence.new(0.3, 0.2),
			Transparency = NumberSequence.new(0.2, 0.7),
			Lifetime = NumberRange.new(0.6, 0.7),
			Rate = 18,
			Speed = NumberRange.new(0.5, 1),
			SpreadAngle = Vector2.new(5, 5),
			Acceleration = V(0, -20, 0),
			EmissionDirection = Enum.NormalId.Bottom,
		})
	end
	local luz = Util.luz(estanque, rgb(120, 200, 255), 16, 1.2)
	luz.Enabled = false
	Util.etiquetar(luz, "LuzJardin")
	return m
end

local function glorieta(padre, c: Vector3)
	local m = Util.modelo("Glorieta", padre)
	local blanco = rgb(246, 244, 236)
	local tejado = rgb(118, 170, 150)
	Util.cilindroV(m, 22, 0.6, c + V(0, 0.3, 0), rgb(225, 220, 205), M.Limestone)
	for i = 0, 7 do
		local a = i * (math.pi / 4) + math.pi / 8
		local p = c + V(math.cos(a) * 9.6, 0, math.sin(a) * 9.6)
		Util.cilindroV(m, 0.9, 9, p + V(0, 5.1, 0), blanco, M.Wood)
		if i % 2 == 0 then
			Util.cilindroV(m, 1.4, 7, p + V(0, 4.1, 0), C.hojasOscuras, M.LeafyGrass, DECO)
			for _ = 1, 6 do
				local q = p + V(Util.entre(-0.7, 0.7), Util.entre(1.2, 7.5), Util.entre(-0.7, 0.7))
				Util.bola(m, 0.55, q, Util.elegir(Props.ROSAS), M.SmoothPlastic, DECO)
			end
		end
	end
	Util.cilindroV(m, 23, 0.7, c + V(0, 9.95, 0), blanco, M.Wood)
	local radios = { 21, 17.5, 13.5, 9 }
	for i, d in radios do
		Util.cilindroV(m, d, 1, c + V(0, 10.3 + (i - 0.5), 0), tejado, M.SmoothPlastic, DECO)
	end
	Util.elipsoide(m, V(8, 4, 8), c + V(0, 14.3, 0), tejado, M.SmoothPlastic, DECO)
	Util.bola(m, 0.9, c + V(0, 16.6, 0), C.oro, M.Metal, DECO)

	Util.cilindroV(m, 0.15, 1.6, c + V(0, 8.8, 0), C.metal, M.Metal, DECO)
	local farol = Util.bola(m, 1, c + V(0, 7.6, 0), rgb(255, 236, 200), M.SmoothPlastic, DECO)
	Util.etiquetar(farol, "BombillaJardin")
	local luz = Util.luz(farol, rgb(255, 196, 125), 18, 1.4)
	luz.Enabled = false
	Util.etiquetar(luz, "LuzJardin")

	Util.cilindroV(m, 0.5, 2.6, c + V(0, 1.9, 0), blanco, M.Wood)
	Util.cilindroV(m, 3.2, 0.25, c + V(0, 3.33, 0), blanco, M.Wood)
	Props.llave(padre, c + V(-0.6, 3.62, -0.2), "Biblioteca")
	Props.pagina(padre, c + V(0.6, 3.5, 0.4), 3)

	for _, a in { math.pi / 2, -math.pi / 2 } do
		local pos = c + V(math.cos(a) * 6.5, 0.6, math.sin(a) * 6.5)
		Props.banco(m, CFrame.lookAt(pos, c + V(0, 0.6, 0)))
	end
	return m
end

local function laberinto(padre)
	local m = Util.modelo("Laberinto", padre)
	local COLS, FILAS = 9, 9
	local X0, Z0 = -140, 111
	local ALTO = 8

	local abierto = {}
	local visitado = {}
	for gx = 0, 2 * COLS do
		abierto[gx] = {}
		for gz = 0, 2 * FILAS do
			abierto[gx][gz] = false
		end
	end
	for cx = 0, COLS - 1 do
		visitado[cx] = {}
	end

	local azar = Random.new(7)
	local pila = { { 0, 0 } }
	visitado[0][0] = true
	abierto[1][1] = true
	local DIRS = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
	while #pila > 0 do
		local actual = pila[#pila]
		local cx, cz = actual[1], actual[2]
		local vecinos = {}
		for _, d in DIRS do
			local nx, nz = cx + d[1], cz + d[2]
			if nx >= 0 and nx < COLS and nz >= 0 and nz < FILAS and not visitado[nx][nz] then
				table.insert(vecinos, { nx, nz, d })
			end
		end
		if #vecinos == 0 then
			table.remove(pila)
		else
			local v = vecinos[azar:NextInteger(1, #vecinos)]
			abierto[2 * cx + 1 + v[3][1]][2 * cz + 1 + v[3][2]] = true
			abierto[2 * v[1] + 1][2 * v[2] + 1] = true
			visitado[v[1]][v[2]] = true
			table.insert(pila, { v[1], v[2] })
		end
	end
	for gx = 7, 11 do
		for gz = 7, 11 do
			abierto[gx][gz] = true
		end
	end
	abierto[2 * COLS][7] = true
	abierto[9][0] = true

	local function inicio(g)
		return (g // 2) * 8 + (g % 2) * 2
	end
	local function tam(g)
		return if g % 2 == 0 then 2 else 6
	end

	for gz = 0, 2 * FILAS do
		local gx = 0
		while gx <= 2 * COLS do
			if not abierto[gx][gz] then
				local desde = gx
				while gx + 1 <= 2 * COLS and not abierto[gx + 1][gz] do
					gx += 1
				end
				local x1 = X0 + inicio(desde)
				local x2 = X0 + inicio(gx) + tam(gx)
				local z1 = Z0 + inicio(gz)
				local z2 = z1 + tam(gz)
				Props.seto(m, V(x2 - x1, ALTO, z2 - z1), V((x1 + x2) / 2, ALTO / 2, (z1 + z2) / 2), true)
			end
			gx += 1
		end
	end

	local centro = V(-103, 0, 148)
	Util.cilindroV(m, 10, 0.3, centro + V(0, 0.15, 0), rgb(220, 214, 198), M.Limestone)
	Props.estatua(m, centro + V(0, 0.3, -3), 0)
	Util.bloque(m, V(1.6, 3, 1.2), centro + V(0, 1.8, 2.5), C.marmol, M.Marble)
	Util.bloque(m, V(2, 0.3, 1.6), CFrame.new(centro + V(0, 3.4, 2.5)) * CFrame.Angles(math.rad(-15), 0, 0), C.marmol, M.Marble)
	Props.pagina(padre, centro + V(0, 3.75, 2.5), 6)
	Props.farol(m, centro + V(4, 0, 4), 7)
	Props.arcoRosas(m, CFrame.new(-67, 0, 140) * CFrame.Angles(0, math.pi / 2, 0), 6, 9)

	for _, p in { V(-135, 1, 116), V(-71, 1, 180), V(-135, 1, 180), V(-71, 1, 116) } do
		Props.marcador(p + V(0, 2, 0), "PuntoEnemigo")
	end
	Props.luciernagas(padre, V(-103, 5, 148), V(74, 6, 74))
	return m
end

local function pato(padre, pos: Vector3, rotY: number)
	local cf = CFrame.new(pos) * CFrame.Angles(0, rotY, 0)
	Util.elipsoide(padre, V(1, 0.8, 1.6), cf, rgb(250, 250, 245), M.SmoothPlastic, DECO)
	Util.bola(padre, 0.7, (cf * CFrame.new(0, 0.55, -0.7)).Position, rgb(250, 250, 245), M.SmoothPlastic, DECO)
	Util.bloque(padre, V(0.25, 0.15, 0.4), cf * CFrame.new(0, 0.5, -1.15), rgb(255, 160, 40), M.SmoothPlastic, DECO)
end

local function estanque(padre)
	local m = Util.modelo("Estanque", padre)
	local c = V(92, 0, 40)
	local madera = rgb(150, 105, 65)

	Util.rampa(m, 5, V(63, 0, 40), V(82, 3, 40), madera, M.WoodPlanks)
	Util.rampa(m, 5, V(82, 3, 40), V(102, 3, 40), madera, M.WoodPlanks)
	Util.rampa(m, 5, V(102, 3, 40), V(121, 0, 40), madera, M.WoodPlanks)
	for _, z in { 37.6, 42.4 } do
		local puntos = { V(63, 3, z), V(82, 6, z), V(102, 6, z), V(121, 3, z) }
		for i = 1, #puntos - 1 do
			Util.barra(m, 0.35, puntos[i], puntos[i + 1], rgb(240, 236, 225), M.Wood, DECO)
		end
		for x = 64, 120, 4 do
			local y = if x < 82 then (x - 63) / 19 * 3 elseif x > 102 then (121 - x) / 19 * 3 else 3
			Util.bloque(m, V(0.4, 3, 0.4), V(x, y + 1.5, z), rgb(240, 236, 225), M.Wood, DECO)
		end
	end
	for _, x in { 82, 102 } do
		for _, z in { 38, 42 } do
			Util.cilindroV(m, 0.8, 7, V(x, -1.5, z), madera, M.Wood, DECO)
		end
	end
	Props.farol(m, V(61, 0, 46))
	Props.farol(m, V(123, 0, 34))

	local puestos = 0
	while puestos < 20 do
		local a = Util.entre(0, math.pi * 2)
		local r = Util.entre(4, 22)
		local p = c + V(math.cos(a) * r, -0.95, math.sin(a) * r)
		if math.abs(p.Z - 40) > 4 then
			Props.nenufar(m, p, Util.entre(1.8, 3.2), Util.azar:NextNumber() < 0.4)
			puestos += 1
		end
	end
	for i = 0, 27 do
		local a = i * (math.pi * 2 / 28) + Util.entre(-0.05, 0.05)
		local p = c + V(math.cos(a) * 26.8, 0.2, math.sin(a) * 26.8)
		if math.abs(p.Z - 40) > 4 then
			Props.roca(m, p, Util.entre(1.6, 2.8))
		end
	end
	for _ = 1, 22 do
		local a = Util.entre(-1.2, -0.4)
		local r = Util.entre(21, 25)
		local p = c + V(math.cos(a) * r, 0, math.sin(a) * r)
		local alto = Util.entre(3, 4.5)
		Util.cilindroV(m, 0.2, alto + 3, p + V(0, (alto + 3) / 2 - 3, 0), rgb(90, 140, 60), M.SmoothPlastic, DECO)
		if Util.azar:NextNumber() < 0.6 then
			Util.elipsoide(m, V(0.4, 1, 0.4), p + V(0, alto - 0.3, 0), rgb(110, 75, 45), M.SmoothPlastic, DECO)
		end
	end
	pato(m, V(84, -0.6, 22), 0.4)
	pato(m, V(88, -0.6, 24), 0.9)
	pato(m, V(104, -0.6, 58), 2.5)

	Props.sauce(m, V(124, 0, 66))
	Props.cerezo(m, V(62, 0, 12))
	Props.banco(m, CFrame.lookAt(V(92, 0, 71), V(92, 0, 40)))
	Props.banco(m, CFrame.lookAt(V(66, 0, 66), V(92, 0, 40)))
	Props.luciernagas(padre, V(92, 3, 40), V(60, 5, 60))
	return m
end

local function huerto(padre)
	local m = Util.modelo("Huerto", padre)
	local esquinas = {
		{ V(64, 0, 110), V(144, 0, 110) },
		{ V(144, 0, 110), V(144, 0, 186) },
		{ V(144, 0, 186), V(64, 0, 186) },
		{ V(64, 0, 186), V(64, 0, 145) },
		{ V(64, 0, 135), V(64, 0, 110) },
	}
	for _, tramo in esquinas do
		Props.vallaMadera(m, tramo[1], tramo[2])
	end
	for _, x in { 82, 104, 126 } do
		for _, z in { 124, 148, 172 } do
			Props.manzano(m, V(x, 0, z))
		end
	end
	local e = V(93, 0, 160)
	Util.bloque(m, V(0.4, 7, 0.4), e + V(0, 3.5, 0), C.tronco, M.Wood)
	Util.bloque(m, V(5, 0.4, 0.4), e + V(0, 5.2, 0), C.tronco, M.Wood, DECO)
	Util.bloque(m, V(2.2, 2.6, 1), e + V(0, 4.6, 0), rgb(150, 60, 50), M.Fabric, DECO)
	Util.bola(m, 1.5, e + V(0, 6.6, 0), rgb(225, 200, 140), M.Fabric, DECO)
	Util.cilindroV(m, 3, 0.2, e + V(0, 7.3, 0), rgb(210, 180, 90), M.Fabric, DECO)
	Util.cilindroV(m, 1.4, 1, e + V(0, 7.8, 0), rgb(210, 180, 90), M.Fabric, DECO)
	Util.cilindro(m, 2.4, 3, CFrame.new(138, 1.2, 180) * CFrame.Angles(0, 0.3, 0), rgb(225, 195, 100), M.Fabric)
	Util.cilindro(m, 2.4, 3, CFrame.new(134, 1.2, 182) * CFrame.Angles(0, 1.2, 0), rgb(225, 195, 100), M.Fabric)
	Props.caja(m, CFrame.new(138, 0, 116) * CFrame.Angles(0, 0.4, 0))
	Props.mariposas(padre, V(104, 5, 148), V(80, 6, 76))
	Props.marcador(V(138, 3, 128), "PuntoEnemigo")
	Props.marcador(V(72, 3, 180), "PuntoEnemigo")
	return m
end

function Jardin.construir(raiz: Instance)
	local jardin = Util.carpeta("Jardin", raiz)

	local tramos = {
		{ -62, 6, PALETA_ROSA },
		{ 74, 134, PALETA_SOL },
		{ 146, 196, PALETA_AZUL },
	}
	for _, tramo in tramos do
		local z1, z2, colores = tramo[1], tramo[2], tramo[3]
		for _, x in { -9, 9 } do
			Props.bordeFlorido(jardin, CFrame.new(x, 0, (z1 + z2) / 2), z2 - z1, colores)
		end
	end
	for _, z in { -50, -26, 84, 108, 160, 184 } do
		Props.farol(jardin, V(-13, 0, z))
		Props.farol(jardin, V(13, 0, z))
	end
	for _, z in { -40, -12, 92, 118, 166, 188 } do
		Props.cerezo(jardin, V(-22, 0, z))
		Props.cerezo(jardin, V(22, 0, z))
	end
	Props.estatua(jardin, V(-17, 0, 182), 0)
	Props.estatua(jardin, V(17, 0, 182), 0)
	Props.mariposas(jardin, V(0, 4, 60), V(50, 5, 240))
	Props.luciernagas(jardin, V(0, 4, 150), V(60, 5, 90))

	for _, x in { -38, -18, 18, 38 } do
		Props.topiario(jardin, V(x, 0, -65))
	end
	for _, x in { -28, 28 } do
		Props.macizo(jardin, V(x, 0, -73), 12, 5, PALETA_ROSA)
	end

	local c = V(0, 0, 40)
	fuente(jardin, c)
	for i = 0, 23 do
		if i % 6 ~= 0 then
			local a = i * (math.pi * 2 / 24)
			local base = c + V(math.cos(a) * 15.5, 0, math.sin(a) * 15.5)
			local colores = if i % 2 == 0 then PALETA_ROSA else PALETA_AZUL
			Props.arbusto(jardin, base, V(2.8, 2.2, 2.8), C.hojasOscuras, colores, 8)
		end
	end
	for k = 0, 3 do
		local a = math.pi / 4 + k * (math.pi / 2)
		Props.banco(jardin, CFrame.lookAt(c + V(math.cos(a) * 21, 0, math.sin(a) * 21), c))
		Props.farol(jardin, c + V(math.cos(a) * 27, 0, math.sin(a) * 27))
		for _, desvio in { -0.33, 0.33 } do
			local b = k * (math.pi / 2) + desvio
			Props.topiario(jardin, c + V(math.cos(b) * 26, 0, math.sin(b) * 26), 0.8)
		end
	end
	Props.luciernagas(jardin, V(0, 3, 40), V(50, 4, 50))

	parterre(jardin, V(-32, 0, 100), 5, PALETA_ROSA)
	parterre(jardin, V(32, 0, 100), 5, PALETA_SOL)
	parterre(jardin, V(-32, 0, 172), 5, PALETA_AZUL)
	parterre(jardin, V(32, 0, 172), 5, PALETA_ROSA)
	parterre(jardin, V(-42, 0, -2), 4.5, PALETA_SOL)
	parterre(jardin, V(42, 0, -2), 4.5, PALETA_AZUL)
	for _, p in { V(-52, 0, 96), V(52, 0, 96), V(-40, 0, 22), V(40, 0, 22), V(-36, 0, 184), V(36, 0, 184), V(132, 0, 92), V(-130, 0, 92) } do
		Props.arbol(jardin, p, Util.entre(11, 14))
	end

	local g = V(-92, 0, 40)
	glorieta(jardin, g)
	for _, anillo in { { 16, 18 }, { 20.5, 24 } } do
		local r, n = anillo[1], anillo[2]
		for i = 0, n - 1 do
			local a = i * (math.pi * 2 / n)
			if math.abs(math.atan2(math.sin(a), math.cos(a))) > 0.32 then
				Props.arbusto(jardin, g + V(math.cos(a) * r, 0, math.sin(a) * r), V(2.6, 2.2, 2.6), C.hojasOscuras, Props.ROSAS, 7)
			end
		end
	end
	for _, x in { -40, -52, -64 } do
		Props.arcoRosas(jardin, CFrame.new(x, 0, 40) * CFrame.Angles(0, math.pi / 2, 0), 9, 9.5)
	end
	for _, p in { V(-62, 0, 12), V(-62, 0, 68), V(-122, 0, 12), V(-122, 0, 68) } do
		Props.cerezo(jardin, p)
	end
	Props.banco(jardin, CFrame.lookAt(g + V(-17, 0, 17), g))
	Props.banco(jardin, CFrame.lookAt(g + V(-17, 0, -17), g))
	Props.mariposas(jardin, g + V(0, 4, 0), V(46, 5, 46))
	Props.luciernagas(jardin, g + V(0, 3, 0), V(46, 5, 46))

	local coloresTulipan = {
		rgb(225, 40, 60),
		rgb(255, 125, 175),
		rgb(255, 214, 70),
		rgb(250, 250, 244),
		rgb(160, 95, 210),
		rgb(255, 150, 60),
		rgb(225, 40, 60),
		rgb(255, 125, 175),
	}
	for fila = 1, 8 do
		local z = -60 + (fila - 1) * 6
		Util.bloque(jardin, V(106, 0.3, 2), V(-85, 0.15, z), C.tierra, M.Mud, DECO)
		for x = -137, -33, 2.4 do
			Props.tulipan(jardin, V(x + Util.entre(-0.3, 0.3), 0.3, z + Util.entre(-0.4, 0.4)), coloresTulipan[fila])
		end
	end
	Props.mariposas(jardin, V(-85, 4, -38), V(106, 5, 46))
	Props.luciernagas(jardin, V(-85, 3, -38), V(106, 4, 46))
	Props.marcador(V(-120, 3, -30), "PuntoEnemigo")
	Props.marcador(V(-60, 3, -50), "PuntoEnemigo")

	for fila = 1, 8 do
		local z = -60 + (fila - 1) * 6
		for x = 32, 136, 2.6 do
			local color = rgb(150, 115, 210):Lerp(rgb(185, 150, 235), Util.entre(0, 1))
			Util.elipsoide(jardin, V(1.9, 1.5, 1.9), V(x + Util.entre(-0.3, 0.3), 0.7, z), color, M.SmoothPlastic, DECO)
		end
	end
	Props.mariposas(jardin, V(84, 4, -38), V(108, 5, 46))
	Props.luciernagas(jardin, V(84, 3, -38), V(108, 4, 46))
	Props.marcador(V(110, 3, -30), "PuntoEnemigo")
	Props.marcador(V(60, 3, -50), "PuntoEnemigo")

	laberinto(jardin)
	estanque(jardin)
	huerto(jardin)

	for z = -90, 196, 22 do
		Props.cipres(jardin, V(-147, 0, z), Util.entre(14, 18))
		if math.abs(z - 40) > 10 then
			Props.cipres(jardin, V(147, 0, z), Util.entre(14, 18))
		end
	end
	for x = -140, 140, 22 do
		if math.abs(x) > 26 then
			Props.cipres(jardin, V(x, 0, 195), Util.entre(14, 18))
		end
	end

	local function lejosDe(p: Vector3, centro: Vector3, radio: number)
		return (V(p.X, 0, p.Z) - V(centro.X, 0, centro.Z)).Magnitude > radio
	end
	local sueltas = 0
	while sueltas < 30 do
		local p = V(Util.entre(-140, 140), 0.4, Util.entre(-60, 190))
		local libre = lejosDe(p, V(92, 0, 40), 30)
			and lejosDe(p, c, 14)
			and lejosDe(p, g, 12)
			and not (p.X < -62 and p.Z > 107)
			and math.abs(p.X) > 8
		if libre then
			Props.marcador(p, "PuntoRama")
			sueltas += 1
		end
	end
	Props.marcador(V(140, 3, 20), "PuntoEnemigo")
	Props.marcador(V(-140, 3, 190), "PuntoEnemigo")
	Props.marcador(V(140, 3, 190), "PuntoEnemigo")
end

return Jardin
