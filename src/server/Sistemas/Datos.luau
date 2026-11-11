local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Estado = require(script.Parent.Estado)

local Datos = {}

local almacen = nil
local cargados: { [Player]: boolean } = {}

local function clave(jugador: Player): string
	return "jugador_" .. jugador.UserId
end

local function stats(jugador: Player)
	local ls = jugador:FindFirstChild("leaderstats")
	if not ls then
		return nil, nil
	end
	return ls:FindFirstChild("Escapes") :: IntValue, ls:FindFirstChild("Récord") :: IntValue
end

local function guardar(jugador: Player)
	if not almacen or not cargados[jugador] then
		return
	end
	local escapes, record = stats(jugador)
	if not escapes or not record then
		return
	end
	local ok, err = pcall(function()
		almacen:UpdateAsync(clave(jugador), function(viejo)
			viejo = if type(viejo) == "table" then viejo else {}
			return {
				Escapes = math.max(viejo.Escapes or 0, escapes.Value),
				Record = math.max(viejo.Record or 0, record.Value),
			}
		end)
	end)
	if not ok then
		warn("[Datos] No se pudo guardar a " .. jugador.Name .. ": " .. tostring(err))
	end
end

local function alEntrar(jugador: Player)
	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	local escapes = Instance.new("IntValue")
	escapes.Name = "Escapes"
	escapes.Parent = ls
	local record = Instance.new("IntValue")
	record.Name = "Récord"
	record.Parent = ls
	ls.Parent = jugador

	if not almacen then
		return
	end
	local ok, datos = pcall(function()
		return almacen:GetAsync(clave(jugador))
	end)
	if not ok then
		warn("[Datos] No se pudieron cargar los datos de " .. jugador.Name .. ": " .. tostring(datos))
		return
	end
	if type(datos) == "table" then
		escapes.Value = datos.Escapes or 0
		record.Value = datos.Record or 0
	end
	cargados[jugador] = true
end

function Datos.registrarEscape(jugador: Player)
	local escapes = stats(jugador)
	if escapes then
		escapes.Value += 1
	end
	guardar(jugador)
end

function Datos.iniciar()
	local ok, resultado = pcall(function()
		return DataStoreService:GetDataStore(Config.NOMBRE_DATASTORE)
	end)
	if ok then
		almacen = resultado
	else
		warn("[Datos] El progreso no se guardará: " .. tostring(resultado))
	end

	Players.PlayerAdded:Connect(alEntrar)
	for _, jugador in Players:GetPlayers() do
		task.spawn(alEntrar, jugador)
	end
	Players.PlayerRemoving:Connect(function(jugador)
		guardar(jugador)
		cargados[jugador] = nil
	end)
	game:BindToClose(function()
		for _, jugador in Players:GetPlayers() do
			guardar(jugador)
		end
	end)

	local function actualizarRecord()
		local noches = Estado.get("NochesSobrevividas") or 0
		for _, jugador in Players:GetPlayers() do
			local _, record = stats(jugador)
			if record and noches > record.Value then
				record.Value = noches
			end
		end
	end
	Estado.escuchar("NocheSobrevivida", actualizarRecord)
	Estado.escuchar("Escape", actualizarRecord)
end

return Datos
