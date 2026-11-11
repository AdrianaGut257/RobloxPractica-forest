local Util = require(script.Parent.Util)
local Props = require(script.Parent.Props)

local Mansion = {}

local M = Enum.Material
local V = Vector3.new
local rgb = Util.rgb
local DECO = Util.DECO
local C = Props.COLORES

local X0, X1 = -60, 60
local ZB, ZF = -150, -80
local Y0 = 1
local H = 16
local Y1 = Y0 + H
local YT = Y0 + 2 * H
local Y2 = YT + 1

local WX0 = -88
local WXC = (WX0 + X0) / 2
local ZESC = -136
local WYT = Y2 + H

local PARED = rgb(236, 222, 198)
local MOLDURA = rgb(248, 245, 238)
local TEJADO = rgb(72, 76, 92)
local PIEDRA = rgb(196, 188, 172)
local MADERA_SUELO = rgb(140, 98, 62)
local MADERA = rgb(110, 72, 45)
local MARMOL = rgb(232, 228, 220)
local LIBROS = {
	rgb(140, 40, 40),
	rgb(40, 70, 120),
	rgb(50, 100, 60),
	rgb(150, 110, 50),
	rgb(90, 50, 90),
	rgb(170, 150, 110),
	rgb(60, 60, 60),
}

local function ventana(padre, eje: string, fijo: number, ab, yBase: number, grosor: number)
	local yc = yBase + ab.base + ab.alto / 2
	local cf
	if eje == "X" then
		cf = CFrame.new(ab.pos, yc, fijo)
	else
		cf = CFrame.new(fijo, yc, ab.pos) * CFrame.Angles(0, math.pi / 2, 0)
	end
	local t = grosor + 0.5
	if ab.abierta then
		local fuera = ab.fuera or 1
		for _, lado in { -1, 1 } do
			Util.bloque(padre, V(ab.ancho / 2, ab.alto, 0.2), cf * CFrame.new(lado * (ab.ancho * 0.75 + 0.5), 0, fuera * (grosor / 2 + 0.15)), rgb(70, 105, 90), M.WoodPlanks, DECO)
		end
		Util.bloque(padre, V(ab.ancho + 0.8, 0.4, t), cf * CFrame.new(0, ab.alto / 2 + 0.2, 0), MOLDURA, M.Wood, DECO)
		Util.bloque(padre, V(ab.ancho + 1.2, 0.4, t + 0.6), cf * CFrame.new(0, -ab.alto / 2 - 0.2, 0), MOLDURA, M.Wood, DECO)
		Util.bloque(padre, V(0.4, ab.alto, t), cf * CFrame.new(-ab.ancho / 2 - 0.2, 0, 0), MOLDURA, M.Wood, DECO)
		Util.bloque(padre, V(0.4, ab.alto, t), cf * CFrame.new(ab.ancho / 2 + 0.2, 0, 0), MOLDURA, M.Wood, DECO)
		return
	end
	Util.bloque(padre, V(ab.ancho, ab.alto, 0.2), cf, rgb(170, 205, 225), M.Glass, { Transparency = 0.55 })
	Util.bloque(padre, V(ab.ancho + 0.8, 0.4, t), cf * CFrame.new(0, ab.alto / 2 + 0.2, 0), MOLDURA, M.Wood, DECO)
	Util.bloque(padre, V(ab.ancho + 1.2, 0.4, t + 0.6), cf * CFrame.new(0, -ab.alto / 2 - 0.2, 0), MOLDURA, M.Wood, DECO)
	Util.bloque(padre, V(0.4, ab.alto, t), cf * CFrame.new(-ab.ancho / 2 - 0.2, 0, 0), MOLDURA, M.Wood, DECO)
	Util.bloque(padre, V(0.4, ab.alto, t), cf * CFrame.new(ab.ancho / 2 + 0.2, 0, 0), MOLDURA, M.Wood, DECO)
	Util.bloque(padre, V(0.2, ab.alto, 0.4), cf, MOLDURA, M.Wood, DECO)
	Util.bloque(padre, V(ab.ancho, 0.2, 0.4), cf * CFrame.new(0, ab.alto * 0.15, 0), MOLDURA, M.Wood, DECO)
end

local function muro(padre, eje: string, fijo: number, desde: number, hasta: number, yBase: number, alto: number, grosor: number, huecos, color: Color3?)
	local colorMuro = color or PARED
	local cortes = { desde, hasta }
	for _, h in huecos do
		table.insert(cortes, h.pos - h.ancho / 2)
		table.insert(cortes, h.pos + h.ancho / 2)
	end
	table.sort(cortes)
	local unicos = {}
	for _, c in cortes do
		if #unicos == 0 or math.abs(c - unicos[#unicos]) > 0.01 then
			table.insert(unicos, c)
		end
	end

	local function pieza(a: number, b: number, y0: number, y1: number)
		if b - a < 0.01 or y1 - y0 < 0.01 then
			return
		end
		local yc = yBase + (y0 + y1) / 2
		if eje == "X" then
			Util.bloque(padre, V(b - a, y1 - y0, grosor), V((a + b) / 2, yc, fijo), colorMuro, M.Plaster)
		else
			Util.bloque(padre, V(grosor, y1 - y0, b - a), V(fijo, yc, (a + b) / 2), colorMuro, M.Plaster)
		end
	end

	for i = 1, #unicos - 1 do
		local a, b = unicos[i], unicos[i + 1]
		if a >= desde - 0.01 and b <= hasta + 0.01 then
			local aqui = {}
			for _, h in huecos do
				if h.pos - h.ancho / 2 <= a + 0.01 and h.pos + h.ancho / 2 >= b - 0.01 then
					table.insert(aqui, h)
				end
			end
			table.sort(aqui, function(p, q)
				return p.base < q.base
			end)
			local cursor = 0
			for _, h in aqui do
				pieza(a, b, cursor, h.base)
				cursor = math.max(cursor, h.base + h.alto)
			end
			pieza(a, b, cursor, alto)
		end
	end

	for _, h in huecos do
		if h.ventana then
			ventana(padre, eje, fijo, h, yBase, grosor)
		end
	end
end

local function hVentana(pos: number, base: number, alto: number?, ancho: number?)
	return { pos = pos, base = base, alto = alto or 7, ancho = ancho or 5, ventana = true }
end
local function hPuerta(pos: number, base: number, alto: number?, ancho: number?)
	return { pos = pos, base = base, alto = alto or 11, ancho = ancho or 6 }
end
local function hHueco(pos: number, base: number, alto: number, ancho: number)
	return { pos = pos, base = base, alto = alto, ancho = ancho }
end
local function hVentanaAbierta(pos: number, base: number, alto: number, ancho: number, fuera: number)
	return { pos = pos, base = base, alto = alto, ancho = ancho, ventana = true, abierta = true, fuera = fuera }
end

local function balcon(padre, x: number, zMuro: number, ySuelo: number, fuera: number)
	local z = zMuro + fuera * 2.1
	Util.bloque(padre, V(7.5, 0.6, 3.4), V(x, ySuelo - 0.3, z), PIEDRA, M.Limestone)
	for _, sx in { -3, 3 } do
		Util.bloque(padre, V(0.6, 1.6, 0.6), V(x + sx, ySuelo - 1.4, zMuro + fuera * 1.2), PIEDRA, M.Limestone, DECO)
	end
	local zb = zMuro + fuera * 3.6
	Util.bloque(padre, V(7.5, 0.3, 0.4), V(x, ySuelo + 2.4, zb), C.metal, M.Metal, DECO)
	for k = -3.5, 3.5, 0.7 do
		Util.bloque(padre, V(0.15, 2.4, 0.15), V(x + k, ySuelo + 1.2, zb), C.metal, M.Metal, DECO)
	end
	for _, sx in { -3.65, 3.65 } do
		Util.bloque(padre, V(0.3, 2.5, 3.2), V(x + sx, ySuelo + 1.25, z), C.metal, M.Metal, { Transparency = 1 })
	end
	Util.bloque(padre, V(7.5, 2.5, 0.3), V(x, ySuelo + 1.25, zb), C.metal, M.Metal, { Transparency = 1 })
	for _, sx in { -2.6, 2.6 } do
		Util.cilindroV(padre, 1, 0.9, V(x + sx, ySuelo + 0.45, zb - fuera * 0.8), rgb(185, 100, 70), M.Brick, DECO)
		Props.arbusto(padre, V(x + sx, ySuelo + 0.9, zb - fuera * 0.8), V(1.1, 1, 1.1), C.hojas, Props.FLORES, 4)
	end
end

local function mesa(padre, centro: Vector3, ancho: number, fondo: number, alto: number, color: Color3?)
	local c = color or MADERA
	Util.bloque(padre, V(ancho, 0.4, fondo), centro + V(0, alto - 0.2, 0), c, M.Wood)
	for _, sx in { -1, 1 } do
		for _, sz in { -1, 1 } do
			Util.bloque(padre, V(0.4, alto - 0.4, 0.4), centro + V(sx * (ancho / 2 - 0.5), (alto - 0.4) / 2, sz * (fondo / 2 - 0.5)), c, M.Wood, DECO)
		end
	end
	return centro.Y + alto
end

local function silla(padre, base: Vector3, rotY: number, color: Color3?)
	local c = color or MADERA
	local cf = CFrame.new(base) * CFrame.Angles(0, rotY, 0)
	Util.bloque(padre, V(1.8, 0.3, 1.8), cf * CFrame.new(0, 1.9, 0), rgb(150, 40, 50), M.Fabric)
	Util.bloque(padre, V(1.8, 2.4, 0.3), cf * CFrame.new(0, 3.2, 0.75), c, M.Wood, DECO)
	for _, sx in { -0.7, 0.7 } do
		for _, sz in { -0.7, 0.7 } do
			Util.bloque(padre, V(0.25, 1.8, 0.25), cf * CFrame.new(sx, 0.9, sz), c, M.Wood, DECO)
		end
	end
end

local function estanteria(padre, cf: CFrame, ancho: number, alto: number)
	local madera = rgb(95, 62, 40)
	Util.bloque(padre, V(ancho, alto, 0.3), cf * CFrame.new(0, alto / 2, 0.85), madera, M.Wood)
	Util.bloque(padre, V(0.3, alto, 2), cf * CFrame.new(-ancho / 2 + 0.15, alto / 2, 0), madera, M.Wood)
	Util.bloque(padre, V(0.3, alto, 2), cf * CFrame.new(ancho / 2 - 0.15, alto / 2, 0), madera, M.Wood)
	local baldas = math.floor(alto / 2.4)
	for i = 0, baldas do
		local y = 0.2 + i * (alto - 0.4) / baldas
		Util.bloque(padre, V(ancho, 0.25, 2), cf * CFrame.new(0, y, 0), madera, M.Wood, DECO)
		if i < baldas then
			local x = -ancho / 2 + 0.4
			while x < ancho / 2 - 0.9 do
				local w = Util.entre(0.4, 0.8)
				local h = Util.entre(1.2, 1.8)
				Util.bloque(padre, V(w, h, 1.4), cf * CFrame.new(x + w / 2, y + 0.12 + h / 2, 0.1), Util.elegir(LIBROS), M.SmoothPlastic, DECO)
				x += w + 0.05
			end
		end
	end
