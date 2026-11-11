local Util = require(script.Parent.Util)

local Props = {}

local M = Enum.Material
local rgb = Util.rgb
local DECO = Util.DECO
local V = Vector3.new

Props.COLORES = {
	tallo = rgb(70, 130, 55),
	hojas = rgb(78, 140, 62),
	hojasOscuras = rgb(48, 100, 52),
	seto = rgb(52, 108, 56),
	tronco = rgb(105, 76, 52),
	troncoOscuro = rgb(70, 58, 50),
	cerezo = rgb(255, 183, 206),
	cerezoClaro = rgb(255, 214, 228),
	marmol = rgb(238, 236, 228),
	tierra = rgb(92, 64, 44),
	metal = rgb(42, 42, 48),
	madera = rgb(150, 105, 65),
	pergamino = rgb(238, 224, 192),
	oro = rgb(255, 202, 86),
}
local C = Props.COLORES

Props.FLORES = {
	rgb(225, 45, 70),
	rgb(255, 125, 175),
	rgb(255, 214, 70),
	rgb(250, 250, 244),
	rgb(160, 95, 210),
	rgb(255, 150, 60),
	rgb(95, 145, 235),
}
Props.ROSAS = { rgb(205, 25, 55), rgb(255, 120, 165), rgb(250, 245, 240), rgb(255, 205, 90), rgb(235, 70, 110) }

Props.marcadores = nil :: Folder?

function Props.marcador(pos: Vector3, etiqueta: string)
	return Util.parte({
		Parent = Props.marcadores,
		Name = etiqueta,
		Size = V(1, 1, 1),
		Position = pos,
		Transparency = 1,
		Deco = true,
		Etiqueta = etiqueta,
	})
end

function Props.ramasAlrededor(base: Vector3, cantidad: number, rMin: number, rMax: number)
	for _ = 1, cantidad do
		local angulo = Util.entre(0, math.pi * 2)
		local r = Util.entre(rMin, rMax)
		Props.marcador(base + V(math.cos(angulo) * r, 0.4, math.sin(angulo) * r), "PuntoRama")
	end
end

function Props.flor(padre, base: Vector3, color: Color3, alto: number?)
	local h = alto or 1.2
	Util.bloque(padre, V(0.16, h, 0.16), base + V(0, h / 2, 0), C.tallo, M.SmoothPlastic, DECO)
	Util.bola(padre, 0.7, base + V(0, h + 0.2, 0), color, M.SmoothPlastic, DECO)
end

function Props.tulipan(padre, base: Vector3, color: Color3)
	local h = Util.entre(1.1, 1.6)
	Util.bloque(padre, V(0.16, h, 0.16), base + V(0, h / 2, 0), C.tallo, M.SmoothPlastic, DECO)
	Util.elipsoide(padre, V(0.62, 0.9, 0.62), base + V(0, h + 0.3, 0), color, M.SmoothPlastic, DECO)
end

function Props.macizo(padre, centro: Vector3, ancho: number, largo: number, colores, separacion: number?)
	local s = separacion or 1.4
	Util.bloque(padre, V(ancho, 0.3, largo), centro + V(0, 0.15, 0), C.tierra, M.Mud, DECO)
	local nx = math.max(1, math.floor(ancho / s))
	local nz = math.max(1, math.floor(largo / s))
	for i = 1, nx do
		for j = 1, nz do
			local x = centro.X - ancho / 2 + (i - 0.5) * (ancho / nx) + Util.entre(-0.2, 0.2)
			local z = centro.Z - largo / 2 + (j - 0.5) * (largo / nz) + Util.entre(-0.2, 0.2)
			Props.flor(padre, V(x, centro.Y + 0.3, z), Util.elegir(colores), Util.entre(0.9, 1.5))
		end
	end
end

