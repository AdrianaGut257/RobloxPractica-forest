local Util = require(script.Parent.Util)

local Terreno = {}

local M = Enum.Material
local V = Vector3.new
local rgb = Util.rgb

local function camino(x1, x2, z1, z2, material)
	Util.terreno(V((x1 + x2) / 2, -2, (z1 + z2) / 2), V(math.abs(x2 - x1), 4, math.abs(z2 - z1)), material)
end
Terreno.camino = camino

function Terreno.construir()
	local t = workspace.Terrain
	t:Clear()

	pcall(function()
		t.Decoration = true
	end)
	t.WaterColor = rgb(62, 140, 130)
	t.WaterTransparency = 0.55
	t.WaterReflectance = 0.6
	t.WaterWaveSize = 0.08
	t.WaterWaveSpeed = 6
	t:SetMaterialColor(M.Grass, rgb(92, 152, 70))
	t:SetMaterialColor(M.LeafyGrass, rgb(52, 74, 44))
	t:SetMaterialColor(M.Pavement, rgb(204, 192, 168))
	t:SetMaterialColor(M.Ground, rgb(178, 152, 118))
	t:SetMaterialColor(M.Mud, rgb(88, 66, 48))

	t:SetMaterialColor(M.Rock, rgb(96, 94, 98))
	t:SetMaterialColor(M.Sand, rgb(176, 160, 120))

	Util.terreno(V(0, -8, 20), V(1460, 16, 1460), M.LeafyGrass)
	Util.terreno(V(0, -8, 10), V(312, 16, 388), M.Grass)

	camino(-6, 6, -66, 236, M.Pavement)
	camino(-44, 44, -80, -62, M.Pavement)
	Util.terrenoCilindro(V(0, -2, 40), 4, 30, M.Pavement)

	camino(-82, -28, 36, 44, M.Ground)
	camino(28, 68, 36, 44, M.Ground)
	camino(116, 148, 36, 44, M.Ground)
	camino(-62, 62, 136, 144, M.Ground)
	camino(-124, -44, -74, -66, M.Ground)
	camino(-124, -116, -100, -66, M.Ground)
	camino(-124, -116, -156, -100, M.Ground)
	camino(44, 128, -74, -66, M.Ground)
	camino(120, 128, -110, -66, M.Ground)
	camino(-6, 6, 236, 300, M.Ground)

	Util.terrenoCilindro(V(92, -6, 40), 12, 26, M.Air)
	Util.terrenoCilindro(V(92, -12, 40), 2, 26, M.Mud)
	Util.terrenoCilindro(V(92, -6, 40), 10, 26, M.Water)
end

return Terreno