end

local function cama(padre, cf: CFrame, ancho: number, largo: number, colorManta: Color3)
	local madera = rgb(100, 65, 42)
	Util.bloque(padre, V(ancho, 1.2, largo), cf * CFrame.new(0, 0.9, 0), madera, M.Wood)
	Util.bloque(padre, V(ancho - 0.4, 0.8, largo - 0.4), cf * CFrame.new(0, 1.9, 0), rgb(245, 242, 235), M.Fabric)
	Util.bloque(padre, V(ancho - 0.2, 0.3, largo * 0.65), cf * CFrame.new(0, 2.4, -largo * 0.15), colorManta, M.Fabric, DECO)
	Util.bloque(padre, V(ancho * 0.8, 0.6, 1.4), cf * CFrame.new(0, 2.6, largo / 2 - 1.2), rgb(250, 250, 248), M.Fabric, DECO)
	Util.bloque(padre, V(ancho, 4, 0.5), cf * CFrame.new(0, 2, largo / 2), madera, M.Wood)
	return (cf * CFrame.new(0, 2.95, largo / 2 - 1.2)).Position
end

local function sofa(padre, cf: CFrame, ancho: number, color: Color3)
	Util.bloque(padre, V(ancho, 1.4, 2.6), cf * CFrame.new(0, 1, 0), color, M.Fabric)
	Util.bloque(padre, V(ancho, 2.2, 0.8), cf * CFrame.new(0, 2.4, 1), color, M.Fabric, DECO)
	Util.bloque(padre, V(0.8, 1.2, 2.6), cf * CFrame.new(-ancho / 2 + 0.4, 2.2, 0), color, M.Fabric, DECO)
	Util.bloque(padre, V(0.8, 1.2, 2.6), cf * CFrame.new(ancho / 2 - 0.4, 2.2, 0), color, M.Fabric, DECO)
end

local function alfombra(padre, centro: Vector3, sx: number, sz: number, color: Color3, borde: Color3)
	Util.bloque(padre, V(sx, 0.06, sz), centro + V(0, 0.03, 0), borde, M.Fabric, DECO)
	Util.bloque(padre, V(sx - 1, 0.08, sz - 1), centro + V(0, 0.04, 0), color, M.Carpet, DECO)
end

local function lampara(padre, pos: Vector3, rango: number?, brillo: number?)
	Util.cilindroV(padre, 0.15, 2, pos - V(0, 1, 0), C.metal, M.Metal, DECO)
	Util.cilindroV(padre, 2.2, 0.5, pos - V(0, 2.1, 0), C.oro, M.Metal, DECO)
	local b = Util.bola(padre, 1, pos - V(0, 2.6, 0), rgb(255, 232, 185), M.Neon, DECO)
	Util.luz(b, rgb(255, 205, 150), rango or 26, brillo or 1.1)
end

local function arana(padre, pos: Vector3)
	Util.cilindroV(padre, 0.2, 5, pos - V(0, 2.5, 0), C.oro, M.Metal, DECO)
	local centro = pos - V(0, 5.5, 0)
	Util.cilindroV(padre, 6.5, 0.3, centro, C.oro, M.Metal, DECO)
	Util.cilindroV(padre, 3.5, 0.3, centro + V(0, 1.4, 0), C.oro, M.Metal, DECO)
	for i = 0, 9 do
		local a = i * (math.pi / 5)
		local p = centro + V(math.cos(a) * 3.1, 0.6, math.sin(a) * 3.1)
		Util.cilindroV(padre, 0.25, 0.8, p, rgb(245, 240, 225), M.SmoothPlastic, DECO)
		Util.bola(padre, 0.3, p + V(0, 0.55, 0), rgb(255, 210, 140), M.Neon, DECO)
	end
	local nucleo = Util.bola(padre, 1, centro - V(0, 0.6, 0), rgb(255, 225, 170), M.Neon, DECO)
	Util.luz(nucleo, rgb(255, 205, 150), 50, 1.6, true)
end

local function cuadro(padre, cf: CFrame, ancho: number, alto: number, retrato: boolean?)
	Util.bloque(padre, V(ancho + 0.6, alto + 0.6, 0.2), cf, C.oro, M.Wood, DECO)
	if retrato then
		Util.bloque(padre, V(ancho, alto, 0.25), cf * CFrame.new(0, 0, -0.03), rgb(45, 35, 30), M.SmoothPlastic, DECO)
		Util.elipsoide(padre, V(ancho * 0.75, alto * 0.35, 0.2), cf * CFrame.new(0, -alto * 0.3, -0.1), rgb(30, 30, 40), M.SmoothPlastic, DECO)
		Util.elipsoide(padre, V(ancho * 0.36, alto * 0.3, 0.2), cf * CFrame.new(0, alto * 0.12, -0.12), rgb(225, 195, 170), M.SmoothPlastic, DECO)
	else
		Util.bloque(padre, V(ancho, alto, 0.25), cf * CFrame.new(0, 0, -0.03), rgb(150, 190, 220), M.SmoothPlastic, DECO)
		Util.bloque(padre, V(ancho, alto * 0.45, 0.27), cf * CFrame.new(0, -alto * 0.275, -0.04), rgb(90, 140, 80), M.SmoothPlastic, DECO)
		Util.bola(padre, alto * 0.2, (cf * CFrame.new(ancho * 0.25, alto * 0.25, -0.05)).Position, rgb(255, 220, 120), M.SmoothPlastic, DECO)
	end
end

local function maceta(padre, base: Vector3, tam: number?)
	local t = tam or 1
	Util.cilindroV(padre, 1.6 * t, 1.6 * t, base + V(0, 0.8 * t, 0), rgb(185, 100, 70), M.Brick)
	Util.elipsoide(padre, V(2.4, 3.2, 2.4) * t, base + V(0, 2.9 * t, 0), C.hojas, M.LeafyGrass, DECO)
	Util.elipsoide(padre, V(1.6, 2.4, 1.6) * t, base + V(0.5, 4 * t, 0.3), rgb(95, 160, 75), M.LeafyGrass, DECO)
end

local function candelabro(padre, base: Vector3)
	Util.cilindroV(padre, 0.8, 0.2, base + V(0, 0.1, 0), C.oro, M.Metal, DECO)
	Util.cilindroV(padre, 0.2, 1.4, base + V(0, 0.8, 0), C.oro, M.Metal, DECO)
	Util.bloque(padre, V(1.8, 0.15, 0.15), base + V(0, 1.4, 0), C.oro, M.Metal, DECO)
	for _, x in { -0.8, 0, 0.8 } do
		local alto = if x == 0 then 1 else 0.8
		Util.cilindroV(padre, 0.22, alto, base + V(x, 1.5 + alto / 2, 0), rgb(245, 240, 225), M.SmoothPlastic, DECO)
		Util.bola(padre, 0.2, base + V(x, 1.6 + alto, 0), rgb(255, 200, 110), M.Neon, DECO)
	end
	Util.luz(Util.bloque(padre, V(0.2, 0.2, 0.2), base + V(0, 2.6, 0), Color3.new(), M.SmoothPlastic, {
		Deco = true,
		Transparency = 1,
	}), rgb(255, 190, 110), 10, 0.9)
end

local function armario(padre, cf: CFrame, ancho: number, alto: number)
	local madera = rgb(90, 58, 38)
	Util.bloque(padre, V(ancho, alto, 2), cf * CFrame.new(0, alto / 2, 0), madera, M.Wood)
	Util.bloque(padre, V(0.1, alto - 1, 0.1), cf * CFrame.new(0, alto / 2, -1.02), rgb(60, 38, 25), M.Wood, DECO)
	for _, x in { -0.4, 0.4 } do
		Util.bola(padre, 0.3, (cf * CFrame.new(x, alto / 2, -1.1)).Position, C.oro, M.Metal, DECO)
	end
	Util.bloque(padre, V(ancho + 0.4, 0.4, 2.3), cf * CFrame.new(0, alto + 0.2, 0), madera, M.Wood, DECO)
end

local function globo(padre, base: Vector3)
	Util.cilindroV(padre, 1.4, 0.3, base + V(0, 0.15, 0), MADERA, M.Wood, DECO)
	Util.cilindroV(padre, 0.25, 2.6, base + V(0, 1.4, 0), MADERA, M.Wood, DECO)
	Util.bola(padre, 2, base + V(0, 3.4, 0), rgb(70, 120, 180), M.SmoothPlastic, DECO)
	Util.elipsoide(padre, V(0.9, 1.1, 0.9), base + V(0.5, 3.7, -0.5), rgb(120, 160, 90), M.SmoothPlastic, DECO)
	Util.elipsoide(padre, V(0.8, 0.9, 0.9), base + V(-0.55, 3.2, 0.5), rgb(120, 160, 90), M.SmoothPlastic, DECO)
end

local function chimenea(padre)
	local m = Util.modelo("Chimenea", padre)
	local piedra = rgb(150, 138, 128)
	local zW = ZB + 0.5
	Util.bloque(m, V(3, 9, 4), V(-5.5, Y0 + 4.5, zW + 2), piedra, M.Cobblestone)
	Util.bloque(m, V(3, 9, 4), V(5.5, Y0 + 4.5, zW + 2), piedra, M.Cobblestone)
	Util.bloque(m, V(14, 6, 4), V(0, Y0 + 12, zW + 2), piedra, M.Cobblestone)
	Util.bloque(m, V(8, 9, 1), V(0, Y0 + 4.5, zW + 0.5), rgb(38, 32, 30), M.Slate)
	Util.bloque(m, V(17, 0.4, 7), V(0, Y0 + 0.2, zW + 3.5), rgb(120, 110, 105), M.Slate)
	Util.bloque(m, V(16, 0.6, 5), V(0, Y0 + 9.3, zW + 2.5), rgb(95, 60, 40), M.Wood)
	local alto = YT + 12 - Y1
	Util.bloque(m, V(8, alto, 3.5), V(0, Y1 + alto / 2, zW + 1.75), piedra, M.Brick)
	Util.bloque(m, V(9, 1, 4.5), V(0, YT + 12.5, zW + 1.75), rgb(110, 100, 95), M.Slate)
	Util.cilindro(m, 0.8, 4.5, CFrame.new(0, Y0 + 0.9, zW + 2.3) * CFrame.Angles(0, -0.25, 0), rgb(90, 60, 40), M.Wood, DECO)
	Util.cilindro(m, 0.8, 4.5, CFrame.new(0, Y0 + 0.9, zW + 2.9) * CFrame.Angles(0, 0.25, 0), rgb(90, 60, 40), M.Wood, DECO)
	Util.cilindro(m, 0.8, 3.5, CFrame.new(0, Y0 + 1.6, zW + 2.6), rgb(90, 60, 40), M.Wood, DECO)

	local fuego = Util.bloque(m, V(2, 1, 2), V(0, Y0 + 1.8, zW + 2.6), Color3.new(), M.SmoothPlastic, {
		Name = "Fuego",
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
	})
	local llamas = Instance.new("Fire")
	llamas.Name = "Llamas"
	llamas.Size = 7
	llamas.Heat = 12
	llamas.Color = rgb(255, 140, 40)
	llamas.SecondaryColor = rgb(255, 60, 10)
	llamas.Parent = fuego
	local luz = Util.luz(fuego, rgb(255, 150, 70), 40, 3, true)
	luz.Name = "Luz"
	local chispas = Util.particulas(fuego, {
		Name = "Chispas",
		Color = ColorSequence.new(rgb(255, 180, 80), rgb(255, 80, 20)),
		LightEmission = 1,
		Size = NumberSequence.new(0.18, 0.05),
		Lifetime = NumberRange.new(1, 2),
		Rate = 10,
		Speed = NumberRange.new(3, 6),
		SpreadAngle = Vector2.new(25, 25),
		Acceleration = V(0, 2, 0),
		EmissionDirection = Enum.NormalId.Top,
	})
	chispas.Name = "Chispas"

	local caja = V(-10.5, Y0, -146)
	Util.bloque(m, V(3, 1.6, 3), caja + V(0, 0.8, 0), rgb(110, 75, 50), M.WoodPlanks)
	for k = 0, 2 do
		Util.cilindro(m, 0.7, 2.6, CFrame.new(caja + V(-0.8 + k * 0.8, 1.9, 0)) * CFrame.Angles(0, math.pi / 2, 0), rgb(130, 90, 55), M.Wood, DECO)
	end
	Util.etiquetar(m, "Chimenea")
	return m
