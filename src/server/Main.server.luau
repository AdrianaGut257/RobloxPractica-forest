local Players = game:GetService("Players")

Players.CharacterAutoLoads = false

local Sistemas = script.Parent.Sistemas
require(Sistemas.Estado)

require(script.Parent.Mundo.Construir).construir()

require(Sistemas.Datos).iniciar()
require(Sistemas.Inventario).iniciar()
require(Sistemas.Chimenea).iniciar()
require(Sistemas.Recursos).iniciar()
require(Sistemas.Enemigos).iniciar()
require(Sistemas.Armas).iniciar()
require(Sistemas.Taller).iniciar()
require(Sistemas.Aventura).iniciar()
require(Sistemas.Ciclo).iniciar()

Players.RespawnTime = 6
Players.CharacterAutoLoads = true
for _, jugador in Players:GetPlayers() do
	if not jugador.Character then
		task.spawn(function()
			jugador:LoadCharacter()
		end)
	end
end
print("[Mansión Velarde] ¡Todo listo!")