function Props.arbusto(padre, base: Vector3, tam: Vector3, colorHojas: Color3, coloresFlores, nFlores: number?)
	local centro = base + V(0, tam.Y * 0.42, 0)
	Util.elipsoide(padre, tam, centro, colorHojas, M.LeafyGrass, DECO)
	if coloresFlores then
		local n = nFlores or 6
		for _ = 1, n do
			local theta = Util.entre(0, math.pi * 2)
			local phi = Util.entre(0, 1.2)
			local p = centro
				+ V(
					math.sin(phi) * math.cos(theta) * tam.X / 2,
					math.cos(phi) * tam.Y / 2,
					math.sin(phi) * math.sin(theta) * tam.Z / 2
				) * 0.93
			Util.bola(padre, Util.entre(0.45, 0.65), p, Util.elegir(coloresFlores), M.SmoothPlastic, DECO)
		end
	end
end

function Props.bordeFlorido(padre, cf: CFrame, largo: number, colores)
	Util.bloque(padre, V(2.2, 1.6, largo), cf * CFrame.new(0, 0.8, 0), C.hojasOscuras, M.LeafyGrass, DECO)
	local n = math.floor(largo * 1.3)
	for _ = 1, n do
		local p = cf * CFrame.new(Util.entre(-0.9, 0.9), 1.65, Util.entre(-largo / 2 + 0.4, largo / 2 - 0.4))
		Util.bola(padre, Util.entre(0.45, 0.7), p.Position, Util.elegir(colores), M.SmoothPlastic, DECO)
	end
end

function Props.seto(padre, size: Vector3, centro: Vector3, conFlores: boolean?)
	local s = Util.bloque(padre, size, centro, C.seto, M.LeafyGrass)
	if conFlores then
		local n = math.floor(math.max(size.X, size.Z) / 6)
		for _ = 1, n do
			if Util.azar:NextNumber() < 0.5 then
				local p = centro
					+ V(
						Util.entre(-size.X / 2, size.X / 2),
						size.Y / 2 + 0.1,
						Util.entre(-size.Z / 2, size.Z / 2)
					)
				Util.bola(padre, 0.6, p, Util.elegir({ rgb(250, 250, 244), rgb(255, 170, 200) }), M.SmoothPlastic, DECO)
			end
		end
	end
	return s
end

function Props.arbol(padre, base: Vector3, alto: number?, colorHojas: Color3?)
	local h = alto or 12
	local m = Util.modelo("Arbol", padre)
	local hTronco = h * 0.55
	Util.cilindroV(m, 1.6, hTronco, base + V(0, hTronco / 2, 0), C.tronco, M.Wood)
	local copa = base + V(0, hTronco + h * 0.15, 0)
	local color = colorHojas or C.hojas
	Util.elipsoide(m, V(h * 0.75, h * 0.5, h * 0.75), copa, color, M.LeafyGrass, DECO)
	for i = 1, 4 do
		local a = i * math.pi / 2 + Util.entre(-0.4, 0.4)
		local offset = V(math.cos(a) * h * 0.25, Util.entre(-0.5, 1.5), math.sin(a) * h * 0.25)
		Util.elipsoide(m, V(h * 0.45, h * 0.35, h * 0.45), copa + offset, color:Lerp(rgb(120, 170, 70), Util.entre(0, 0.3)), M.LeafyGrass, DECO)
	end
	Props.ramasAlrededor(base, 2, 3, 6)
	return m
end