end

local function mesaDeTrabajo(padre, centro: Vector3)
	local m = Util.modelo("MesaDeTrabajo", padre)
	local sup = Util.bloque(m, V(6, 0.6, 3), centro + V(0, 3.7, 0), rgb(160, 115, 70), M.WoodPlanks)
	sup.Name = "Superficie"
	for _, sx in { -2.6, 2.6 } do
		for _, sz in { -1.1, 1.1 } do
			Util.bloque(m, V(0.5, 3.4, 0.5), centro + V(sx, 1.7, sz), rgb(120, 85, 55), M.Wood)
		end
	end
	Util.bloque(m, V(5.6, 0.3, 2.6), centro + V(0, 1, 0), rgb(120, 85, 55), M.WoodPlanks, DECO)
	Util.bloque(m, V(1, 1, 1.2), centro + V(-2.2, 4.5, -0.6), rgb(90, 90, 100), M.Metal, DECO)
	Util.bloque(m, V(2.4, 0.1, 0.8), centro + V(0.4, 4.05, 0.4), rgb(180, 180, 190), M.Metal, DECO)
	Util.bloque(m, V(0.9, 0.4, 0.3), centro + V(1.8, 4.2, 0.4), MADERA, M.Wood, DECO)
	Util.bloque(m, V(0.3, 0.3, 1.6), centro + V(1.4, 4.15, -0.7), MADERA, M.Wood, DECO)
	Util.bloque(m, V(0.9, 0.5, 0.5), centro + V(1.4, 4.25, -1.4), rgb(90, 90, 100), M.Metal, DECO)
	for k = 0, 2 do
		Util.bloque(m, V(4.5, 0.25, 0.8), centro + V(0, 1.3 + k * 0.26, -0.5 + k * 0.1), rgb(185, 140, 90), M.WoodPlanks, DECO)
	end
	m.PrimaryPart = sup
	Util.etiquetar(m, "Taller")
	return m
end

local function estructura(padre)
	local G = 1
	Util.bloque(padre, V(40, 1, 70), V(0, 0.5, -115), MARMOL, M.Marble)
	Util.bloque(padre, V(40, 1, 70), V(-40, 0.5, -115), MADERA_SUELO, M.WoodPlanks)
	Util.bloque(padre, V(40, 1, 35), V(40, 0.5, -97.5), MADERA_SUELO, M.WoodPlanks)
	Util.bloque(padre, V(40, 1, 35), V(40, 0.5, -132.5), rgb(222, 216, 204), M.CeramicTiles)
	Util.bloque(padre, V(40, 1, 70), V(-40, H + 0.5, -115), MADERA_SUELO, M.WoodPlanks)
	Util.bloque(padre, V(40, 1, 70), V(40, H + 0.5, -115), MADERA_SUELO, M.WoodPlanks)
	Util.bloque(padre, V(40, 1, 10), V(0, H + 0.5, -145), MADERA_SUELO, M.WoodPlanks)
	Util.bloque(padre, V(122, 1, 72), V(0, YT + 0.5, -115), MOLDURA, M.Plaster)

	local alto = 2 * H
	muro(padre, "X", ZF, X0 - 0.5, X1 + 0.5, Y0, alto, G, {
		hPuerta(0, 0, 12, 10),
		hVentana(-50, 4),
		hVentana(-32, 4),
		hVentana(32, 4),
		hVentana(50, 4),
		hVentana(-13, 3, 8, 4),
		hVentana(13, 3, 8, 4),
		hVentana(-50, H + 4),
		hVentana(-32, H + 4),
		hVentana(32, H + 4),
		hVentana(50, H + 4),
		hVentana(-11, H + 2, 10, 4),
		hVentana(0, H + 2, 10, 4),
		hVentana(11, H + 2, 10, 4),
	})
	muro(padre, "X", ZB, X0 - 0.5, X1 + 0.5, Y0, alto, G, {
		hVentana(-48, 4),
		hVentana(-32, 4),
		hVentana(32, 4),
		hVentana(48, 4),
		hVentanaAbierta(-48, H + 2, 9, 5, -1),
		hVentanaAbierta(-32, H + 2, 9, 5, -1),
		hVentanaAbierta(32, H + 2, 9, 5, -1),
		hVentanaAbierta(48, H + 2, 9, 5, -1),
		hVentana(-15, H + 4, 8, 4),
		hVentana(15, H + 4, 8, 4),
	})
	muro(padre, "Z", X0, ZB, ZF, Y0, alto, G, {
		hPuerta(-98, 0, 11, 6),
		hPuerta(-130, H, 11, 5),
	})
	for _, x in { -48, -32, 32, 48 } do
		balcon(padre, x, ZB - 0.5, Y0 + H + 2, -1)
	end
	muro(padre, "Z", X1, ZB, ZF, Y0, alto, G, {
		hPuerta(-125, 0),
		hVentana(-100, 4),
		hVentana(-140, 4),
		hVentana(-132, H + 4),
		hVentana(-98, H + 4),
	})

	muro(padre, "Z", -20, ZB, ZF, Y0, alto, G, { hPuerta(-92, 0), hPuerta(-145, H, 11, 5) })
	muro(padre, "Z", 20, ZB, ZF, Y0, alto, G, { hPuerta(-92, 0), hPuerta(-145, H, 11, 5) })
	muro(padre, "X", -115, X0, -20, Y0, alto, G, { hPuerta(-40, 0), hPuerta(-40, H) })
	muro(padre, "X", -115, 20, X1, Y0, alto, G, { hPuerta(40, 0), hPuerta(40, H) })

	local cumbre = YT + 15
	Util.rampa(padre, 122, V(1, YT + 1, ZF + 2), V(1, cumbre, -115), TEJADO, M.RoofShingles, nil, 1)
	Util.rampa(padre, 122, V(1, YT + 1, ZB - 2), V(1, cumbre, -115), TEJADO, M.RoofShingles, nil, 1)
	Util.bloque(padre, V(122, 0.8, 1.8), V(1, cumbre + 0.1, -115), rgb(60, 62, 75), M.Slate, DECO)
	Util.cuna(padre, V(1, 14, 37), CFrame.new(X1 + 1, YT + 8, -96.5) * CFrame.Angles(0, math.pi, 0), PARED, M.Plaster)
	Util.cuna(padre, V(1, 14, 37), CFrame.new(X1 + 1, YT + 8, -133.5), PARED, M.Plaster)
	Util.cilindro(padre, 4, 0.4, CFrame.new(X1 + 1.6, YT + 7, -115), MOLDURA, M.Wood, DECO)
	Util.cilindro(padre, 3.2, 0.5, CFrame.new(X1 + 1.6, YT + 7, -115), rgb(170, 205, 225), M.Glass, { Deco = true, Transparency = 0.4 })
	for _, x in { -40, 40 } do
		Util.bloque(padre, V(4, 13, 4), V(x, YT + 7.5, -133), rgb(150, 92, 72), M.Brick)
		Util.bloque(padre, V(4.8, 0.8, 4.8), V(x, YT + 14.4, -133), PIEDRA, M.Limestone)
	end

	for _, y in { Y1, YT } do
		Util.bloque(padre, V(121.6, 0.6, 0.6), V(0, y, ZF + 0.8), MOLDURA, M.Plaster, DECO)
		Util.bloque(padre, V(121.6, 0.6, 0.6), V(0, y, ZB - 0.8), MOLDURA, M.Plaster, DECO)
		Util.bloque(padre, V(0.6, 0.6, 71.6), V(X0 - 0.8, y, -115), MOLDURA, M.Plaster, DECO)
		Util.bloque(padre, V(0.6, 0.6, 71.6), V(X1 + 0.8, y, -115), MOLDURA, M.Plaster, DECO)
	end
	Util.bloque(padre, V(122, 1.6, 0.6), V(0, 0.8, ZF + 0.8), PIEDRA, M.Limestone, DECO)
	Util.bloque(padre, V(122, 1.6, 0.6), V(0, 0.8, ZB - 0.8), PIEDRA, M.Limestone, DECO)
	Util.bloque(padre, V(0.6, 1.6, 71.6), V(X0 - 0.8, 0.8, -115), PIEDRA, M.Limestone, DECO)
	Util.bloque(padre, V(0.6, 1.6, 71.6), V(X1 + 0.8, 0.8, -115), PIEDRA, M.Limestone, DECO)
end

