local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Historia = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Historia"))
local Interfaz = require(script.Interfaz)
local Hud = require(script.Hud)
local Ventanas = require(script.Ventanas)

local jugador = Players.LocalPlayer
local estado = ReplicatedStorage:WaitForChild("Estado")
local remotos = ReplicatedStorage:WaitForChild("Remotos") :: Folder
local playerGui = jugador:WaitForChild("PlayerGui")

local gui = Interfaz.crear("ScreenGui", {
	Name = "InterfazMansion",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})
local pantalla = Interfaz.crear("ScreenGui", {
	Name = "InterfazPantalla",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 10,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

local hud = Hud.crear(gui, pantalla, estado)
local ventanas = Ventanas.crear(gui, pantalla, estado, remotos)

local function comer()
	remotos:WaitForChild("Comer"):FireServer()
end
hud.alComer = comer
hud.alDiario = ventanas.alternarDiario

remotos:WaitForChild("Notificar").OnClientEvent:Connect(hud.notificar)
remotos:WaitForChild("Anuncio").OnClientEvent:Connect(hud.anunciar)
remotos:WaitForChild("MostrarPagina").OnClientEvent:Connect(ventanas.mostrarPagina)
remotos:WaitForChild("AbrirTaller").OnClientEvent:Connect(ventanas.abrirTaller)
remotos:WaitForChild("Victoria").OnClientEvent:Connect(ventanas.victoria)

UserInputService.InputBegan:Connect(function(entrada, procesado)
	if procesado then
		return
	end
	if entrada.KeyCode == Enum.KeyCode.F then
		comer()
	elseif entrada.KeyCode == Enum.KeyCode.J then
		ventanas.alternarDiario()
	end
end)

task.delay(1.5, function()
	local fase = estado:GetAttribute("Fase")
	if fase == "Dia" or fase == nil then
		hud.anunciar(Historia.TITULO, "Día " .. (estado:GetAttribute("Dia") or 1) .. " · Explora antes de que caiga la noche")
	end
end)
