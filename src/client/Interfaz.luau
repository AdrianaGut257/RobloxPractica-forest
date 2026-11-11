local TweenService = game:GetService("TweenService")

local Interfaz = {}

local rgb = Color3.fromRGB

Interfaz.TEMA = {
	panel = rgb(22, 20, 28),
	panelTransparencia = 0.18,
	borde = rgb(255, 214, 150),
	texto = rgb(246, 239, 226),
	textoSuave = rgb(196, 186, 170),
	oro = rgb(255, 205, 110),
	fuego = rgb(255, 140, 50),
	noche = rgb(120, 150, 255),
	rojo = rgb(235, 80, 80),
	verde = rgb(140, 225, 120),
	hambre = rgb(235, 170, 80),
	vida = rgb(225, 70, 85),
	pergamino = rgb(241, 229, 200),
	tinta = rgb(62, 42, 26),
	fuente = Enum.Font.GothamBold,
	fuenteMedia = Enum.Font.GothamMedium,
	fuenteHistoria = Enum.Font.Garamond,
}
local T = Interfaz.TEMA

function Interfaz.crear(clase: string, props, hijos)
	local obj = Instance.new(clase)
	for clave, valor in props do
		if clave ~= "Parent" then
			(obj :: any)[clave] = valor
		end
	end
	if hijos then
		for _, h in hijos do
			h.Parent = obj
		end
	end
	obj.Parent = props.Parent
	return obj
end
local crear = Interfaz.crear

function Interfaz.esquinas(radio: number?)
	return crear("UICorner", { CornerRadius = UDim.new(0, radio or 10) })
end

function Interfaz.contorno(color: Color3?, grosor: number?, transparencia: number?)
	return crear("UIStroke", {
		Color = color or T.borde,
		Thickness = grosor or 1,
		Transparency = transparencia or 0.55,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function Interfaz.relleno(px: number)
	return crear("UIPadding", {
		PaddingTop = UDim.new(0, px),
		PaddingBottom = UDim.new(0, px),
		PaddingLeft = UDim.new(0, px),
		PaddingRight = UDim.new(0, px),
	})
end

function Interfaz.panel(props)
	props.BackgroundColor3 = props.BackgroundColor3 or T.panel
	props.BackgroundTransparency = props.BackgroundTransparency or T.panelTransparencia
	props.BorderSizePixel = 0
	return crear("Frame", props, { Interfaz.esquinas(12), Interfaz.contorno() })
end

function Interfaz.texto(props)
	props.BackgroundTransparency = 1
	props.Font = props.Font or T.fuente
	props.TextColor3 = props.TextColor3 or T.texto
	props.TextSize = props.TextSize or 16
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	return crear("TextLabel", props)
end

function Interfaz.boton(props)
	props.BackgroundColor3 = props.BackgroundColor3 or rgb(70, 52, 34)
	props.BorderSizePixel = 0
	props.Font = props.Font or T.fuente
	props.TextColor3 = props.TextColor3 or T.texto
	props.TextSize = props.TextSize or 15
	props.AutoButtonColor = true
	local b = crear("TextButton", props, { Interfaz.esquinas(8), Interfaz.contorno(T.oro, 1, 0.5) })
	return b
end

function Interfaz.barra(props)
	local color = props.color or T.oro
	props.color = nil
	props.BackgroundColor3 = rgb(10, 10, 14)
	props.BackgroundTransparency = 0.35
	props.BorderSizePixel = 0
	local marco = crear("Frame", props, { Interfaz.esquinas(6) })
	local relleno = crear("Frame", {
		Name = "Relleno",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = marco,
	}, { Interfaz.esquinas(6) })
	local etiqueta = Interfaz.texto({
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextSize = 12,
		TextStrokeTransparency = 0.5,
		Text = "",
		ZIndex = 2,
		Parent = marco,
	})
	local barra = { marco = marco }
	function barra.poner(fraccion: number, texto: string?, nuevoColor: Color3?)
		local f = math.clamp(fraccion, 0, 1)
		TweenService:Create(relleno, TweenInfo.new(0.25), { Size = UDim2.fromScale(f, 1) }):Play()
		relleno.Visible = f > 0.001
		if texto then
			etiqueta.Text = texto
		end
		if nuevoColor then
			relleno.BackgroundColor3 = nuevoColor
		end
	end
	return barra
end

function Interfaz.fundido(objeto: CanvasGroup, visible: boolean, duracion: number?)
	if visible then
		objeto.Visible = true
	end
	local t = TweenService:Create(objeto, TweenInfo.new(duracion or 0.25), { GroupTransparency = if visible then 0 else 1 })
	t:Play()
	if not visible then
		t.Completed:Connect(function(estado)
			if estado == Enum.PlaybackState.Completed then
				objeto.Visible = false
			end
		end)
	end
end

function Interfaz.formatoTiempo(segundos: number): string
	local s = math.max(0, math.floor(segundos))
	return string.format("%d:%02d", s // 60, s % 60)
end

return Interfaz