local function fachada(padre)
	Util.bloque(padre, V(28, 1, 10), V(0, 0.5, -75), PIEDRA, M.Limestone)
	Util.bloque(padre, V(24, 0.5, 2), V(0, 0.25, -69), PIEDRA, M.Limestone)
	for _, x in { -12, -6, 6, 12 } do
		Util.cilindroV(padre, 1.6, 12, V(x, Y0 + 6, -71.5), MOLDURA, M.Marble)
		Util.bloque(padre, V(2.2, 0.6, 2.2), V(x, Y0 + 0.3, -71.5), MOLDURA, M.Marble, DECO)
		Util.bloque(padre, V(2.2, 0.6, 2.2), V(x, Y0 + 11.7, -71.5), MOLDURA, M.Marble, DECO)
	end
	Util.bloque(padre, V(30, 1, 11), V(0, Y0 + 12.5, -74.5), MOLDURA, M.Plaster)
	Util.fronton(padre, V(0, Y0 + 13, -74.5), 30, 5, 11, TEJADO, M.RoofShingles)
	for _, x in { -7.5, 7.5 } do
		Util.bloque(padre, V(0.6, 1.2, 0.8), V(x, Y0 + 8, ZF + 0.9), C.metal, M.Metal, DECO)
		local b = Util.bola(padre, 0.9, V(x, Y0 + 8.9, ZF + 1.2), rgb(255, 236, 200), M.SmoothPlastic, DECO)
		Util.etiquetar(b, "BombillaJardin")
		local luz = Util.luz(b, rgb(255, 196, 125), 18, 1.5)
		luz.Enabled = false
		Util.etiquetar(luz, "LuzJardin")
	end
	for _, x in { -5.3, 5.3 } do
		Util.bloque(padre, V(0.5, 12, 5), V(x, Y0 + 6, ZF - 2.8), rgb(92, 58, 38), M.WoodPlanks, DECO)
	end
	for _, x in { -50, -32, 32, 50 } do
		Util.bloque(padre, V(6, 1, 1.4), V(x, Y0 + 3.5, ZF + 1.2), rgb(120, 80, 50), M.WoodPlanks, DECO)
		for k = 0, 8 do
			Util.bola(padre, 0.6, V(x - 2.6 + k * 0.65, Y0 + 4.25, ZF + 1.2 + Util.entre(-0.3, 0.3)), Util.elegir(Props.FLORES), M.SmoothPlastic, DECO)
		end
		Util.bloque(padre, V(5.6, 1.2, 0.3), V(x, Y0 + 2.6, ZF + 1.95), C.hojasOscuras, M.LeafyGrass, DECO)
	end
	for _, x in { -58, -56.5, 56.5, 58 } do
		local alto = Util.entre(14, 26)
		Util.bloque(padre, V(Util.entre(1.5, 3), alto, 0.3), V(x, Y0 + alto / 2, ZF + 0.7), rgb(60, 115, 55), M.LeafyGrass, DECO)
	end
end

local function salon(padre)
	for _, lado in { -1, 1 } do
		local xc = lado * 15.75
		local xi = lado * 12
		local zA, zB = -100, -140
		Util.rampa(padre, 7.5, V(xc, Y0, zA), V(xc, Y1, zB), Color3.new(), M.SmoothPlastic, { Transparency = 1 })
		for k = 1, 16 do
			local zc = zA - (k - 0.5) * 2.5
			local arriba = Y0 - 0.5 + k
			Util.bloque(padre, V(7.5, 1, 2.5), V(xc, arriba - 0.5, zc), MADERA, M.Wood, DECO)
			Util.bloque(padre, V(4, 0.06, 2.5), V(xc, arriba + 0.03, zc), rgb(150, 30, 45), M.Carpet, DECO)
			if k % 2 == 1 then
				Util.bloque(padre, V(0.25, 3, 0.25), V(xi, arriba + 1.5, zc), MOLDURA, M.Wood, DECO)
			end
		end
		Util.rampa(padre, 7.5, V(xc, Y0, zA - 2.5), V(xc, Y1 - 1, zB), rgb(85, 55, 35), M.Wood, DECO)
		Util.rampa(padre, 0.5, V(xi, Y0 + 1.2, zA), V(xi, Y1 + 1.2, zB), MADERA, M.Wood, DECO, 2.4)
		Util.rampa(padre, 0.4, V(xi, Y0 + 3.5, zA), V(xi, Y1 + 3.5, zB), MOLDURA, M.Wood, DECO, 0.4)
		Util.rampa(padre, 0.4, V(xi, Y0 + 4, zA), V(xi, Y1 + 4, zB), Color3.new(), M.SmoothPlastic, { Transparency = 1 }, 4)
	end
	Util.bloque(padre, V(24, 0.4, 0.5), V(0, Y1 + 3.3, -140.2), MOLDURA, M.Wood, DECO)
	Util.bloque(padre, V(24, 4, 0.4), V(0, Y1 + 2, -140.2), Color3.new(), M.SmoothPlastic, { Transparency = 1 })
	for x = -11.5, 11.5, 1.5 do
		Util.bloque(padre, V(0.25, 3.2, 0.25), V(x, Y1 + 1.6, -140.2), MOLDURA, M.Wood, DECO)
	end

	chimenea(padre)
	mesaDeTrabajo(padre, V(8.5, Y0, -134))

	local arriba = mesa(padre, V(0, Y0, -113), 5, 22, 3.4)
	for _, z in { -121, -117, -113, -109, -105 } do
		silla(padre, V(-3.8, Y0, z), -math.pi / 2)
		silla(padre, V(3.8, Y0, z), math.pi / 2)
	end
	candelabro(padre, V(0, arriba, -120))
	candelabro(padre, V(0, arriba, -106))
	Props.pagina(padre, V(0.4, arriba + 0.05, -112.5), 1)

	alfombra(padre, V(0, Y0, -112), 14, 50, rgb(130, 28, 40), rgb(200, 160, 80))
	arana(padre, V(0, YT, -112))
	cuadro(padre, CFrame.lookAt(V(-9, Y1 + 6.5, ZB + 0.6), V(-9, Y1 + 6.5, 0)), 5, 7, true)
	cuadro(padre, CFrame.lookAt(V(9, Y1 + 6.5, ZB + 0.6), V(9, Y1 + 6.5, 0)), 5, 7, true)
	for _, x in { -8, 8 } do
		maceta(padre, V(x, Y0, -83.5), 1.2)
	end
	for _, x in { -19.3, 19.3 } do
		local b = Util.bola(padre, 0.8, V(x, Y0 + 9, -86), rgb(255, 225, 170), M.Neon, DECO)
		Util.luz(b, rgb(255, 200, 140), 16, 0.8)
	end

	Util.parte({
		Clase = "SpawnLocation",
		Name = "Aparicion",
		Parent = padre,
		Size = V(8, 0.2, 6),
		Position = V(0, Y0 + 0.1, -131),
		Transparency = 1,
		CanCollide = false,
		Neutral = true,
		Duration = 3,
	})
end

local function plantaBaja(padre)
	alfombra(padre, V(-40, Y0, -97), 22, 18, rgb(120, 40, 50), rgb(200, 160, 80))
	local cfPiano = CFrame.new(-46, Y0, -101) * CFrame.Angles(0, math.rad(-20), 0)
	local negro = rgb(25, 22, 25)
	Util.bloque(padre, V(5, 1.6, 7), cfPiano * CFrame.new(0, 3.2, 0), negro, M.SmoothPlastic, { Reflectance = 0.1 })
	Util.bloque(padre, V(5, 0.3, 1.2), cfPiano * CFrame.new(0, 2.9, -4), rgb(245, 245, 240), M.SmoothPlastic, DECO)
	Util.bloque(padre, V(4.6, 0.32, 0.5), cfPiano * CFrame.new(0, 2.92, -4.2), negro, M.SmoothPlastic, DECO)
	for _, p in { V(-2, 0, -3), V(2, 0, -3), V(0, 0, 3) } do
		Util.bloque(padre, V(0.5, 2.4, 0.5), cfPiano * CFrame.new(p.X, 1.2, p.Z), negro, M.SmoothPlastic, DECO)
	end
	Util.bloque(padre, V(3, 1.8, 1.4), cfPiano * CFrame.new(0, 0.9, -6), negro, M.SmoothPlastic)
	Props.pagina(padre, (cfPiano * CFrame.new(0.5, 4.05, 1)).Position, 2)
	sofa(padre, CFrame.new(-30, Y0, -111) * CFrame.Angles(0, math.pi, 0), 7, rgb(70, 90, 120))
	maceta(padre, V(-57, Y0, -83))
	maceta(padre, V(-23, Y0, -83))
	cuadro(padre, CFrame.lookAt(V(-59.4, Y0 + 8, -108), V(0, Y0 + 8, -108)), 4, 3)
	Props.caja(padre, CFrame.new(-24, Y0, -111) * CFrame.Angles(0, 0.2, 0))
	lampara(padre, V(-40, H, -97))

	Props.puerta(padre, CFrame.new(-40, Y0 + 5.5, -115), 6, 11, "Biblioteca", "Biblioteca")
	for _, x in { -56, -40, -24 } do
		estanteria(padre, CFrame.new(x, Y0, ZB + 1.6) * CFrame.Angles(0, math.pi, 0), 6, 12)
	end
	for _, z in { -142, -122 } do
		estanteria(padre, CFrame.new(X0 + 1.6, Y0, z) * CFrame.Angles(0, -math.pi / 2, 0), 6, 12)
	end
	alfombra(padre, V(-40, Y0, -131), 18, 14, rgb(40, 70, 60), rgb(190, 160, 90))
	local escritorio = mesa(padre, V(-38, Y0, -131), 6, 3, 3.4)
	Util.bloque(padre, V(1.6, 2.6, 2.6), V(-35.8, Y0 + 1.6, -131), MADERA, M.Wood, DECO)
	Props.llave(padre, V(-39.2, escritorio + 0.22, -131), "Invernadero")
	Props.pagina(padre, V(-36.6, escritorio + 0.05, -130.6), 4)
	local lamparita = Util.bola(padre, 0.8, V(-40.5, escritorio + 1.3, -131.8), rgb(80, 200, 120), M.Neon, DECO)
	Util.cilindroV(padre, 0.15, 1, V(-40.5, escritorio + 0.5, -131.8), C.oro, M.Metal, DECO)
	Util.luz(lamparita, rgb(160, 255, 180), 10, 0.8)
	silla(padre, V(-38, Y0, -128), 0)
	globo(padre, V(-26, Y0, -141))
	sofa(padre, CFrame.new(-50, Y0, -124) * CFrame.Angles(0, math.pi / 2, 0), 5, rgb(90, 50, 40))
	Props.caja(padre, CFrame.new(-24, Y0, -119))
	lampara(padre, V(-40, H, -132))

	alfombra(padre, V(40, Y0, -97), 26, 14, rgb(110, 30, 40), rgb(200, 160, 80))
	local mesaComedor = mesa(padre, V(40, Y0, -97), 18, 5, 3.4)
	for x = 33, 47, 3.5 do
		silla(padre, V(x, Y0, -100.4), math.pi)
		silla(padre, V(x, Y0, -93.6), 0)
	end
	silla(padre, V(29.5, Y0, -97), -math.pi / 2)
	silla(padre, V(50.5, Y0, -97), math.pi / 2)
	candelabro(padre, V(36, mesaComedor, -97))
	candelabro(padre, V(44, mesaComedor, -97))
	for x = 33, 47, 3.5 do
		Util.cilindroV(padre, 1.2, 0.08, V(x, mesaComedor + 0.04, -98.8), rgb(250, 250, 245), M.SmoothPlastic, DECO)
		Util.cilindroV(padre, 1.2, 0.08, V(x, mesaComedor + 0.04, -95.2), rgb(250, 250, 245), M.SmoothPlastic, DECO)
	end
	Util.bloque(padre, V(8, 3.6, 1.8), V(52, Y0 + 1.8, -113.4), MADERA, M.Wood)
	candelabro(padre, V(52, Y0 + 3.6, -113.4))
	cuadro(padre, CFrame.lookAt(V(28, Y0 + 8, -114.4), V(28, Y0 + 8, 0)), 6, 4)
	Props.caja(padre, CFrame.new(56.5, Y0, -84))
	maceta(padre, V(23, Y0, -83))
	lampara(padre, V(40, H, -97), 30, 1.2)

	Util.bloque(padre, V(34, 3.4, 3), V(40, Y0 + 1.7, ZB + 2), rgb(200, 190, 175), M.Wood)
	Util.bloque(padre, V(34.4, 0.3, 3.3), V(40, Y0 + 3.55, ZB + 2), MARMOL, M.Marble, DECO)
	Util.bloque(padre, V(6, 3.9, 3.1), V(40, Y0 + 1.95, ZB + 2), rgb(35, 35, 38), M.Metal)
	for _, x in { 38.5, 41.5 } do
		Util.cilindroV(padre, 1.6, 1.2, V(x, Y0 + 4.5, ZB + 2), rgb(120, 120, 125), M.Metal, DECO)
	end
	local mesaCocina = mesa(padre, V(40, Y0, -132), 8, 4, 3.2, rgb(160, 120, 80))
	for _, x in { 37, 43 } do
		for _, z in { -134.8, -129.2 } do
			Util.cilindroV(padre, 1.2, 2.2, V(x, Y0 + 1.1, z), rgb(160, 120, 80), M.Wood)
		end
	end
	Util.elipsoide(padre, V(1.8, 0.6, 1.8), V(40, mesaCocina + 0.3, -132), rgb(200, 190, 170), M.SmoothPlastic, DECO)
	for k = 0, 2 do
		Util.bola(padre, 0.6, V(39.6 + k * 0.4, mesaCocina + 0.55, -132), rgb(210, 30, 40), M.SmoothPlastic, DECO)
	end
	Props.despensa(padre, CFrame.new(21.9, Y0, -128) * CFrame.Angles(0, -math.pi / 2, 0))
	Props.despensa(padre, CFrame.new(21.9, Y0, -140) * CFrame.Angles(0, -math.pi / 2, 0))
	Props.caja(padre, CFrame.new(56.5, Y0, -119))
	lampara(padre, V(40, H, -132))

	Props.puerta(padre, CFrame.new(X1, Y0 + 5.5, -125) * CFrame.Angles(0, math.pi / 2, 0), 6, 11, "Invernadero", "Invernadero")
