local Config = {}

Config.DURACION_DIA = 240
Config.DURACION_NOCHE = 150
Config.DURACION_ULTIMA_NOCHE = 210
Config.AVISO_ANOCHECER = 20

Config.NOCHE_CRIPTA = 4

Config.CHIMENEA = {
	COMBUSTIBLE_INICIAL = 100,
	POR_LENA = 12,
	GASTO_DIA = 0.25,
	GASTO_NOCHE = 0.6,
	DANO_LUZ = 18,
	NIVELES = {
		[1] = { maximo = 100, radio = 32 },
		[2] = { maximo = 160, radio = 46 },
		[3] = { maximo = 240, radio = 60 },
	},
}

Config.HAMBRE = {
	MAXIMA = 100,
	GASTO = 0.2,
	DANO_SIN_COMIDA = 2,
	POR_COMIDA = 35,
	CURA_COMIDA = 10,
	AL_REAPARECER = 60,
}

Config.RECURSOS = {
	MAX_RAMAS = 48,
	REAPARICION_RAMAS = 6,
	CAJA_RECARGA = 180,
	DESPENSA_RECARGA = 120,
	FRUTOS_POR_ARBOL = 3,
	FRUTO_RECRECE = 40,
	LENERA_MAXIMO = 10,
	LENERA_RECARGA = 20,
	ARBOL_SECO_VIDA = 6,
	LENA_POR_ARBOL = 3,
	ARBOL_RECRECE = 150,
	DURACION_SUELTO = 120,
}

Config.ARMAS = {
	Pala = { dano = 20, alcance = 7, cadencia = 0.55, tala = 1 },
	Hacha = { dano = 38, alcance = 8, cadencia = 0.6, tala = 3 },
	Ballesta = { dano = 34, alcance = 75, cadencia = 1.1, distancia = true },
}
Config.FAROL = {
	RADIO = 22,
	LENTITUD = 0.45,
}

Config.FINCA = { XMIN = -152, XMAX = 152, ZMIN = -180, ZMAX = 200 }

function Config.dentroDeFinca(pos: Vector3): boolean
	local f = Config.FINCA
	return pos.X > f.XMIN and pos.X < f.XMAX and pos.Z > f.ZMIN and pos.Z < f.ZMAX
end

Config.BOSQUE = {
	MAX_DIA = 9,
	DISTANCIA_MIN = 50,
	DISTANCIA_MAX = 170,
	CORREA = 170,
	DESAPARECER = 280,
	FANTASMA_DESVAN_RECARGA = 60,
}

Config.ENEMIGOS = {
	MAXIMO_VIVOS = 32,
	BASE = 5,
	POR_NOCHE = 3,
	VIDA_POR_NOCHE = 0.08,
	ULTIMA_NOCHE = 44,
	HUARGO_DESDE_NOCHE = 3,
	TIPOS = {
		Marchito = {
			nombre = "Marchito",
			vida = 60,
			velocidad = 11,
			dano = 10,
			cadencia = 1.2,
			escala = 1,
			desdeNoche = 1,
			peso = 10,
			aparece = "PuntoEnemigo",
			botin = { Chatarra = 0.45, Lena = 0.25 },
		},
		Espino = {
			nombre = "Espino",
			vida = 40,
			velocidad = 16,
			dano = 7,
			cadencia = 0.9,
			escala = 0.9,
			desdeNoche = 3,
			peso = 5,
			aparece = "PuntoEnemigo",
			botin = { Chatarra = 0.45, Lena = 0.25 },
		},
		Raigon = {
			nombre = "Raigón",
			vida = 220,
			velocidad = 8,
			dano = 22,
			cadencia = 1.8,
			escala = 1.6,
			desdeNoche = 5,
			peso = 2,
			aparece = "PuntoEnemigo",
			botin = { Chatarra = 0.8, Lena = 0.6 },
		},
		Lobo = {
			nombre = "Lobo Sombrío",
			forma = "lobo",
			vida = 45,
			velocidad = 19,
			dano = 8,
			cadencia = 0.9,
			escala = 1,
			desdeNoche = 1,
			peso = 6,
			aparece = "PuntoLinde",
			botin = { Comida = 0.5, Chatarra = 0.15 },
		},
		Arana = {
			nombre = "Araña Tejedora",
			forma = "arana",
			vida = 35,
			velocidad = 17,
			dano = 6,
			cadencia = 0.8,
			escala = 1,
			veneno = 2.5,
			desdeNoche = 2,
			peso = 4,
			aparece = "PuntoLinde",
			botin = { Chatarra = 0.45 },
		},
		Espectro = {
			nombre = "Espectro",
			forma = "fantasma",
			vida = 70,
			velocidad = 10,
			dano = 12,
			cadencia = 1.4,
			escala = 1,
			desdeNoche = 2,
			peso = 3,
			maximo = 4,
			aparece = "PuntoFantasma",
			botin = { Chatarra = 0.5 },
		},
		Huargo = {
			nombre = "El Huargo",
			forma = "lobo",
			vida = 650,
			velocidad = 18,
			dano = 24,
			cadencia = 1.3,
			escala = 2.3,
			especial = true,
			botin = { Comida = 1, Chatarra = 1, Lena = 1 },
			botinExtra = 6,
		},
		Jardinero = {
			nombre = "El Jardinero",
			vida = 1500,
			velocidad = 12,
			dano = 35,
			cadencia = 1.5,
			escala = 2.2,
			jefe = true,
		},
	},
}