function Props.cerezo(padre, base: Vector3)
	local m = Util.modelo("Cerezo", padre)
	Util.cilindroV(m, 1.4, 7, base + V(0, 3.5, 0), rgb(92, 62, 52), M.Wood)
	for i = 1, 3 do
		local a = i * 2.1 + Util.entre(-0.3, 0.3)
		local desde = base + V(0, 5.5, 0)
		local hasta = base + V(math.cos(a) * 3.5, 8.5, math.sin(a) * 3.5)
		Util.barra(m, 0.6, desde, hasta, rgb(92, 62, 52), M.Wood, DECO)
	end
	local centro = base + V(0, 9.5, 0)
	Util.elipsoide(m, V(9, 5.5, 9), centro, C.cerezo, M.SmoothPlastic, DECO)
	for i = 1, 5 do
		local a = i * (math.pi * 2 / 5) + Util.entre(-0.3, 0.3)
		local p = centro + V(math.cos(a) * 3.6, Util.entre(-1, 1.2), math.sin(a) * 3.6)
		local color = if i % 2 == 0 then C.cerezoClaro else C.cerezo
		Util.elipsoide(m, V(5, 3.8, 5), p, color, M.SmoothPlastic, DECO)
	end
	local emisor = Util.bloque(m, V(10, 1, 10), centro - V(0, 2, 0), C.cerezo, M.SmoothPlastic, {
		Deco = true,
		Transparency = 1,
	})
	Util.particulas(emisor, {
		Color = ColorSequence.new(C.cerezo, C.cerezoClaro),
		Size = NumberSequence.new(0.28),
		Lifetime = NumberRange.new(5, 8),
		Rate = 3,
		Speed = NumberRange.new(0.5, 1.5),
		SpreadAngle = Vector2.new(180, 180),
		Acceleration = V(0.4, -1.2, 0.2),
		RotSpeed = NumberRange.new(-90, 90),
		Rotation = NumberRange.new(0, 360),
		EmissionDirection = Enum.NormalId.Bottom,
	})
	for _ = 1, 8 do
		local a = Util.entre(0, math.pi * 2)
		local r = Util.entre(1.5, 5)
		Util.bloque(
			m,
			V(0.5, 0.05, 0.5),
			CFrame.new(base + V(math.cos(a) * r, 0.05, math.sin(a) * r)) * CFrame.Angles(0, Util.entre(0, 3), 0),
			C.cerezo,
			M.SmoothPlastic,
			DECO
		)
	end
	Props.ramasAlrededor(base, 2, 3, 6)
	return m
end

function Props.cipres(padre, base: Vector3, alto: number?)
	local h = alto or 16
	local m = Util.modelo("Cipres", padre)
	Util.cilindroV(m, 0.9, 3, base + V(0, 1.5, 0), C.tronco, M.Wood)
	Util.elipsoide(m, V(3.6, h, 3.6), base + V(0, 1.5 + h / 2, 0), rgb(40, 86, 52), M.LeafyGrass, DECO)
	return m
end

function Props.sauce(padre, base: Vector3)
	local m = Util.modelo("Sauce", padre)
	Util.cilindroV(m, 2.4, 9, base + V(0, 4.5, 0), C.tronco, M.Wood)
	local copa = base + V(0, 11, 0)
	Util.elipsoide(m, V(15, 6, 15), copa, rgb(120, 165, 85), M.LeafyGrass, DECO)
	for i = 1, 16 do
		local a = i * (math.pi * 2 / 16)
		local r = Util.entre(5, 7)
		local largo = Util.entre(6, 8)
		Util.elipsoide(
			m,
			V(1.6, largo, 1.6),
			copa + V(math.cos(a) * r, -largo / 2 + 0.5, math.sin(a) * r),
			rgb(130, 175, 95):Lerp(rgb(100, 150, 70), Util.entre(0, 1)),
			M.LeafyGrass,
			DECO
		)
	end
	Props.ramasAlrededor(base, 3, 4, 8)
	return m
end

function Props.manzano(padre, base: Vector3)
	local m = Util.modelo("Manzano", padre)
	local tronco = Util.cilindroV(m, 1.4, 5, base + V(0, 2.5, 0), C.tronco, M.Wood)
	tronco.Name = "Tronco"
	local copa = base + V(0, 7, 0)
	Util.elipsoide(m, V(9, 6.5, 9), copa, rgb(82, 145, 60), M.LeafyGrass, DECO)
	Util.elipsoide(m, V(6, 4.5, 6), copa + V(1.5, 1.8, -1), rgb(95, 160, 70), M.LeafyGrass, DECO)
	for i = 1, 6 do
		local a = i * (math.pi * 2 / 6)
		local p = copa + V(math.cos(a) * 4.1, Util.entre(-1.5, 1), math.sin(a) * 4.1)
		local fruto = Util.bola(m, 0.8, p, rgb(210, 30, 40), M.SmoothPlastic, DECO)
		fruto.Name = "Fruto"
	end
	m.PrimaryPart = tronco
	Util.etiquetar(m, "Frutal")
	Props.ramasAlrededor(base, 2, 3, 6)
	return m
