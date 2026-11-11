local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Estado = {}

local REMOTOS = {
	"Notificar",
	"Anuncio",
	"MostrarPagina",
	"AbrirTaller",
	"Victoria",
	"Fabricar",
	"Comer",
}

local obj = Instance.new("Configuration")
obj.Name = "Estado"
obj.Parent = ReplicatedStorage
Estado.obj = obj

local carpeta = Instance.new("Folder")
carpeta.Name = "Remotos"
Estado.remotos = {} :: { [string]: RemoteEvent }
for _, nombre in REMOTOS do
	local r = Instance.new("RemoteEvent")
	r.Name = nombre
	r.Parent = carpeta
	Estado.remotos[nombre] = r
end
carpeta.Parent = ReplicatedStorage

function Estado.get(clave: string)
	return obj:GetAttribute(clave)
end

function Estado.set(clave: string, valor)
	obj:SetAttribute(clave, valor)
end

function Estado.notificar(jugador: Player?, texto: string, color: Color3?)
	if jugador then
		Estado.remotos.Notificar:FireClient(jugador, texto, color)
	else
		Estado.remotos.Notificar:FireAllClients(texto, color)
	end
end

function Estado.anunciar(titulo: string, subtitulo: string?, jugador: Player?)
	if jugador then
		Estado.remotos.Anuncio:FireClient(jugador, titulo, subtitulo)
	else
		Estado.remotos.Anuncio:FireAllClients(titulo, subtitulo)
	end
end

local oyentes = {}

function Estado.escuchar(evento: string, funcion)
	oyentes[evento] = oyentes[evento] or {}
	table.insert(oyentes[evento], funcion)
end

function Estado.emitir(evento: string, ...)
	for _, funcion in oyentes[evento] or {} do
		task.spawn(funcion, ...)
	end
end

return Estado
