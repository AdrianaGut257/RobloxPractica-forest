local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Historia = require(Shared:WaitForChild("Historia"))
local Progreso = require(Shared:WaitForChild("Progreso"))
local Interfaz = require(script.Parent.Interfaz)

local Hud = {}

local T = Interfaz.TEMA
local crear = Interfaz.crear
local rgb = Color3.fromRGB

function Hud.crear(gui: ScreenGui, pantalla: ScreenGui, estado: Instance)
	local jugador = Players.LocalPlayer
	local hud = {}

	local escala = crear("UIScale", { Parent = gui })
	local function ajustarEscala()
		local camara = workspace.CurrentCamera
		local alto = if camara then camara.ViewportSize.Y else 800
		escala.Scale = math.clamp(alto / 820, 0.62, 1)
	end
	ajustarEscala()
	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ajustarEscala)
	end

	local reloj = Interfaz.panel({
		Name = "Reloj",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = UDim2.fromOffset(310, 64),
		Parent = gui,
	})
	local faseTxt = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 30,
		Size = UDim2.new(1, -100, 0, 34),
		Position = UDim2.fromOffset(12, 3),
		Text = "",
		Parent = reloj,
	})
	local tiempoTxt = Interfaz.texto({
		TextSize = 18,
		TextColor3 = T.textoSuave,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.fromOffset(80, 34),
		Position = UDim2.new(1, -92, 0, 3),
		Text = "",
		Parent = reloj,
	})
	local barraTiempo = Interfaz.barra({
		Position = UDim2.new(0, 12, 0, 42),
		Size = UDim2.new(1, -24, 0, 10),
		Parent = reloj,
		color = T.oro,
	})

	local objetivo = Interfaz.panel({
		Name = "Objetivo",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 80),
		Size = UDim2.fromOffset(540, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0.35,
		Parent = gui,
	})
	Interfaz.relleno(8).Parent = objetivo
	local objetivoTxt = Interfaz.texto({
		Font = T.fuenteMedia,
		TextSize = 16,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		Parent = objetivo,
	})

	local izquierda = crear("Frame", {
		Name = "Izquierda",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(260, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		crear("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	local panelFuego = Interfaz.panel({ Size = UDim2.fromOffset(260, 108), LayoutOrder = 1, Parent = izquierda })
	local fuegoTitulo = Interfaz.texto({ Text = "🔥 CHIMENEA", TextSize = 16, Size = UDim2.new(1, -24, 0, 22), Position = UDim2.fromOffset(12, 8), Parent = panelFuego })
	local barraFuego = Interfaz.barra({ Position = UDim2.new(0, 12, 0, 36), Size = UDim2.new(1, -24, 0, 18), Parent = panelFuego, color = T.fuego })
	local luzTxt = Interfaz.texto({ Font = T.fuenteMedia, TextSize = 14, Size = UDim2.new(1, -24, 0, 20), Position = UDim2.fromOffset(12, 60), Text = "", Parent = panelFuego })
	local enemigosTxt = Interfaz.texto({ Font = T.fuenteMedia, TextSize = 13, TextColor3 = T.textoSuave, Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(12, 82), Text = "", Parent = panelFuego })

	local panelVida = Interfaz.panel({ Size = UDim2.fromOffset(260, 74), LayoutOrder = 2, Parent = izquierda })
	Interfaz.texto({ Text = "❤️", TextSize = 16, Size = UDim2.fromOffset(24, 22), Position = UDim2.fromOffset(10, 10), Parent = panelVida })
	local barraVida = Interfaz.barra({ Position = UDim2.new(0, 38, 0, 12), Size = UDim2.new(1, -50, 0, 18), Parent = panelVida, color = T.vida })
	Interfaz.texto({ Text = "🍖", TextSize = 16, Size = UDim2.fromOffset(24, 22), Position = UDim2.fromOffset(10, 42), Parent = panelVida })
	local barraHambre = Interfaz.barra({ Position = UDim2.new(0, 38, 0, 44), Size = UDim2.new(1, -50, 0, 18), Parent = panelVida, color = T.hambre })

	local mochila = Interfaz.panel({
		Name = "Mochila",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(210, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = gui,
	})
	Interfaz.relleno(12).Parent = mochila
	crear("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = mochila })
	Interfaz.texto({ Text = "🎒 MOCHILA", TextSize = 15, TextColor3 = T.oro, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1, Parent = mochila })
	local filas = {}
	for i, recurso in { "Lena", "Chatarra", "Comida" } do
		filas[recurso] = Interfaz.texto({
			Font = T.fuenteMedia,
			TextSize = 16,
			Size = UDim2.new(1, 0, 0, 22),
			LayoutOrder = 1 + i,
			Text = "",
			Parent = mochila,
		})
	end
	local botonComer = Interfaz.boton({ Text = "🍎 Comer  [F]", Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 5, Parent = mochila })
	crear("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.borde, BackgroundTransparency = 0.7, BorderSizePixel = 0, LayoutOrder = 6, Parent = mochila })
	local llavesTxt = Interfaz.texto({ Font = T.fuenteMedia, TextSize = 15, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 7, Text = "", Parent = mochila })
	local paginasTxt = Interfaz.texto({ Font = T.fuenteMedia, TextSize = 15, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 8, Text = "", Parent = mochila })
	local botonDiario = Interfaz.boton({ Text = "📖 Diario  [J]", Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 9, Parent = mochila })

	hud.alComer = function() end
	hud.alDiario = function() end
	botonComer.Activated:Connect(function()
		hud.alComer()
	end)
	botonDiario.Activated:Connect(function()
		hud.alDiario()
	end)

	local avisos = crear("Frame", {
		Name = "Avisos",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -96),
		Size = UDim2.fromOffset(560, 240),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		crear("UIListLayout", {
			Padding = UDim.new(0, 6),
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local contadorAvisos = 0

	function hud.notificar(texto: string, color: Color3?)
		contadorAvisos += 1
		local grupo = crear("CanvasGroup", {
			Size = UDim2.fromOffset(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = T.panel,
			BackgroundTransparency = 0.2,
			GroupTransparency = 1,
			LayoutOrder = contadorAvisos,
			Parent = avisos,
		}, { Interfaz.esquinas(10), Interfaz.relleno(8) })
		Interfaz.texto({
			Font = T.fuenteMedia,
			TextSize = 16,
			TextColor3 = color or T.texto,
			TextWrapped = true,
			Size = UDim2.fromOffset(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = texto,
			Parent = grupo,
		})
		local limite = crear("UISizeConstraint", { MaxSize = Vector2.new(540, math.huge) })
		limite.Parent = grupo:FindFirstChildOfClass("TextLabel")
		TweenService:Create(grupo, TweenInfo.new(0.25), { GroupTransparency = 0 }):Play()
		local hijos = {}
		for _, h in avisos:GetChildren() do
			if h:IsA("CanvasGroup") then
				table.insert(hijos, h)
			end
		end
		if #hijos > 5 then
			table.sort(hijos, function(a, b)
				return a.LayoutOrder < b.LayoutOrder
			end)
			hijos[1]:Destroy()
		end
		local duracion = math.clamp(#texto / 18, 4, 9)
		task.delay(duracion, function()
			if grupo.Parent then
				local t = TweenService:Create(grupo, TweenInfo.new(0.5), { GroupTransparency = 1 })
				t:Play()
				t.Completed:Wait()
				grupo:Destroy()
			end
		end)
	end

	local anuncio = crear("CanvasGroup", {
		Name = "Anuncio",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.36),
		Size = UDim2.fromOffset(820, 150),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		Parent = gui,
	})
	local anuncioTitulo = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 64,
		TextColor3 = T.oro,
		TextStrokeTransparency = 0.3,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 70),
		Text = "",
		Parent = anuncio,
	})
	local anuncioSub = Interfaz.texto({
		Font = T.fuenteMedia,
		TextSize = 20,
		TextStrokeTransparency = 0.4,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 70),
		Position = UDim2.fromOffset(0, 74),
		Text = "",
		Parent = anuncio,
	})
	local idAnuncio = 0
	function hud.anunciar(titulo: string, subtitulo: string?)
		idAnuncio += 1
		local este = idAnuncio
		anuncioTitulo.Text = titulo
		anuncioSub.Text = subtitulo or ""
		Interfaz.fundido(anuncio, true, 0.6)
		task.delay(5, function()
			if idAnuncio == este then
				Interfaz.fundido(anuncio, false, 1.2)
			end
		end)
	end

	local dano = crear("Frame", {
		Name = "Dano",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = rgb(180, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = pantalla,
	})

	local function refrescarEstado()
		local fase = estado:GetAttribute("Fase") or "Dia"
		local restante = estado:GetAttribute("TiempoRestante") or 0
		local duracion = estado:GetAttribute("DuracionFase") or 1
		if fase == "Dia" then
			faseTxt.Text = "☀️  Día " .. (estado:GetAttribute("Dia") or 1)
			barraTiempo.poner(restante / duracion, nil, T.oro)
		elseif fase == "Noche" then
			faseTxt.Text = "🌙  Noche " .. (estado:GetAttribute("NocheActual") or 1)
			barraTiempo.poner(restante / duracion, nil, T.noche)
		elseif fase == "UltimaNoche" then
			faseTxt.Text = "🌕  La última noche"
			barraTiempo.poner(restante / duracion, nil, T.rojo)
		else
			faseTxt.Text = "🌅  ¡Amanece!"
			barraTiempo.poner(1, nil, T.verde)
		end
		tiempoTxt.Text = if fase == "Escape" then "" else Interfaz.formatoTiempo(restante)
		objetivoTxt.Text = "🎯  " .. Progreso.objetivo(estado)

		local combustible = estado:GetAttribute("Combustible") or 0
		local maximo = estado:GetAttribute("CombustibleMax") or 100
		local nivel = estado:GetAttribute("NivelChimenea") or 1
		fuegoTitulo.Text = "🔥 CHIMENEA  ·  Nivel " .. nivel
		local colorFuego = if combustible < maximo * 0.25 then T.rojo else T.fuego
		barraFuego.poner(combustible / maximo, string.format("%d / %d", math.floor(combustible), maximo), colorFuego)

		local enemigos = estado:GetAttribute("EnemigosVivos") or 0
		enemigosTxt.Text = if enemigos > 0 then "👹 " .. enemigos .. (if enemigos == 1 then " monstruo rondando" else " monstruos rondando") else ""

		local llaves = 0
		for _, id in Historia.ORDEN_LLAVES do
			if estado:GetAttribute("Llave_" .. id) then
				llaves += 1
			end
		end
		llavesTxt.Text = string.format("🗝️ Llaves  %d / %d", llaves, #Historia.ORDEN_LLAVES)
		paginasTxt.Text = string.format("📜 Páginas  %d / %d", estado:GetAttribute("PaginasEncontradas") or 0, Historia.TOTAL_PAGINAS)
	end

	local function refrescarJugador()
		for recurso, fila in filas do
			fila.Text = string.format("%s  %s:  %d", Config.ICONOS_RECURSOS[recurso], Config.NOMBRES_RECURSOS[recurso], jugador:GetAttribute(recurso) or 0)
		end
		local hambre = jugador:GetAttribute("Hambre") or 100
		barraHambre.poner(hambre / Config.HAMBRE.MAXIMA, string.format("Hambre  %d%%", math.floor(hambre)), if hambre < 20 then T.rojo else T.hambre)
	end

	local function refrescarLuz()
		local fase = estado:GetAttribute("Fase") or "Dia"
		local combustible = estado:GetAttribute("Combustible") or 0
		local personaje = jugador.Character
		local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart
		local centro = estado:GetAttribute("CentroLuz")
		local radio = estado:GetAttribute("RadioLuz") or 0
		local protegido = raiz ~= nil and typeof(centro) == "Vector3" and radio > 0 and (raiz.Position - centro).Magnitude <= radio
		if combustible <= 0 then
			luzTxt.Text = "🌑 ¡El fuego está apagado!"
			luzTxt.TextColor3 = T.rojo
		elseif protegido then
			luzTxt.Text = "✨ A salvo junto al fuego"
			luzTxt.TextColor3 = T.verde
		elseif (fase == "Dia" or fase == "Escape") and raiz and Config.dentroDeFinca(raiz.Position) then
			luzTxt.Text = "☀️ De día el jardín es seguro"
			luzTxt.TextColor3 = T.textoSuave
		elseif fase == "Dia" or fase == "Escape" then
			luzTxt.Text = "🌲 Estás en el bosque: ¡cuidado con los lobos!"
			luzTxt.TextColor3 = rgb(255, 200, 120)
		else
			luzTxt.Text = "⚠️ Estás fuera de la luz"
			luzTxt.TextColor3 = rgb(255, 170, 90)
		end
	end

	local function conectarPersonaje(personaje: Model)
		local hum = personaje:WaitForChild("Humanoid", 10) :: Humanoid
		if not hum then
			return
		end
		local anterior = hum.Health
		local function vida()
			barraVida.poner(hum.Health / hum.MaxHealth, string.format("Vida  %d", math.ceil(hum.Health)))
			if hum.Health < anterior - 0.5 then
				dano.BackgroundTransparency = 0.75
				TweenService:Create(dano, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
			end
			anterior = hum.Health
		end
		vida()
		hum.HealthChanged:Connect(vida)
	end

	estado.AttributeChanged:Connect(refrescarEstado)
	jugador.AttributeChanged:Connect(refrescarJugador)
	jugador.CharacterAdded:Connect(conectarPersonaje)
	if jugador.Character then
		task.spawn(conectarPersonaje, jugador.Character)
	end
	refrescarEstado()
	refrescarJugador()
	task.spawn(function()
		while true do
			refrescarLuz()
			task.wait(0.25)
		end
	end)

	return hud
end

return Hud