end

function Props.arbolSeco(padre, base: Vector3, talable: boolean?)
	local m = Util.modelo("ArbolSeco", padre)
	local alto = Util.entre(9, 13)
	local tronco = Util.cilindroV(m, 1.7, alto, base + V(0, alto / 2, 0), C.troncoOscuro, M.Wood)
	tronco.Name = "Tronco"
	for i = 1, 4 do
		local a = i * 1.6 + Util.entre(-0.4, 0.4)
		local desde = base + V(0, alto * Util.entre(0.55, 0.9), 0)
		local hasta = desde + V(math.cos(a) * Util.entre(3, 5), Util.entre(2, 4), math.sin(a) * Util.entre(3, 5))
		Util.barra(m, 0.5, desde, hasta, C.troncoOscuro, M.Wood, DECO)
	end
	m.PrimaryPart = tronco
	if talable then
		Util.etiquetar(m, "Talable")
		Props.ramasAlrededor(base, 3, 3, 7)
	end
	return m
end

function Props.farol(padre, base: Vector3, alto: number?)
	local h = alto or 9
	local m = Util.modelo("Farola", padre)
	Util.cilindroV(m, 1.3, 0.8, base + V(0, 0.4, 0), C.metal, M.Metal)
	Util.cilindroV(m, 0.45, h, base + V(0, h / 2, 0), C.metal, M.Metal)
	local cabeza = base + V(0, h + 1, 0)
	Util.bloque(m, V(1.5, 2, 1.5), cabeza, rgb(255, 240, 210), M.Glass, { Deco = true, Transparency = 0.45 })
	local bombilla = Util.bola(m, 0.9, cabeza, rgb(255, 236, 200), M.SmoothPlastic, DECO)
	Util.etiquetar(bombilla, "BombillaJardin")
	Util.bloque(m, V(1.9, 0.35, 1.9), cabeza + V(0, 1.15, 0), C.metal, M.Metal, DECO)
	Util.bola(m, 0.5, cabeza + V(0, 1.5, 0), C.metal, M.Metal, DECO)
	local luz = Util.luz(bombilla, rgb(255, 196, 125), 20, 1.6, false)
	luz.Enabled = false
	Util.etiquetar(luz, "LuzJardin")
	return m
end

function Props.banco(padre, cf: CFrame)
	local m = Util.modelo("Banco", padre)
	Util.bloque(m, V(5, 0.4, 1.6), cf * CFrame.new(0, 1.6, 0), rgb(160, 110, 70), M.WoodPlanks)
	Util.bloque(m, V(5, 1.6, 0.3), cf * CFrame.new(0, 2.8, 0.75) * CFrame.Angles(math.rad(-10), 0, 0), rgb(160, 110, 70), M.WoodPlanks, DECO)
	for _, x in { -2.2, 2.2 } do
		Util.bloque(m, V(0.3, 1.5, 1.6), cf * CFrame.new(x, 0.75, 0), C.metal, M.Metal, DECO)
		Util.bloque(m, V(0.3, 2.4, 0.3), cf * CFrame.new(x, 2.4, 0.7), C.metal, M.Metal, DECO)
	end
	return m
end

function Props.topiario(padre, base: Vector3, tam: number?)
	local t = tam or 1
	local m = Util.modelo("Topiario", padre)
	Util.cilindroV(m, 2.4 * t, 1.8 * t, base + V(0, 0.9 * t, 0), rgb(185, 100, 70), M.Brick)
	Util.cilindroV(m, 0.4 * t, 2 * t, base + V(0, 2.6 * t, 0), C.tronco, M.Wood, DECO)
	Util.bola(m, 3.4 * t, base + V(0, 4.6 * t, 0), C.seto, M.LeafyGrass, DECO)
	Util.bola(m, 1.8 * t, base + V(0, 6.8 * t, 0), C.seto, M.LeafyGrass, DECO)
	return m