end

local function invernadero(padre)
	local m = Util.modelo("Invernadero", padre)
	local vidrio = { Transparency = 0.6 }
	local colorVidrio = rgb(205, 235, 225)
	local blanco = rgb(245, 245, 240)
	Util.bloque(m, V(32, 1, 50), V(76, 0.5, -121), rgb(190, 112, 82), M.CeramicTiles)
	Util.bloque(m, V(0.8, 2, 50), V(91.6, Y0 + 1, -121), rgb(150, 92, 72), M.Brick)
	Util.bloque(m, V(32, 2, 0.8), V(76, Y0 + 1, -145.6), rgb(150, 92, 72), M.Brick)
	Util.bloque(m, V(32, 2, 0.8), V(76, Y0 + 1, -96.4), rgb(150, 92, 72), M.Brick)
	Util.bloque(m, V(0.4, 11, 50), V(91.6, Y0 + 7.5, -121), colorVidrio, M.Glass, vidrio)
	Util.bloque(m, V(32, 11, 0.4), V(76, Y0 + 7.5, -145.6), colorVidrio, M.Glass, vidrio)
	Util.bloque(m, V(32, 11, 0.4), V(76, Y0 + 7.5, -96.4), colorVidrio, M.Glass, vidrio)
	for z = -146, -96, 5 do
		Util.bloque(m, V(0.6, 11, 0.6), V(91.6, Y0 + 7.5, z), blanco, M.Wood, DECO)
	end
	for x = 61, 91, 5 do
		Util.bloque(m, V(0.6, 11, 0.6), V(x, Y0 + 7.5, -145.6), blanco, M.Wood, DECO)
		Util.bloque(m, V(0.6, 11, 0.6), V(x, Y0 + 7.5, -96.4), blanco, M.Wood, DECO)
	end
	local yTejado = Y0 + 13
	Util.bloque(m, V(0.8, 0.6, 50), V(91.6, yTejado + 0.3, -121), blanco, M.Wood)
	Util.bloque(m, V(32, 0.6, 0.8), V(76, yTejado + 0.3, -145.6), blanco, M.Wood)
	Util.bloque(m, V(32, 0.6, 0.8), V(76, yTejado + 0.3, -96.4), blanco, M.Wood)
	Util.cuna(m, V(50, 6, 16), CFrame.new(68, yTejado + 3.6, -121) * CFrame.Angles(0, math.pi / 2, 0), colorVidrio, M.Glass, vidrio)
	Util.cuna(m, V(50, 6, 16), CFrame.new(84, yTejado + 3.6, -121) * CFrame.Angles(0, -math.pi / 2, 0), colorVidrio, M.Glass, vidrio)
	Util.bloque(m, V(0.6, 0.6, 50), V(76, yTejado + 6.6, -121), blanco, M.Wood, DECO)
	for z = -146, -96, 10 do
		Util.barra(m, 0.4, V(60, yTejado + 0.6, z), V(76, yTejado + 6.6, z), blanco, M.Wood, DECO)
		Util.barra(m, 0.4, V(92, yTejado + 0.6, z), V(76, yTejado + 6.6, z), blanco, M.Wood, DECO)
	end

	for _, z in { -142.5, -99.5 } do
		local arriba = mesa(m, V(76, Y0, z), 24, 3, 3, rgb(150, 110, 70))
		for x = 66, 86, 4 do
			Util.cilindroV(m, 1.2, 1, V(x, arriba + 0.5, z), rgb(185, 100, 70), M.Brick, DECO)
			Props.arbusto(m, V(x, arriba + 0.9, z), V(1.6, 1.4, 1.6), C.hojas, Props.FLORES, 4)
		end
	end
	Props.pagina(padre, V(68, Y0 + 3.05, -98.7), 5)

	local c = V(76, Y0, -121)
	Util.cilindroV(m, 8.6, 1.2, c + V(0, 0.6, 0), rgb(150, 92, 72), M.Brick)
	Util.cilindroV(m, 7.8, 1.25, c + V(0, 0.65, 0), C.tierra, M.Mud, DECO)
	local morado = rgb(70, 0, 100)
	local centro = c + V(0.4, 8.6, -0.4)
	Util.barra(m, 0.7, c + V(0, 1.2, 0), centro, rgb(40, 30, 40), M.SmoothPlastic, DECO)
	local corazon = Util.bola(m, 1.8, centro, rgb(140, 40, 190), M.Neon, DECO)
	for i = 0, 6 do
		local a = i * (math.pi * 2 / 7)
		local cf = CFrame.new(centro) * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -1.9) * CFrame.Angles(math.rad(25), 0, 0)
		Util.elipsoide(m, V(1.3, 0.35, 3.2), cf, morado, M.Neon, DECO)
	end
	for i = 0, 3 do
		local a = i * (math.pi / 2) + 0.4
		Util.elipsoide(m, V(3.5, 0.3, 1.4), CFrame.new(c + V(math.cos(a) * 1.8, 3 + i * 0.8, math.sin(a) * 1.8)) * CFrame.Angles(0, -a, 0.3), rgb(25, 40, 25), M.SmoothPlastic, DECO)
	end
	Util.luz(corazon, rgb(170, 70, 255), 20, 2)
	Util.particulas(corazon, {
		Color = ColorSequence.new(rgb(190, 110, 255)),
		LightEmission = 1,
		Size = NumberSequence.new(0.15),
		Lifetime = NumberRange.new(3, 5),
		Rate = 6,
		Speed = NumberRange.new(0.5, 1),
		SpreadAngle = Vector2.new(180, 180),
		Acceleration = V(0, 0.4, 0),
	})
	for i = 0, 7 do
		local a = i * (math.pi / 4) + 0.2
		local hasta = c + V(math.cos(a) * 13, 0.2, math.sin(a) * 13)
		Util.barra(m, 0.5, c + V(math.cos(a) * 4, 1.2, math.sin(a) * 4), hasta, rgb(55, 40, 30), M.Wood, DECO)
	end
	Util.barra(m, 0.5, V(91, Y0 + 0.3, -128), V(91, Y0 + 9, -132), rgb(55, 40, 30), M.Wood, DECO)
	Util.barra(m, 0.4, V(61, Y0 + 0.3, -116), V(61, Y0 + 8, -112), rgb(55, 40, 30), M.Wood, DECO)
	Props.llave(padre, c + V(3.3, 1.42, 1.5), "Estudio")
	for _, p in { V(66, 0, -110), V(86, 0, -110), V(66, 0, -132), V(86, 0, -132) } do
		Util.cilindroV(m, 0.1, 3, p + V(0, yTejado - 0.5, 0), C.metal, M.Metal, DECO)
		Util.elipsoide(m, V(2.6, 2, 2.6), p + V(0, yTejado - 2.8, 0), rgb(80, 150, 70), M.LeafyGrass, DECO)
	end
	Props.caja(padre, CFrame.new(89.5, Y0, -138) * CFrame.Angles(0, math.pi / 2, 0))
	return m
end

