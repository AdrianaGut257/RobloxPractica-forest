local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Historia = require(Shared:WaitForChild("Historia"))
local Interfaz = require(script.Parent.Interfaz)

local Ventanas = {}

local T = Interfaz.TEMA
local crear = Interfaz.crear
local rgb = Color3.fromRGB

local function botonCerrar(padre: Instance, color: Color3)
	return crear("TextButton", {
		Text = "✕",
		Font = T.fuente,
		TextSize = 22,
		TextColor3 = color,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 6),
		Size = UDim2.fromOffset(36, 36),
		Modal = true,
		Parent = padre,
	})
end

local function hex(c: Color3): string
	return string.format("#%02x%02x%02x", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
end

function Ventanas.crear(gui: ScreenGui, pantalla: ScreenGui, estado: Instance, remotos: Folder)
	local jugador = Players.LocalPlayer
	local v = {}

	local diario = crear("CanvasGroup", {
		Name = "Diario",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = UDim2.fromOffset(600, 480),
		BackgroundColor3 = T.pergamino,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 5,
		Parent = gui,
	}, {
		Interfaz.esquinas(14),
		Interfaz.contorno(rgb(150, 108, 60), 3, 0),
	})
	crear("Frame", {
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.new(1, -20, 1, -20),
		BackgroundTransparency = 1,
		Parent = diario,
	}, { Interfaz.esquinas(10), Interfaz.contorno(rgb(190, 150, 95), 1, 0.2) })
	local tituloPag = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 34,
		TextColor3 = T.tinta,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, -80, 0, 40),
		Position = UDim2.fromOffset(40, 22),
		Text = "",
		Parent = diario,
	})
	local autorPag = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 19,
		TextColor3 = rgb(130, 90, 50),
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, -80, 0, 24),
		Position = UDim2.fromOffset(40, 62),
		Text = "",
		Parent = diario,
	})
	crear("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 94),
		Size = UDim2.new(0.6, 0, 0, 1),
		BackgroundColor3 = rgb(150, 108, 60),
		BorderSizePixel = 0,
		Parent = diario,
	})
	local cuerpo = crear("ScrollingFrame", {
		Position = UDim2.fromOffset(34, 108),
		Size = UDim2.new(1, -68, 1, -170),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = rgb(150, 108, 60),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = diario,
	})
	local textoPag = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 22,
		TextColor3 = T.tinta,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, -10, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		Parent = cuerpo,
	})
	local pieTxt = Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 18,
		TextColor3 = rgb(130, 90, 50),
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -18),
		Size = UDim2.new(1, -160, 0, 30),
		Text = "",
		Parent = diario,
	})
	local function flecha(texto: string, x: number, ancla: number)
		return crear("TextButton", {
			Text = texto,
			Font = T.fuente,
			TextSize = 20,
			TextColor3 = T.tinta,
			BackgroundColor3 = rgb(225, 205, 165),
			AnchorPoint = Vector2.new(ancla, 1),
			Position = UDim2.new(x, if ancla == 0 then 22 else -22, 1, -16),
			Size = UDim2.fromOffset(44, 34),
			Parent = diario,
		}, { Interfaz.esquinas(8) })
	end
	local anterior = flecha("◀", 0, 0)
	local siguiente = flecha("▶", 1, 1)
	local cerrarDiario = botonCerrar(diario, T.tinta)

	local actual: number? = nil
	local function encontradas()
		local lista = {}
		for n = 1, Historia.TOTAL_PAGINAS do
			if estado:GetAttribute("Pagina_" .. n) then
				table.insert(lista, n)
			end
		end
		return lista
	end

	local function pintarDiario()
		local lista = encontradas()
		if #lista == 0 then
			tituloPag.Text = "Tu diario"
			autorPag.Text = ""
			textoPag.Text = "Todavía no has encontrado ninguna página.\n\nBusca papeles que brillan por la mansión y el jardín: cuentan lo que pasó aquí."
			pieTxt.Text = ""
			anterior.Visible = false
			siguiente.Visible = false
			return
		end
		if not actual or not table.find(lista, actual) then
			actual = lista[#lista]
		end
		local datos = Historia.PAGINAS[actual]
		local indice = table.find(lista, actual) or 1
		tituloPag.Text = datos.titulo
		autorPag.Text = datos.autor
		textoPag.Text = datos.texto
		cuerpo.CanvasPosition = Vector2.zero
		pieTxt.Text = string.format("Página %d  ·  %d de %d encontradas", actual, #lista, Historia.TOTAL_PAGINAS)
		anterior.Visible = indice > 1
		siguiente.Visible = indice < #lista
	end

	local function moverPagina(paso: number)
		local lista = encontradas()
		local indice = table.find(lista, actual) or #lista
		local nuevo = lista[math.clamp(indice + paso, 1, #lista)]
		if nuevo then
			actual = nuevo
			pintarDiario()
		end
	end
	anterior.Activated:Connect(function()
		moverPagina(-1)
	end)
	siguiente.Activated:Connect(function()
		moverPagina(1)
	end)

	local taller = crear("CanvasGroup", {
		Name = "Taller",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = UDim2.fromOffset(620, 500),
		BackgroundColor3 = T.panel,
		BackgroundTransparency = 0.05,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 5,
		Parent = gui,
	}, { Interfaz.esquinas(14), Interfaz.contorno(T.oro, 2, 0.3) })
	Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 32,
		TextColor3 = T.oro,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, -80, 0, 40),
		Position = UDim2.fromOffset(40, 14),
		Text = "🔨 Mesa de trabajo",
		Parent = taller,
	})
	local llevasTxt = Interfaz.texto({
		Font = T.fuenteMedia,
		TextSize = 16,
		TextColor3 = T.textoSuave,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, -40, 0, 22),
		Position = UDim2.fromOffset(20, 56),
		Text = "",
		Parent = taller,
	})
	local lista = crear("ScrollingFrame", {
		Position = UDim2.fromOffset(18, 88),
		Size = UDim2.new(1, -36, 1, -104),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = T.oro,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = taller,
	}, { crear("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
	local cerrarTaller = botonCerrar(taller, T.texto)

	local tarjetas = {}
	for i, receta in Config.RECETAS do
		local tarjeta = crear("Frame", {
			Size = UDim2.new(1, -8, 0, 86),
			BackgroundColor3 = rgb(40, 34, 30),
			BackgroundTransparency = 0.1,
			LayoutOrder = i,
			Parent = lista,
		}, { Interfaz.esquinas(10), Interfaz.contorno(T.borde, 1, 0.75) })
		Interfaz.texto({
			Text = receta.icono,
			TextSize = 34,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromOffset(56, 86),
			Parent = tarjeta,
		})
		Interfaz.texto({
			Text = receta.nombre,
			TextSize = 18,
			Size = UDim2.new(1, -220, 0, 22),
			Position = UDim2.fromOffset(60, 8),
			Parent = tarjeta,
		})
		Interfaz.texto({
			Text = receta.descripcion,
			Font = T.fuenteMedia,
			TextSize = 13,
			TextColor3 = T.textoSuave,
			TextWrapped = true,
			Size = UDim2.new(1, -220, 0, 32),
			Position = UDim2.fromOffset(60, 30),
			Parent = tarjeta,
		})
		local coste = Interfaz.texto({
			Font = T.fuenteMedia,
			TextSize = 15,
			RichText = true,
			Size = UDim2.new(1, -220, 0, 20),
			Position = UDim2.fromOffset(60, 62),
			Text = "",
			Parent = tarjeta,
		})
		local boton = Interfaz.boton({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(140, 40),
			TextWrapped = true,
			Text = "Fabricar",
			Parent = tarjeta,
		})
		boton.Activated:Connect(function()
			remotos.Fabricar:FireServer(receta.id)
		end)
		tarjetas[receta.id] = { receta = receta, coste = coste, boton = boton }
	end

	local function pintarTaller()
		local partes = {}
		for _, recurso in { "Lena", "Chatarra", "Comida" } do
			table.insert(partes, Config.ICONOS_RECURSOS[recurso] .. " " .. (jugador:GetAttribute(recurso) or 0))
		end
		llevasTxt.Text = "Llevas:   " .. table.concat(partes, "     ")

		for _, t in tarjetas do
			local receta = t.receta
			local trozos = {}
			local alcanza = true
			for recurso, n in receta.coste do
				local tengo = jugador:GetAttribute(recurso) or 0
				local color = if tengo >= n then T.verde else T.rojo
				if tengo < n then
					alcanza = false
				end
				table.insert(trozos, string.format('<font color="%s">%s %d</font>', hex(color), Config.ICONOS_RECURSOS[recurso], n))
			end
			t.coste.Text = "Cuesta:  " .. table.concat(trozos, "   ")

			local desbloqueada, motivo = Config.recetaDesbloqueada(receta, estado)
			if receta.unica and jugador:GetAttribute(receta.unica) then
				t.boton.Text = "✔ Ya lo tienes"
				t.boton.BackgroundColor3 = rgb(50, 80, 50)
				t.boton.Active = false
			elseif not desbloqueada then
				t.boton.Text = "🔒 " .. (motivo or "Bloqueado")
				t.boton.TextSize = 12
				t.boton.BackgroundColor3 = rgb(55, 50, 50)
				t.boton.Active = false
			else
				t.boton.Text = "Fabricar"
				t.boton.TextSize = 15
				t.boton.BackgroundColor3 = if alcanza then rgb(120, 80, 30) else rgb(70, 52, 34)
				t.boton.Active = true
			end
		end
	end

	local victoria = crear("CanvasGroup", {
		Name = "Victoria",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = rgb(10, 8, 12),
		BackgroundTransparency = 0.15,
		GroupTransparency = 1,
		Visible = false,
		Parent = pantalla,
	})
	local contenido = crear("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.8, 0, 0.8, 0),
		BackgroundTransparency = 1,
		Parent = victoria,
	}, {
		crear("UIListLayout", {
			Padding = UDim.new(0, 18),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		crear("UISizeConstraint", { MaxSize = Vector2.new(760, 600) }),
	})
	Interfaz.texto({
		Font = T.fuenteHistoria,
		TextScaled = true,
		TextColor3 = T.oro,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 80),
		Text = "¡Has escapado!",
		LayoutOrder = 1,
		Parent = contenido,
	})
	Interfaz.texto({
		Font = T.fuenteHistoria,
		TextSize = 24,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = Historia.FINAL,
		LayoutOrder = 2,
		Parent = contenido,
	})
	local statsTxt = Interfaz.texto({
		Font = T.fuenteMedia,
		TextSize = 18,
		TextColor3 = T.textoSuave,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 24),
		Text = "",
		LayoutOrder = 3,
		Parent = contenido,
	})
	local seguir = Interfaz.boton({ Text = "Seguir mirando", Size = UDim2.fromOffset(200, 44), LayoutOrder = 4, Modal = true, Parent = contenido })

	local function cerrarTodo()
		if diario.Visible then
			Interfaz.fundido(diario, false)
		end
		if taller.Visible then
			Interfaz.fundido(taller, false)
		end
	end

	function v.mostrarPagina(n: number)
		cerrarTodo()
		actual = n
		pintarDiario()
		Interfaz.fundido(diario, true)
	end

	function v.alternarDiario()
		if diario.Visible and diario.GroupTransparency < 0.5 then
			Interfaz.fundido(diario, false)
		else
			cerrarTodo()
			pintarDiario()
			Interfaz.fundido(diario, true)
		end
	end

	function v.abrirTaller()
		cerrarTodo()
		pintarTaller()
		Interfaz.fundido(taller, true)
	end

	function v.victoria(noches: number)
		cerrarTodo()
		statsTxt.Text = string.format(
			"Noches sobrevividas: %d   ·   Páginas del diario: %d / %d",
			noches,
			estado:GetAttribute("PaginasEncontradas") or 0,
			Historia.TOTAL_PAGINAS
		)
		Interfaz.fundido(victoria, true, 1.5)
	end

	cerrarDiario.Activated:Connect(function()
		Interfaz.fundido(diario, false)
	end)
	cerrarTaller.Activated:Connect(function()
		Interfaz.fundido(taller, false)
	end)
	seguir.Activated:Connect(function()
		Interfaz.fundido(victoria, false)
	end)

	jugador.AttributeChanged:Connect(function()
		if taller.Visible then
			pintarTaller()
		end
	end)
	estado.AttributeChanged:Connect(function(nombre)
		if taller.Visible and (string.sub(nombre, 1, 6) == "Llave_" or nombre == "NivelChimenea" or nombre == "NochesSobrevividas") then
			pintarTaller()
		end
	end)

	task.spawn(function()
		while true do
			task.wait(0.5)
			if taller.Visible and taller.GroupTransparency < 0.5 then
				local personaje = jugador.Character
				local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart") :: BasePart
				local centro = estado:GetAttribute("CentroLuz")
				if raiz and typeof(centro) == "Vector3" and (raiz.Position - centro).Magnitude > 40 then
					Interfaz.fundido(taller, false)
				end
			end
		end
	end)

	return v
end

return Ventanas