end

function Props.estatua(padre, base: Vector3, rotY: number?)
	local m = Util.modelo("Estatua", padre)
	local cf = CFrame.new(base) * CFrame.Angles(0, rotY or 0, 0)
	Util.bloque(m, V(3.4, 0.6, 3.4), cf * CFrame.new(0, 0.3, 0), C.marmol, M.Marble)
	Util.bloque(m, V(2.6, 3.4, 2.6), cf * CFrame.new(0, 2.3, 0), C.marmol, M.Marble)
	Util.bloque(m, V(3.2, 0.5, 3.2), cf * CFrame.new(0, 4.2, 0), C.marmol, M.Marble)
	Util.elipsoide(m, V(2.2, 5, 2), cf * CFrame.new(0, 6.9, 0), C.marmol, M.Marble, DECO)
	Util.bola(m, 1.2, (cf * CFrame.new(0, 9.9, 0)).Position, C.marmol, M.Marble, DECO)
	Util.bloque(m, V(0.5, 2.2, 0.5), cf * CFrame.new(0.9, 8.6, 0) * CFrame.Angles(0, 0, math.rad(-35)), C.marmol, M.Marble, DECO)
	Util.elipsoide(m, V(1.1, 1.4, 1.1), cf * CFrame.new(1.4, 10, 0), C.marmol, M.Marble, DECO)
	return m
end

function Props.arcoRosas(padre, cf: CFrame, ancho: number, alto: number)
	local m = Util.modelo("ArcoRosas", padre)
	local r = ancho / 2
	local hPoste = alto - r
	for _, x in { -r, r } do
		Util.bloque(m, V(0.6, hPoste, 0.6), cf * CFrame.new(x, hPoste / 2, 0), rgb(245, 245, 240), M.Wood)
		Util.bloque(m, V(1.1, hPoste * 0.9, 1.1), cf * CFrame.new(x, hPoste * 0.45, 0), C.hojasOscuras, M.LeafyGrass, DECO)
	end
	local segmentos = 9
	local anterior = nil
	for i = 0, segmentos do
		local a = math.pi * i / segmentos
		local punto = (cf * CFrame.new(math.cos(a) * r, hPoste + math.sin(a) * r, 0)).Position
		if anterior then
			Util.barra(m, 0.5, anterior, punto, rgb(245, 245, 240), M.Wood, DECO)
			Util.barra(m, 1.1, anterior, punto, C.hojasOscuras, M.LeafyGrass, DECO)
		end
		anterior = punto
	end
	for _ = 1, 22 do
		local a = Util.entre(0, math.pi)
		local lado = Util.entre(-0.4, 0.4)
		local punto
		if Util.azar:NextNumber() < 0.6 then
			punto = cf * CFrame.new(math.cos(a) * r, hPoste + math.sin(a) * r, lado)
		else
			punto = cf * CFrame.new(if Util.azar:NextNumber() < 0.5 then -r else r, Util.entre(0.5, hPoste), lado)
		end
		Util.bola(m, Util.entre(0.5, 0.75), punto.Position, Util.elegir(Props.ROSAS), M.SmoothPlastic, DECO)
	end
	return m
end

function Props.roca(padre, pos: Vector3, tam: number)
	return Util.elipsoide(
		padre,
		V(tam * Util.entre(0.9, 1.4), tam * Util.entre(0.5, 0.8), tam * Util.entre(0.9, 1.3)),
		CFrame.new(pos) * CFrame.Angles(0, Util.entre(0, 3), 0),
		rgb(130, 128, 124):Lerp(rgb(160, 150, 135), Util.entre(0, 1)),
		M.Slate
	)
end

function Props.nenufar(padre, pos: Vector3, diametro: number, conFlor: boolean)
	Util.cilindroV(padre, diametro, 0.1, pos, rgb(70, 150, 70), M.SmoothPlastic, DECO)
	if conFlor then
		Util.elipsoide(padre, V(0.9, 0.6, 0.9), pos + V(0.3, 0.3, 0.2), Util.elegir({ rgb(255, 170, 200), rgb(250, 250, 244) }), M.SmoothPlastic, DECO)
	end