local function plantaAlta(padre)
	alfombra(padre, V(-40, Y1, -132), 20, 16, rgb(60, 80, 110), rgb(190, 170, 120))
	cama(padre, CFrame.new(-50, Y1, -142) * CFrame.Angles(0, math.pi, 0), 6, 8, rgb(70, 100, 150))
	armario(padre, CFrame.new(X0 + 1.6, Y1, -122) * CFrame.Angles(0, -math.pi / 2, 0), 5, 8)
	mesa(padre, V(-43, Y1, -146.5), 2, 2, 2.6)
	candelabro(padre, V(-43, Y1 + 2.6, -146.5))
	Props.caja(padre, CFrame.new(-30, Y1, -120))
	lampara(padre, V(-40, YT, -132))

	Props.puerta(padre, CFrame.new(-40, Y1 + 5.5, -115), 6, 11, "Estudio", "Estudio")
	alfombra(padre, V(-40, Y1, -96), 20, 16, rgb(90, 50, 40), rgb(200, 160, 80))
	local escritorio = mesa(padre, V(-40, Y1, -95), 7, 3.5, 3.4)
	Util.bloque(padre, V(1.8, 2.6, 3), V(-37.3, Y1 + 1.6, -95), MADERA, M.Wood, DECO)
	Props.llave(padre, V(-41, escritorio + 0.22, -95), "Dormitorio")
	Props.pagina(padre, V(-38.4, escritorio + 0.05, -94.6), 7)
	candelabro(padre, V(-43, escritorio, -95.8))
	silla(padre, V(-40, Y1, -91.8), 0)
	for _, x in { -52, -28 } do
		estanteria(padre, CFrame.new(x, Y1, -113.4) * CFrame.Angles(0, math.pi, 0), 6, 12)
	end
	globo(padre, V(-26, Y1, -86))
	cuadro(padre, CFrame.lookAt(V(-59.4, Y1 + 8, -112), V(0, Y1 + 8, -112)), 6, 4)
	sofa(padre, CFrame.new(-54, Y1, -92) * CFrame.Angles(0, math.pi / 2, 0), 5, rgb(90, 50, 40))
	Props.caja(padre, CFrame.new(-56, Y1, -84))
	lampara(padre, V(-40, YT, -97))

	alfombra(padre, V(40, Y1, -132), 22, 18, rgb(220, 170, 190), rgb(120, 170, 210))
	cama(padre, CFrame.new(36, Y1, -144) * CFrame.Angles(0, math.pi, 0), 4, 6.5, rgb(90, 140, 210))
	local almohada = cama(padre, CFrame.new(50, Y1, -144) * CFrame.Angles(0, math.pi, 0), 4, 6.5, rgb(230, 130, 170))
	Util.elipsoide(padre, V(0.9, 1.1, 0.7), almohada + V(0, 0.4, 1.4), rgb(160, 40, 60), M.Fabric, DECO)
	Util.bola(padre, 0.7, almohada + V(0, 1.2, 1.4), rgb(240, 220, 205), M.SmoothPlastic, DECO)
	local cab = V(44, Y1, -125)
	Util.bloque(padre, V(5, 0.3, 0.6), cab + V(0, 0.15, -1), rgb(160, 110, 60), M.Wood, DECO)
	Util.bloque(padre, V(5, 0.3, 0.6), cab + V(0, 0.15, 1), rgb(160, 110, 60), M.Wood, DECO)
	Util.elipsoide(padre, V(3.2, 1.6, 1.4), cab + V(0, 2.2, 0), rgb(240, 235, 225), M.Wood)
	Util.elipsoide(padre, V(1.4, 1.2, 1), cab + V(1.8, 3.4, 0), rgb(240, 235, 225), M.Wood, DECO)
	for _, x in { -1, 1 } do
		Util.bloque(padre, V(0.4, 1.6, 2), cab + V(x, 0.9, 0), rgb(160, 110, 60), M.Wood, DECO)
	end
	for k = 0, 4 do
		Util.bloque(padre, V(1, 1, 1), CFrame.new(V(30 + k * 1.6, Y1 + 0.5, -122 + (k % 2) * 1.2)) * CFrame.Angles(0, k * 0.5, 0), Util.elegir(Props.FLORES), M.SmoothPlastic, DECO)
	end
	Props.caja(padre, CFrame.new(56.5, Y1, -119))
	lampara(padre, V(40, YT, -132))

	Props.puerta(padre, CFrame.new(40, Y1 + 5.5, -115), 6, 11, "Dormitorio", "Dormitorio Principal")
	alfombra(padre, V(44, Y1, -98), 22, 18, rgb(120, 30, 50), rgb(200, 160, 80))
	local cfCama = CFrame.new(54, Y1, -100) * CFrame.Angles(0, math.pi / 2, 0)
	local sobreAlmohada = cama(padre, cfCama, 7, 9, rgb(150, 30, 50))
	for _, sx in { -3.3, 3.3 } do
		for _, sz in { -4.3, 4.3 } do
			Util.bloque(padre, V(0.4, 9, 0.4), cfCama * CFrame.new(sx, 4.5, sz), rgb(100, 65, 42), M.Wood)
		end
	end
	Util.bloque(padre, V(7.2, 0.4, 9.2), cfCama * CFrame.new(0, 9.1, 0), rgb(100, 65, 42), M.Wood, DECO)
	for _, sx in { -3.5, 3.5 } do
		Util.bloque(padre, V(0.15, 6, 9), cfCama * CFrame.new(sx, 6, 0), rgb(130, 20, 40), M.Fabric, { Deco = true, Transparency = 0.35 })
	end
	Props.llave(padre, sobreAlmohada + V(0, 0.05, 0), "Cripta")
	Props.pagina(padre, (cfCama * CFrame.new(1.2, 2.62, -1.5)).Position, 8)
	Util.bloque(padre, V(5, 3, 2), V(25, Y1 + 1.5, -84), rgb(240, 230, 215), M.Wood)
	Util.bloque(padre, V(3.6, 4, 0.2), V(25, Y1 + 5.2, -83.2), rgb(220, 230, 240), M.Glass, { Reflectance = 0.6 })
	Util.bloque(padre, V(4, 4.4, 0.15), V(25, Y1 + 5.2, -83.05), C.oro, M.Metal, DECO)
	armario(padre, CFrame.new(30, Y1, -113.4) * CFrame.Angles(0, math.pi, 0), 6, 9)
	cuadro(padre, CFrame.lookAt(V(20.6, Y1 + 8, -100), V(100, Y1 + 8, -100)), 5, 7, true)
	Props.caja(padre, CFrame.new(24, Y1, -104) * CFrame.Angles(0, 0.3, 0))
	lampara(padre, V(44, YT, -98))
end

local function tramoEscalera(padre, a: Vector3, b: Vector3, ancho: number)
	Util.rampa(padre, ancho, a, b, Color3.new(), M.SmoothPlastic, { Transparency = 1 })
	local horizontal = V(b.X - a.X, 0, b.Z - a.Z)
	local dir = horizontal.Unit
	local n = 8
	local huella = horizontal.Magnitude / n
	local subida = (b.Y - a.Y) / n
	for k = 1, n do
		local centro = V(a.X, 0, a.Z) + dir * (huella * (k - 0.5))
		local arriba = a.Y + subida * (k - 0.5)
		local cf = CFrame.lookAt(V(centro.X, arriba - 0.5, centro.Z), V(centro.X, arriba - 0.5, centro.Z) + dir)
		Util.bloque(padre, V(ancho, 1, huella), cf, MADERA, M.Wood, DECO)
		Util.bloque(padre, V(ancho * 0.6, 0.06, huella), cf * CFrame.new(0, 0.53, 0), rgb(40, 70, 110), M.Carpet, DECO)
	end
	Util.rampa(padre, ancho, a - V(0, 0.6, 0), b - V(0, 0.6, 0), rgb(85, 55, 35), M.Wood, DECO)
end

local function figuraFantasma(padre, base: Vector3, rotY: number, vestido: boolean)
	local cf = CFrame.new(base) * CFrame.Angles(0, rotY, 0)
	local color = rgb(200, 220, 250)
	local extra = { Deco = true, Transparency = 0.72 }
	if vestido then
		Util.elipsoide(padre, V(3, 4.4, 3), cf * CFrame.new(0, 2.2, 0), color, M.Neon, extra)
	else
		Util.bloque(padre, V(1.6, 4.2, 1), cf * CFrame.new(0, 2.1, 0), color, M.Neon, extra)
	end
	Util.elipsoide(padre, V(2, 2.6, 1.2), cf * CFrame.new(0, 5.4, 0), color, M.Neon, extra)
	Util.bola(padre, 1.3, (cf * CFrame.new(0, 7.3, 0)).Position, color, M.Neon, extra)
	Util.bloque(padre, V(0.5, 0.5, 2.2), cf * CFrame.new(0.9, 6, -0.9), color, M.Neon, extra)
end

