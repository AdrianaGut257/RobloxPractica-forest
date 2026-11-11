local Util = require(script.Parent.Util)
local Props = require(script.Parent.Props)
local Terreno = require(script.Parent.Terreno)
local Jardin = require(script.Parent.Jardin)
local Exterior = require(script.Parent.Exterior)
local Mansion = require(script.Parent.Mansion)
local Bosque = require(script.Parent.Bosque)

local Construir = {}

Construir.NOMBRE = "MansionVelarde"

function Construir.construir(): Instance
	local existente = workspace:FindFirstChild(Construir.NOMBRE)
	if existente then
		print("[Mapa] Usando el mapa que ya existe en Workspace")
		return existente
	end

	local inicio = os.clock()
	local raiz = Instance.new("Folder")
	raiz.Name = Construir.NOMBRE
	Props.marcadores = Util.carpeta("Marcadores", raiz)

	Terreno.construir()
	Jardin.construir(raiz)
	Exterior.construir(raiz)
	Bosque.construir(raiz)
	Mansion.construir(raiz)

	raiz.Parent = workspace
	print(string.format("[Mapa] Mansión construida en %.1f s", os.clock() - inicio))
	return raiz
end

return Construir