end

function Props.vallaHierro(padre, a: Vector3, b: Vector3, alto: number?)
	local h = alto or 5
	local dir = b - a
	local largo = dir.Magnitude
	local cf = CFrame.lookAt((a + b) / 2, b)
	Util.bloque(padre, V(0.4, h + 1, largo), cf * CFrame.new(0, (h + 1) / 2, 0), C.metal, M.Metal, { Transparency = 1 })
	Util.bloque(padre, V(0.25, 0.25, largo), cf * CFrame.new(0, h - 0.5, 0), C.metal, M.Metal, DECO)
	Util.bloque(padre, V(0.25, 0.25, largo), cf * CFrame.new(0, 0.6, 0), C.metal, M.Metal, DECO)
	local n = math.floor(largo / 0.9)
	for i = 0, n do
		local z = -largo / 2 + i * (largo / math.max(n, 1))
		Util.bloque(padre, V(0.18, h, 0.18), cf * CFrame.new(0, h / 2, z), C.metal, M.Metal, DECO)
		if i % 2 == 0 then
			Util.bloque(padre, V(0.3, 0.5, 0.3), cf * CFrame.new(0, h + 0.25, z) * CFrame.Angles(0, math.rad(45), 0), C.metal, M.Metal, DECO)
		end
	end
end

function Props.vallaMadera(padre, a: Vector3, b: Vector3)
	local dir = b - a
	local largo = dir.Magnitude
	local cf = CFrame.lookAt((a + b) / 2, b)
	local blanco = rgb(245, 242, 232)
	Util.bloque(padre, V(0.4, 4, largo), cf * CFrame.new(0, 2, 0), blanco, M.Wood, { Transparency = 1 })
	Util.bloque(padre, V(0.25, 0.4, largo), cf * CFrame.new(0, 2.6, 0), blanco, M.Wood, DECO)
	Util.bloque(padre, V(0.25, 0.4, largo), cf * CFrame.new(0, 1.3, 0), blanco, M.Wood, DECO)
	local n = math.max(1, math.floor(largo / 4))
	for i = 0, n do
		local z = -largo / 2 + i * (largo / n)
		Util.bloque(padre, V(0.5, 3.4, 0.5), cf * CFrame.new(0, 1.7, z), blanco, M.Wood, DECO)
	end
end

function Props.lapida(padre, base: Vector3, rotY: number, cruz: boolean)
	local cf = CFrame.new(base) * CFrame.Angles(0, rotY, Util.entre(-0.08, 0.08))
	local gris = rgb(135, 135, 130):Lerp(rgb(110, 115, 110), Util.entre(0, 1))
	if cruz then
		Util.bloque(padre, V(0.6, 4, 0.6), cf * CFrame.new(0, 2, 0), gris, M.Slate)
		Util.bloque(padre, V(2.4, 0.6, 0.6), cf * CFrame.new(0, 2.9, 0), gris, M.Slate, DECO)
	else
		Util.bloque(padre, V(2.6, 2.6, 0.6), cf * CFrame.new(0, 1.3, 0), gris, M.Slate)
		Util.cilindro(padre, 2.6, 0.6, cf * CFrame.new(0, 2.6, 0) * CFrame.Angles(0, math.pi / 2, 0), gris, M.Slate, DECO)
	end
	Util.bloque(padre, V(2.4, 0.25, 4.5), cf * CFrame.new(0, 0.12, -2.8), C.tierra, M.Mud, DECO)
end

function Props.luciernagas(padre, centro: Vector3, tam: Vector3)
	local p = Util.bloque(padre, tam, centro, Color3.new(), M.SmoothPlastic, { Deco = true, Transparency = 1 })
	p.Name = "Luciernagas"
	local e = Util.particulas(p, {
		Color = ColorSequence.new(rgb(220, 255, 120)),
		LightEmission = 1,
		LightInfluence = 0,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.2, 0.25),
			NumberSequenceKeypoint.new(0.8, 0.25),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Lifetime = NumberRange.new(4, 7),
		Rate = math.max(2, tam.X * tam.Z / 400),
		Speed = NumberRange.new(0.3, 1.2),
		SpreadAngle = Vector2.new(180, 180),
		Acceleration = V(0, 0.15, 0),
		Enabled = false,
	})
	Util.etiquetar(e, "Luciernagas")
	return p