local function alaOeste(padre)
	local G = 1
	local m = padre

	Util.bloque(m, V(28, 1, 70), V(WXC, 0.5, -115), MARMOL, M.Marble)
	Util.bloque(m, V(28, 1, 56), V(WXC, H + 0.5, -108), MADERA_SUELO, M.WoodPlanks)
	Util.bloque(m, V(28, 1, 56), V(WXC, Y2 - 0.5, -108), MADERA_SUELO, M.WoodPlanks)
	Util.bloque(m, V(5.5, 1, 13), V(-84.75, H + 0.5, -143), MADERA_SUELO, M.WoodPlanks)
	Util.bloque(m, V(5.5, 1, 13), V(-84.75, Y2 - 0.5, -143), MADERA_SUELO, M.WoodPlanks)
	Util.bloque(m, V(5.5, 1, 13), V(-63.25, Y0 + 8, -143), MADERA_SUELO, M.WoodPlanks)
	Util.bloque(m, V(5.5, 1, 13), V(-63.25, Y1 + 8, -143), MADERA_SUELO, M.WoodPlanks)
	Util.bloque(m, V(24, 1, 71), V(-71.5, WYT + 0.5, -115), PIEDRA, M.Slate)
	Util.bloque(m, V(5, 1, 58.5), V(-86, WYT + 0.5, -121.25), PIEDRA, M.Slate)
	Util.bloque(m, V(5, 1, 8.5), V(-86, WYT + 0.5, -83.75), PIEDRA, M.Slate)

	local zS, zN = -146.5, -139.5
	tramoEscalera(m, V(-82, Y0, zS), V(-66, Y0 + 8.5, zS), 6)
	tramoEscalera(m, V(-66, Y0 + 8.5, zN), V(-82, Y1, zN), 6)
	tramoEscalera(m, V(-82, Y1, zS), V(-66, Y1 + 8.5, zS), 6)
	tramoEscalera(m, V(-66, Y1 + 8.5, zN), V(-82, Y2, zN), 6)
	Util.bloque(m, V(16, WYT - Y0, 1), V(-74, (Y0 + WYT) / 2, -143), PARED, M.Plaster)

	local alto = WYT - Y0
	muro(m, "X", ZF, WX0 - 0.5, X0 - 0.5, Y0, alto, G, {
		hPuerta(WXC, 0, 11, 8),
		hVentana(-84, 4),
		hVentana(-64, 4),
		hVentanaAbierta(-84, H + 2, 9, 5, 1),
		hVentana(-74, H + 4),
		hVentanaAbierta(-64, H + 2, 9, 5, 1),
		hVentana(-84, Y2 - Y0 + 2, 8, 5),
		hVentana(-74, Y2 - Y0 + 2, 8, 5),
		hVentanaAbierta(-64, Y2 - Y0 + 2, 8, 5, 1),
	})
	muro(m, "Z", WX0, ZB - 0.5, ZF + 0.5, Y0, alto, G, {
		hVentana(-125, 3, 9),
		hVentana(-111, 3, 9),
		hVentana(-97, 3, 9),
		hVentana(-86, 3, 9),
		hVentana(-143, 9, 5, 4),
		hVentana(-125, H + 4),
		hVentana(-115, H + 4),
		hVentana(-95, H + 4),
		hVentana(-143, H + 9, 5, 4),
		hVentana(-125, Y2 - Y0 + 3),
		hVentana(-105, Y2 - Y0 + 3),
		hVentana(-92, Y2 - Y0 + 3),
	})
	muro(m, "X", ZB, WX0 - 0.5, X0 - 0.5, Y0, alto, G, {
		hVentana(-84.75, 4),
		hVentana(-84.75, H + 4),
		hVentana(-84.75, Y2 - Y0 + 3),
	})
	muro(m, "Z", X0, ZB - 0.5, ZF + 0.5, YT, WYT - YT, G, { hPuerta(-115, 1, 9, 5) })

	muro(m, "X", ZESC, WX0 + 0.5, X0 - 0.5, Y0, alto, G, {
		hPuerta(-84.75, 0, 11, 5),
		hPuerta(-84.75, H, 11, 5),
		hPuerta(-84.75, Y2 - Y0, 11, 5),
	})
	muro(m, "X", -108, WX0 + 0.5, X0 - 0.5, Y1, Y2 - 1 - Y1, G, { hPuerta(WXC, 0, 11, 6) })

	for _, y in { Y1, Y2, WYT } do
		Util.bloque(m, V(29, 0.6, 0.6), V(WXC, y, ZF + 0.8), MOLDURA, M.Plaster, DECO)
		Util.bloque(m, V(29, 0.6, 0.6), V(WXC, y, ZB - 0.8), MOLDURA, M.Plaster, DECO)
		Util.bloque(m, V(0.6, 0.6, 71.6), V(WX0 - 0.8, y, -115), MOLDURA, M.Plaster, DECO)
	end
	Util.bloque(m, V(29, 1.6, 0.6), V(WXC, 0.8, ZF + 0.8), PIEDRA, M.Limestone, DECO)
	Util.bloque(m, V(0.6, 1.6, 71.6), V(WX0 - 0.8, 0.8, -115), PIEDRA, M.Limestone, DECO)
	for _, x in { -84, -64 } do
		balcon(m, x, ZF + 0.5, Y0 + H + 2, 1)
	end
	Util.bloque(m, V(12, 0.6, 4), V(WXC, 0.3, ZF + 2), PIEDRA, M.Limestone)
	Util.bloque(m, V(12, 0.3, 10), V(WXC, 0.15, ZF + 9), rgb(204, 192, 168), M.Pavement)
	for _, x in { WXC - 5.5, WXC + 5.5 } do
		Util.bloque(m, V(0.6, 1.2, 0.8), V(x, Y0 + 8, ZF + 0.9), C.metal, M.Metal, DECO)
		local b = Util.bola(m, 0.9, V(x, Y0 + 8.9, ZF + 1.2), rgb(255, 236, 200), M.SmoothPlastic, DECO)
		Util.etiquetar(b, "BombillaJardin")
		local luz = Util.luz(b, rgb(255, 196, 125), 18, 1.5)
		luz.Enabled = false
		Util.etiquetar(luz, "LuzJardin")
	end
	for _, z in { -84, -146 } do
		local altoHiedra = Util.entre(18, 34)
		Util.bloque(m, V(0.3, altoHiedra, Util.entre(2, 4)), V(WX0 - 0.7, Y0 + altoHiedra / 2, z), rgb(60, 115, 55), M.LeafyGrass, DECO)
	end

	for fila = 0, 11 do
		for col = 0, 5 do
			local color = if (fila + col) % 2 == 0 then rgb(240, 236, 228) else rgb(40, 38, 44)
			Util.bloque(m, V(4.5, 0.06, 4.5), V(WX0 + 0.5 + 2.25 + col * 4.5, Y0 + 0.03, -135 + 2.25 + fila * 4.5), color, M.Marble, DECO)
		end
	end
	arana(m, V(WXC, H, -121))
	arana(m, V(WXC, H, -95))
	for _, z in { -118, -104 } do
		Util.bloque(m, V(0.3, 10, 5), V(WX0 + 0.7, Y0 + 6, z), rgb(215, 225, 235), M.Glass, { Deco = true, Reflectance = 0.5 })
		Util.bloque(m, V(0.2, 10.8, 5.8), V(WX0 + 0.55, Y0 + 6, z), C.oro, M.Metal, DECO)
	end
	for _, p in { V(-85.5, 0, -133.5), V(-62.5, 0, -133.5), V(-85.5, 0, -82.5), V(-62.5, 0, -82.5) } do
		Util.cilindroV(m, 1.4, H - 1, V(p.X, Y0 + (H - 1) / 2, p.Z), MOLDURA, M.Marble)
	end
	Util.bloque(m, V(20, 0.8, 6), V(-70, Y0 + 0.4, -132), MADERA, M.WoodPlanks)
	for _, x in { -76, -70, -64 } do
		Util.cilindroV(m, 0.15, 3.4, V(x, Y0 + 2.5, -131), C.metal, M.Metal, DECO)
		Util.bloque(m, V(1.6, 1.1, 0.1), CFrame.new(x, Y0 + 4.3, -130.8) * CFrame.Angles(math.rad(-25), 0, 0), C.metal, M.Metal, DECO)
	end
	Util.elipsoide(m, V(1.6, 3.4, 1), V(-67, Y0 + 2.6, -133), rgb(140, 70, 35), M.Wood, DECO)
	mesa(m, V(-83, Y0, -106), 2.4, 2.4, 3)
	Util.bloque(m, V(1.6, 1, 1.6), V(-83, Y0 + 3.5, -106), rgb(110, 70, 40), M.Wood, DECO)
	Util.cilindro(m, 2, 0.2, CFrame.new(-83, Y0 + 5.2, -105.2) * CFrame.Angles(0, math.pi / 2, 0) * CFrame.Angles(0, 0, 0.6), C.oro, M.Metal, DECO)
	for z = -125, -85, 5 do
		if math.abs(z + 98) > 4 then
			silla(m, V(-62.2, Y0, z), math.pi / 2)
		end
	end
	figuraFantasma(m, V(-77, Y0, -110), 0.4, true)
	figuraFantasma(m, V(-75.5, Y0, -111.2), 0.4 + math.pi, false)
	figuraFantasma(m, V(-71, Y0, -98), -0.8, true)
	figuraFantasma(m, V(-72.4, Y0, -96.8), -0.8 + math.pi, false)
	Props.caja(m, CFrame.new(-86, Y0, -84) * CFrame.Angles(0, 0.4, 0))
	Props.caja(m, CFrame.new(-63, Y0, -125))

	alfombra(m, V(WXC, Y1, -122), 8, 24, rgb(40, 70, 110), rgb(200, 170, 100))
	for _, z in { -131, -120, -110.5 } do
		cuadro(m, CFrame.lookAt(V(WX0 + 0.6, Y1 + 7, z), V(0, Y1 + 7, z)), 3.2, 4.6, true)
	end
	cuadro(m, CFrame.lookAt(V(-74, Y1 + 7, -108.6), V(-74, Y1 + 7, -200)), 6, 4)
	for _, z in { -129, -121, -113 } do
		Util.cilindroV(m, 1.4, 3.6, V(-68, Y1 + 1.8, z), MARMOL, M.Marble)
		Util.bola(m, 1.4, V(-68, Y1 + 4.3, z), MARMOL, M.Marble, DECO)
		Util.elipsoide(m, V(1.8, 1, 1.2), V(-68, Y1 + 3.75, z), MARMOL, M.Marble, DECO)
	end
	Props.banco(m, CFrame.new(-80, Y1, -121) * CFrame.Angles(0, math.pi / 2, 0))
	Props.caja(m, CFrame.new(-63, Y1, -112))
	lampara(m, V(WXC, Y2 - 1, -122))

	alfombra(m, V(WXC, Y1, -94), 18, 18, rgb(150, 70, 90), rgb(220, 190, 120))
	local mesaCostura = mesa(m, V(-80, Y1, -96), 5, 3, 3.2)
	Util.bloque(m, V(1.8, 1.2, 0.8), V(-80.6, mesaCostura + 0.6, -96), rgb(30, 30, 34), M.Metal, DECO)
	Util.bloque(m, V(0.4, 0.8, 0.8), V(-79.4, mesaCostura + 1, -96), rgb(30, 30, 34), M.Metal, DECO)
	silla(m, V(-80, Y1, -92.5), 0)
	Util.cilindroV(m, 0.3, 3, V(-66, Y1 + 1.5, -100), MADERA, M.Wood, DECO)
	Util.elipsoide(m, V(2, 3, 1.4), V(-66, Y1 + 4.5, -100), rgb(240, 230, 215), M.Fabric)
	Util.elipsoide(m, V(3, 3.4, 2.4), V(-66, Y1 + 2.4, -100), rgb(120, 30, 50), M.Fabric, { Deco = true, Transparency = 0.1 })
	for i, color in { rgb(200, 60, 80), rgb(70, 110, 170), rgb(230, 200, 90), rgb(110, 160, 90) } do
		Util.cilindro(m, 1, 4, CFrame.new(-86, Y1 + 0.5 + (i - 1) * 1.05, -104 + (i % 2) * 0.4) * CFrame.Angles(0, math.pi / 2, 0), color, M.Fabric)
	end
	armario(m, CFrame.new(-62, Y1, -88) * CFrame.Angles(0, math.pi / 2, 0), 5, 8)
	Props.caja(m, CFrame.new(-84, Y1, -84))
	lampara(m, V(WXC, Y2 - 1, -94))

	alfombra(m, V(WXC, Y2, -110), 20, 36, rgb(60, 60, 55), rgb(120, 110, 80))
	for _, z in { -122, -104 } do
		local arriba = mesa(m, V(-72, Y2, z), 10, 3.5, 3.4, rgb(90, 80, 70))
		for k = 0, 5 do
			local color = Util.elegir({ rgb(120, 255, 120), rgb(170, 90, 255), rgb(255, 120, 60), rgb(90, 200, 255) })
			local altoTarro = Util.entre(0.8, 1.6)
			Util.cilindroV(m, 0.6, altoTarro, V(-76 + k * 1.6, arriba + altoTarro / 2, z + Util.entre(-0.8, 0.8)), rgb(220, 240, 240), M.Glass, { Deco = true, Transparency = 0.5 })
			Util.cilindroV(m, 0.45, altoTarro * 0.6, V(-76 + k * 1.6, arriba + altoTarro * 0.3, z + Util.entre(-0.3, 0.3)), color, M.Neon, DECO)
		end
	end
	Util.cilindroV(m, 3, 3, V(-66, Y2 + 1.5, -130), MADERA, M.Wood)
	Util.bloque(m, V(2.6, 3, 2.6), V(-66, Y2 + 4.5, -130), rgb(220, 235, 240), M.Glass, { Transparency = 0.6 })
	local semilla = Util.bola(m, 1, V(-66, Y2 + 4, -130), rgb(40, 10, 60), M.Neon, DECO)
	Util.luz(semilla, rgb(170, 70, 255), 14, 2)
	Util.particulas(semilla, {
		Color = ColorSequence.new(rgb(190, 110, 255)),
		LightEmission = 1,
		Size = NumberSequence.new(0.12),
		Lifetime = NumberRange.new(2, 3),
		Rate = 5,
		Speed = NumberRange.new(0.3, 0.6),
		SpreadAngle = Vector2.new(180, 180),
	})
	Util.bloque(m, V(0.3, 6, 10), V(WX0 + 0.7, Y2 + 6, -114), rgb(40, 52, 45), M.Slate, DECO)
	Util.bloque(m, V(0.35, 6.6, 10.6), V(WX0 + 0.6, Y2 + 6, -114), MADERA, M.Wood, DECO)
	for k = 0, 4 do
		Util.barra(m, 0.15, V(WX0 + 0.9, Y2 + 8 - k * 0.3, -118 + k), V(WX0 + 0.9, Y2 + 4 + k * 0.2, -113 + k * 0.7), rgb(235, 235, 225), M.SmoothPlastic, DECO)
	end
	local escritorio = mesa(m, V(-62.5, Y2, -101), 3, 4, 3.2)
	Props.pagina(m, V(-62.5, escritorio + 0.05, -101.5), 14)
	candelabro(m, V(-62.5, escritorio, -99.8))
	estanteria(m, CFrame.new(-80, Y2, -134.4) * CFrame.Angles(0, math.pi, 0), 6, 10)
	for _, p in { V(-62, Y2, -88), V(-62, Y2, -96) } do
		Util.cilindroV(m, 1.6, 1.6, p + V(0, 0.8, 0), rgb(185, 100, 70), M.Brick)
		Util.elipsoide(m, V(2, 3.4, 2), p + V(0, 3.2, 0), rgb(35, 45, 35), M.LeafyGrass, DECO)
		Util.bola(m, 0.6, p + V(0.3, 4.6, 0.2), rgb(70, 0, 100), M.Neon, DECO)
	end
	Props.caja(m, CFrame.new(-62, Y2, -122))
	Props.caja(m, CFrame.new(-80, Y2, -84) * CFrame.Angles(0, 0.3, 0))
	lampara(m, V(WXC, WYT, -122))
	lampara(m, V(WXC, WYT, -96))

	Util.parte({
		Clase = "TrussPart",
		Parent = m,
		Name = "EscaleraTorre",
		Size = V(2, 18, 2),
		CFrame = CFrame.new(-86.5, Y2 + 9, -90),
		Color = MADERA,
		Material = M.Wood,
	})

	local yP = WYT + 1
	Util.bloque(m, V(14, 3, 0.8), V(-67, yP + 1.5, ZF + 0.1), PIEDRA, M.Limestone)
	Util.bloque(m, V(29, 3, 0.8), V(WXC, yP + 1.5, ZB - 0.1), PIEDRA, M.Limestone)
	Util.bloque(m, V(0.8, 3, 56), V(WX0 - 0.1, yP + 1.5, -122), PIEDRA, M.Limestone)
	Util.bloque(m, V(0.8, 3, 70), V(X0 + 0.1, yP + 1.5, -115), PIEDRA, M.Limestone)
	for _, p in { V(-67, 0, ZF + 0.1), V(WXC, 0, ZB - 0.1) } do
		Util.bloque(m, V(if p.X == -67 then 14.6 else 29.6, 0.4, 1.3), V(p.X, yP + 3.2, p.Z), MOLDURA, M.Limestone, DECO)
	end
	for _, x in { -80, -66 } do
		Util.cilindroV(m, 1.3, 1, V(x, yP + 0.5, -140), rgb(185, 100, 70), M.Brick, DECO)
		Props.arbusto(m, V(x, yP + 1, -140), V(1.6, 1.4, 1.6), C.hojas, Props.FLORES, 5)
	end

	local yT0 = WYT + 1
	local altoT = 14
	muro(m, "Z", WX0, -94.5, ZF + 0.5, yT0, altoT, G, { hHueco(-87, 3, 7, 6) })
	muro(m, "X", ZF, WX0 - 0.5, -73.5, yT0, altoT, G, { hHueco(-81, 3, 7, 6) })
	muro(m, "Z", -74, -94.5, ZF + 0.5, yT0, altoT, G, { hPuerta(-87, 0, 9, 5) })
	muro(m, "X", -94, WX0 - 0.5, -73.5, yT0, altoT, G, { hPuerta(-81, 0, 9, 5) })
	local yTecho = yT0 + altoT
	Util.bloque(m, V(16, 1, 16), V(-81, yTecho + 0.5, -87), MOLDURA, M.Plaster)
	for k = 1, 6 do
		local lado = 16 - k * 2.4
		Util.bloque(m, V(lado, 1.4, lado), V(-81, yTecho + 0.3 + k * 1.4, -87), TEJADO, M.RoofShingles)
	end
	Util.cilindroV(m, 0.4, 4, V(-81, yTecho + 11.5, -87), C.metal, M.Metal, DECO)
	Util.bola(m, 0.9, V(-81, yTecho + 13.6, -87), C.oro, M.Metal, DECO)
	local pie = V(-82, yT0, -83.5)
	for i = 0, 2 do
		local a = i * (math.pi * 2 / 3)
		Util.barra(m, 0.2, pie + V(math.cos(a) * 1.2, 0, math.sin(a) * 1.2), pie + V(0, 3.6, 0), MADERA, M.Wood, DECO)
	end
	Util.cilindro(m, 0.9, 4, CFrame.lookAt(pie + V(0, 4, 0), pie + V(0, 5.2, 6)) * CFrame.Angles(0, math.pi / 2, 0), C.oro, M.Metal, DECO)
	Props.caja(m, CFrame.new(-77, yT0, -91))
	local farolillo = Util.bola(m, 0.7, V(-76, yTecho - 1.2, -82), rgb(255, 220, 160), M.Neon, DECO)
	Util.luz(farolillo, rgb(255, 196, 125), 18, 1)