Config.RECETAS = {
	{
		id = "Botiquin",
		nombre = "Botiquín",
		icono = "🩹",
		descripcion = "Cura toda tu vida al instante.",
		coste = { Chatarra = 3, Comida = 1 },
	},
	{
		id = "Hacha",
		nombre = "Hacha de Jardín",
		icono = "🪓",
		descripcion = "Casi el doble de daño que la pala y tala árboles secos rápido.",
		coste = { Lena = 5, Chatarra = 4 },
		unica = "TieneHacha",
	},
	{
		id = "Farol",
		nombre = "Farol de Mano",
		icono = "🏮",
		descripcion = "Da luz en la oscuridad y frena a los monstruos cercanos.",
		coste = { Chatarra = 6, Lena = 2 },
		unica = "TieneFarol",
		requiere = "Llave_Invernadero",
		pista = "Encuentra la Llave del Invernadero",
	},
	{
		id = "Chimenea2",
		nombre = "Chimenea Nivel 2",
		icono = "🔥",
		descripcion = "Más combustible y una luz más grande.",
		coste = { Lena = 10, Chatarra = 6 },
		requiereNoches = 1,
		requiereNivel = 1,
		pista = "Sobrevive a la primera noche",
	},
	{
		id = "Chimenea3",
		nombre = "Chimenea Nivel 3",
		icono = "🔥",
		descripcion = "La luz llega a casi todo el Gran Salón.",
		coste = { Lena = 18, Chatarra = 12 },
		requiere = "Llave_Dormitorio",
		requiereNivel = 2,
		pista = "Encuentra la Llave del Dormitorio y mejora antes al Nivel 2",
	},
	{
		id = "Ballesta",
		nombre = "Ballesta",
		icono = "🏹",
		descripcion = "Dispara virotes de lejos hacia donde miras. ¡Ideal contra lobos y fantasmas!",
		coste = { Chatarra = 8, Lena = 4 },
		unica = "TieneBallesta",
		requiere = "Planos_Ballesta",
		pista = "Encuentra los planos en la torre de vigilancia del bosque",
	},
}

Config.NOMBRES_RECURSOS = {
	Lena = "Leña",
	Chatarra = "Chatarra",
	Comida = "Comida",
}
Config.ICONOS_RECURSOS = {
	Lena = "🪵",
	Chatarra = "⚙️",
	Comida = "🍎",
}

function Config.recetaDesbloqueada(receta, estado: Instance)
	if receta.requiere and estado:GetAttribute(receta.requiere) ~= true then
		return false, receta.pista
	end
	if receta.requiereNoches and (estado:GetAttribute("NochesSobrevividas") or 0) < receta.requiereNoches then
		return false, receta.pista
	end
	if receta.requiereNivel and (estado:GetAttribute("NivelChimenea") or 1) ~= receta.requiereNivel then
		if (estado:GetAttribute("NivelChimenea") or 1) > receta.requiereNivel then
			return false, "Ya está mejorada"
		end
		return false, receta.pista
	end
	return true, nil
end

Config.NOMBRE_DATASTORE = "MansionVelarde_v1"

return Config