end

function Props.mariposas(padre, centro: Vector3, tam: Vector3)
	local p = Util.bloque(padre, tam, centro, Color3.new(), M.SmoothPlastic, { Deco = true, Transparency = 1 })
	p.Name = "Mariposas"
	local e = Util.particulas(p, {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, rgb(255, 230, 90)),
			ColorSequenceKeypoint.new(0.5, rgb(255, 160, 210)),
			ColorSequenceKeypoint.new(1, rgb(150, 200, 255)),
		}),
		LightInfluence = 1,
		Size = NumberSequence.new(0.35),
		Lifetime = NumberRange.new(5, 8),
		Rate = math.max(1, tam.X * tam.Z / 900),
		Speed = NumberRange.new(1, 2.5),
		SpreadAngle = Vector2.new(180, 180),
		RotSpeed = NumberRange.new(-200, 200),
		Enabled = true,
	})
	Util.etiquetar(e, "Mariposas")
	return p
end

function Props.caja(padre, cf: CFrame)
	local m = Util.modelo("Caja", padre)
	local cuerpo = Util.bloque(m, V(2.4, 1.5, 1.6), cf * CFrame.new(0, 0.75, 0), rgb(150, 108, 68), M.WoodPlanks)
	cuerpo.Name = "Cuerpo"
	local tapa = Util.bloque(m, V(2.5, 0.3, 1.7), cf * CFrame.new(0, 1.65, 0), rgb(130, 92, 58), M.WoodPlanks, DECO)
	tapa.Name = "Tapa"
	for _, x in { -0.9, 0.9 } do
		Util.bloque(m, V(0.2, 1.55, 1.65), cf * CFrame.new(x, 0.77, 0), rgb(80, 80, 85), M.Metal, DECO)
	end
	m.PrimaryPart = cuerpo
	Util.etiquetar(m, "Caja")
	return m
end

function Props.despensa(padre, cf: CFrame)
	local m = Util.modelo("Despensa", padre)
	local cuerpo = Util.bloque(m, V(4, 6, 1.4), cf * CFrame.new(0, 3, 0.2), rgb(120, 85, 55), M.WoodPlanks)
	cuerpo.Name = "Cuerpo"
	for i = 1, 3 do
		local y = i * 1.8
		Util.bloque(m, V(3.6, 0.15, 1.2), cf * CFrame.new(0, y - 0.4, -0.55), rgb(150, 110, 70), M.WoodPlanks, DECO)
		for j = 1, 4 do
			local color = Util.elegir({ rgb(200, 60, 50), rgb(230, 180, 60), rgb(110, 160, 80), rgb(180, 120, 200) })
			Util.cilindroV(m, 0.6, 0.8, (cf * CFrame.new(-1.35 + (j - 1) * 0.9, y + 0.05, -0.6)).Position, color, M.Glass, {
				Name = "Tarro",
				Deco = true,
			})
		end
	end
	m.PrimaryPart = cuerpo
	Util.etiquetar(m, "Despensa")
	return m
end