end

local function desvan(padre)
	local m = padre
	local yS = Y2
	Util.bloque(m, V(120, 0.1, 44), V(1, yS + 0.05, -115), rgb(120, 90, 62), M.WoodPlanks, DECO)
	for x = -52, 56, 12 do
		Util.barra(m, 0.7, V(x, yS + 0.5, ZF + 1), V(x, YT + 14.3, -115), rgb(90, 62, 40), M.Wood, DECO)
		Util.barra(m, 0.7, V(x, yS + 0.5, ZB - 1), V(x, YT + 14.3, -115), rgb(90, 62, 40), M.Wood, DECO)
	end
	Util.bloque(m, V(120, 0.8, 0.8), V(1, YT + 13.6, -115), rgb(90, 62, 40), M.Wood, DECO)
	for _, x in { -30, 0, 30 } do
		Util.cilindroV(m, 0.1, 3, V(x, YT + 12, -115), C.metal, M.Metal, DECO)
		local b = Util.bola(m, 0.6, V(x, YT + 10.3, -115), rgb(255, 225, 170), M.Neon, DECO)
		Util.luz(b, rgb(255, 200, 140), 24, 0.7)
	end
	for _, p in { V(-45, 0, -108), V(-38, 0, -124), V(10, 0, -105), V(18, 0, -126), V(42, 0, -110) } do
		local alto = Util.entre(2.5, 4.5)
		Util.bloque(m, V(Util.entre(3, 5), alto, Util.entre(2.5, 4)), V(p.X, yS + alto / 2, p.Z), rgb(232, 230, 222), M.Fabric)
		Util.elipsoide(m, V(4.5, 1.2, 4), V(p.X, yS + alto, p.Z), rgb(232, 230, 222), M.Fabric, DECO)
	end
	local cm = V(-18, yS, -110)
	Util.bloque(m, V(4, 3, 2.5), cm + V(0, 1.5, 0), rgb(240, 200, 210), M.Wood)
	Util.cuna(m, V(4.4, 1.6, 1.4), CFrame.new(cm + V(0, 3.8, 0.65)), rgb(150, 60, 70), M.Wood, DECO)
	Util.cuna(m, V(4.4, 1.6, 1.4), CFrame.new(cm + V(0, 3.8, -0.65)) * CFrame.Angles(0, math.pi, 0), rgb(150, 60, 70), M.Wood, DECO)
	for _, x in { -1, 1 } do
		Util.bloque(m, V(0.8, 0.8, 0.1), cm + V(x, 2, 1.27), rgb(255, 220, 140), M.Neon, DECO)
	end
	local mc = CFrame.new(28, yS, -118) * CFrame.Angles(0, 2.4, 0)
	Util.bloque(m, V(2, 0.3, 2), mc * CFrame.new(0, 1.8, 0), MADERA, M.Wood)
	Util.bloque(m, V(2, 3, 0.3), mc * CFrame.new(0, 3.3, 0.9) * CFrame.Angles(math.rad(-12), 0, 0), MADERA, M.Wood, DECO)
	for _, x in { -0.9, 0.9 } do
		Util.cilindro(m, 0.3, 3, mc * CFrame.new(x, 0.25, 0) * CFrame.Angles(0, math.pi / 2, 0), MADERA, M.Wood, DECO)
	end
	Util.bloque(m, V(3, 5, 0.2), CFrame.new(-5, yS + 2.6, -129) * CFrame.Angles(math.rad(-12), 0.3, 0), rgb(200, 215, 230), M.Glass, { Reflectance = 0.5 })
	for i = 0, 2 do
		cuadro(m, CFrame.new(48 + i * 0.4, yS + 2.4, -124 + i * 0.5) * CFrame.Angles(math.rad(-10), math.pi + 0.4, 0), 3, 3.6, i == 1)
	end
	Props.caja(m, CFrame.new(-30, yS, -116))
	Props.caja(m, CFrame.new(5, yS, -122) * CFrame.Angles(0, 0.5, 0))
	Props.caja(m, CFrame.new(52, yS, -108))
	Props.pagina(m, V(-30, yS + 1.85, -116), 10)
	for _, p in { V(-56, YT + 4, -100), V(-56, YT + 4, -130), V(58, YT + 4, -100), V(58, YT + 4, -130) } do
		for k = 0, 4 do
			local a = k * 0.35
			Util.barra(m, 0.06, p, p + V(math.cos(a) * 4 * math.sign(-p.X), math.sin(a) * 3, if p.Z > -115 then -2 else 2), rgb(235, 235, 235), M.SmoothPlastic, DECO)
		end
	end
	local polvo = Util.bloque(m, V(100, 8, 36), V(0, yS + 5, -115), Color3.new(), M.SmoothPlastic, { Deco = true, Transparency = 1 })
	Util.particulas(polvo, {
		Color = ColorSequence.new(rgb(255, 240, 210)),
		LightEmission = 0.3,
		Size = NumberSequence.new(0.08),
		Transparency = NumberSequence.new(0.3),
		Lifetime = NumberRange.new(6, 10),
		Rate = 20,
		Speed = NumberRange.new(0.1, 0.3),
		SpreadAngle = Vector2.new(180, 180),
	})
	Props.marcador(V(-20, yS + 2, -115), "PuntoDesvan")
	Props.marcador(V(25, yS + 2, -115), "PuntoDesvan")
end

local function fantasmas()
	for _, p in {
		V(WXC, Y0 + 2, -110),
		V(WXC, Y1 + 2, -122),
		V(WXC, Y1 + 2, -94),
		V(WXC, Y2 + 2, -110),
		V(-30, Y2 + 2, -115),
		V(30, Y2 + 2, -115),
		V(40, Y0 + 2, -138),
		V(40, Y0 + 2, -97),
		V(-40, Y1 + 2, -132),
		V(40, Y1 + 2, -132),
		V(44, Y1 + 2, -98),
		V(-40, Y1 + 2, -97),
	} do
		Props.marcador(p, "PuntoFantasma")
	end
end

function Mansion.construir(raiz: Instance)
	local casa = Util.carpeta("Mansion", raiz)
	estructura(casa)
	fachada(casa)
	salon(casa)
	plantaBaja(casa)
	invernadero(casa)
	plantaAlta(casa)
	alaOeste(Util.carpeta("AlaOeste", casa))
	desvan(Util.carpeta("Desvan", casa))
	fantasmas()
end

return Mansion