function Props.llave(padre, pos: Vector3, id: string)
	local m = Util.modelo("Llave_" .. id, padre)
	local cf = CFrame.new(pos) * CFrame.Angles(0, Util.entre(0, 3), 0)
	local cana = Util.bloque(m, V(0.25, 0.25, 1.5), cf, C.oro, M.Metal, { CanCollide = false, CanTouch = false })
	cana.Name = "Cuerpo"
	Util.cilindro(m, 0.8, 0.2, cf * CFrame.new(0, 0, 0.95) * CFrame.Angles(0, 0, math.pi / 2), C.oro, M.Metal, DECO)
	Util.bloque(m, V(0.2, 0.25, 0.45), cf * CFrame.new(0.25, 0, -0.55), C.oro, M.Metal, DECO)
	Util.bloque(m, V(0.2, 0.25, 0.3), cf * CFrame.new(0.25, 0, -0.2), C.oro, M.Metal, DECO)
	Util.luz(cana, rgb(255, 215, 130), 7, 2)
	local brillo = Instance.new("Sparkles")
	brillo.SparkleColor = rgb(255, 225, 150)
	brillo.Parent = cana
	m.PrimaryPart = cana
	m:SetAttribute("Id", id)
	Util.etiquetar(m, "Llave")
	return m
end

function Props.pagina(padre, pos: Vector3, numero: number)
	local p = Util.bloque(
		padre,
		V(1.3, 0.06, 1.7),
		CFrame.new(pos) * CFrame.Angles(0, Util.entre(-0.6, 0.6), 0),
		C.pergamino,
		M.SmoothPlastic,
		{ CanCollide = false, CanTouch = false, Name = "Pagina_" .. numero }
	)
	Util.luz(p, rgb(255, 240, 200), 5, 1)
	p:SetAttribute("Numero", numero)
	Util.etiquetar(p, "Pagina")
	return p
end

function Props.hallazgo(padre, pos: Vector3, id: string)
	local m = Util.modelo("Hallazgo_" .. id, padre)
	local cf = CFrame.new(pos) * CFrame.Angles(0, Util.entre(0, 3), 0)
	local rollo = Util.cilindro(m, 0.5, 1.8, cf, C.pergamino, M.SmoothPlastic, { CanCollide = false, CanTouch = false })
	rollo.Name = "Cuerpo"
	Util.cilindro(m, 0.56, 0.2, cf * CFrame.new(0.4, 0, 0), rgb(150, 40, 40), M.Fabric, DECO)
	Util.bloque(m, V(1.6, 0.04, 1.2), cf * CFrame.new(0, -0.22, 0.6), rgb(200, 215, 240), M.SmoothPlastic, DECO)
	Util.luz(rollo, rgb(160, 210, 255), 8, 2)
	local brillo = Instance.new("Sparkles")
	brillo.SparkleColor = rgb(170, 220, 255)
	brillo.Parent = rollo
	m.PrimaryPart = rollo
	m:SetAttribute("Id", id)
	Util.etiquetar(m, "Hallazgo")
	return m
end

function Props.puerta(padre, cfCentro: CFrame, ancho: number, alto: number, llave: string, nombre: string, nocheMinima: number?)
	local m = Util.modelo("Puerta_" .. nombre, nil)
	local panel = Util.bloque(m, V(ancho, alto, 0.6), cfCentro, rgb(92, 58, 38), M.WoodPlanks)
	panel.Name = "Panel"
	for _, dx in { -ancho * 0.23, ancho * 0.23 } do
		for _, dy in { alto * 0.2, -alto * 0.2 } do
			Util.bloque(m, V(ancho * 0.34, alto * 0.32, 0.8), cfCentro * CFrame.new(dx, dy, 0), rgb(78, 48, 30), M.Wood, DECO)
		end
	end
	for _, dz in { -0.45, 0.45 } do
		Util.bola(m, 0.45, (cfCentro * CFrame.new(ancho * 0.36, -alto * 0.05, dz)).Position, C.oro, M.Metal, DECO)
	end
	Util.bloque(m, V(0.5, 0.8, 0.75), cfCentro * CFrame.new(ancho * 0.36, -alto * 0.05 - 0.7, 0), C.oro, M.Metal, DECO)
	m.PrimaryPart = panel
	m.WorldPivot = cfCentro * CFrame.new(-ancho / 2, 0, 0)
	m:SetAttribute("Llave", llave)
	m:SetAttribute("Nombre", nombre)
	if nocheMinima then
		m:SetAttribute("NocheMinima", nocheMinima)
	end
	Util.etiquetar(m, "PuertaCerrada")
	m.Parent = padre
	return m
end

return Props
