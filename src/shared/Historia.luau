local Historia = {}

Historia.TITULO = "La Mansión Velarde"

Historia.INTRO = "Te perdiste en la niebla y encontraste una verja abierta. "
	.. "Al entrar, se cerró de golpe detrás de ti. Bienvenido a la Mansión Velarde."

Historia.NIEBLA = "🌫️ La niebla te envuelve... y vuelves a aparecer delante de la verja. El bosque no te deja salir."

Historia.FINAL = "Al amanecer, el jardín se queda en silencio. La verja chirría y se abre. "
	.. "Detrás de ti, los cerezos siguen floreciendo... y desde una ventana de la mansión, "
	.. "alguien te mira marchar."

Historia.LLAVES = {
	Biblioteca = "Llave de la Biblioteca",
	Invernadero = "Llave del Invernadero",
	Estudio = "Llave del Estudio",
	Dormitorio = "Llave del Dormitorio",
	Cripta = "Llave de la Cripta",
	Verja = "Llave de la Verja",
}
Historia.ORDEN_LLAVES = { "Biblioteca", "Invernadero", "Estudio", "Dormitorio", "Cripta", "Verja" }

Historia.PAGINAS = {
	[1] = {
		titulo = "Nota sobre la mesa",
		autor = "Letra temblorosa, sin firma",
		texto = "A quien encuentre esta casa:\n\n"
			.. "No te alejes del fuego cuando caiga la noche. Cuando el sol se pone, el jardín despierta.\n\n"
			.. "La chimenea los mantiene lejos: aliméntala con leña y no dejes que se apague nunca.\n\n"
			.. "La verja solo se abre con una llave. Busca en la casa. Busca en el jardín. "
			.. "Empieza por la glorieta, donde ella leía por las tardes.",
	},
	[2] = {
		titulo = "Diario de Elena Velarde",
		autor = "3 de abril de 1921 · Sala de Música",
		texto = "Aurelio me ha regalado el jardín más hermoso del mundo. Rosas de seis colores, "
			.. "un estanque lleno de nenúfares y cerezos que florecen todo el año.\n\n"
			.. "Por las tardes toco el piano con las ventanas abiertas y los pájaros me contestan. "
			.. "Él dice que todo esto es para mí.\n\nNunca he sido tan feliz.",
	},
	[3] = {
		titulo = "Diario de Elena Velarde",
		autor = "9 de agosto de 1921 · La glorieta",
		texto = "El médico ha vuelto a venir. Toso sangre y Aurelio ya no duerme.\n\n"
			.. "Hoy lo he visto en la biblioteca rodeado de mapas, hablando de una flor que crece "
			.. "en una selva sin nombre. «La flor que nunca muere», la llama.\n\n"
			.. "He escondido aquí la llave de la biblioteca, en mi glorieta. No quiero que se marche.",
	},
	[4] = {
		titulo = "Cuaderno de Aurelio Velarde",
		autor = "La expedición · Biblioteca",
		texto = "La encontré. Tres meses río arriba, y allí estaba: una semilla negra, caliente como una brasa.\n\n"
			.. "Los del poblado no quisieron tocarla. Dijeron que esa flor no cura: cambia una vida por otra.\n\n"
			.. "Supersticiones. Elena no verá otro invierno si no hago algo. "
			.. "La plantaré en el invernadero esta misma noche.",
	},
	[5] = {
		titulo = "Cuaderno de Aurelio Velarde",
		autor = "Primavera de 1922 · Invernadero",
		texto = "¡Ha funcionado! Elena pasea por el jardín sin ayuda. La flor negra ya llega al techo "
			.. "y su perfume llena toda la casa.\n\n"
			.. "Pero los criados se quejan: dicen que las plantas se mueven de noche. "
			.. "Anoche desapareció Martín, el mozo de cuadra. Encontraron sus botas junto a los rosales, llenas de tierra.",
	},
	[6] = {
		titulo = "Nota de Tomás, el jardinero",
		autor = "Clavada en el centro del laberinto",
		texto = "No vuelvo a entrar en el invernadero. He visto a Martín. Caminaba entre los setos "
			.. "con la piel como corteza y los ojos encendidos. Ya no era él.\n\n"
			.. "Les da miedo el fuego, eso lo sé: no se acercan a la chimenea.\n\n"
			.. "Si alguien lee esto: de noche, junto al fuego. Siempre junto al fuego.",
	},
	[7] = {
		titulo = "Cuaderno de Aurelio Velarde",
		autor = "Última entrada · Estudio",
		texto = "Ya son demasiados. Todo el servicio, y los vecinos que vinieron a buscarlos...\n\n"
			.. "Si salen de aquí, el mundo entero será un jardín. He cerrado la verja y he guardado la llave "
			.. "en la cripta de la familia.\n\n"
			.. "Las raíces la protegen: solo se retiran cuando el jardín se cansa, tras muchas noches. "
			.. "Que Dios me perdone.",
	},
	[8] = {
		titulo = "Diario de Elena Velarde",
		autor = "La última página · Dormitorio",
		texto = "Aurelio ya no habla. Pasa las noches en el jardín, podando rosas a oscuras.\n\n"
			.. "Esta mañana tenía tierra bajo las uñas y hojas en el pelo. Me ha mirado como se mira una flor.\n\n"
			.. "Dejo la llave de la cripta bajo mi almohada, por si alguien consigue lo que yo no pude: salir.",
	},
	[9] = {
		titulo = "Inscripción en la tumba",
		autor = "Cripta de la familia Velarde",
		texto = "ELENA VELARDE · 1898 – 1922\n«La flor cambió una vida por otra.»\n\n"
			.. "Debajo, alguien ha rayado la piedra con un cuchillo:\n\n"
			.. "«Aurelio nunca murió. Ahora es el Jardinero y cuida su jardín cada noche. "
			.. "Si metes la llave en la verja, todo el jardín despertará por última vez. "
			.. "Resiste hasta el amanecer y la verja se abrirá.»",
	},
	[10] = {
		titulo = "Carta de la señorita Inés",
		autor = "La institutriz · Desván",
		texto = "Querida hermana:\n\n"
			.. "Desde que la señora Elena murió, alguien camina por el desván cada noche. "
			.. "Los niños dicen que es «la dama de blanco» y que solo quiere jugar.\n\n"
			.. "Yo la he visto. Flota entre los baúles y atraviesa las paredes como si fueran niebla. "
			.. "Tiene los ojos de un azul que quema.\n\nLa luz la espanta. Si subes, no subas sin fuego.",
	},
	[11] = {
		titulo = "Diario de un explorador",
		autor = "Campamento abandonado · El bosque",
		texto = "Día 3. Salimos por el hueco del muro para buscar ayuda. Hemos caminado en línea recta "
			.. "y, cuando la niebla se ha cerrado, hemos vuelto a aparecer delante de la verja. Otra vez.\n\n"
			.. "De día los lobos nos siguen de lejos. No entran en el jardín: le tienen miedo al muro.\n\n"
			.. "Al norte hay una cueva llena de telarañas. Ramón entró a por las cajas. No ha vuelto.",
	},
	[12] = {
		titulo = "Cuaderno del leñador",
		autor = "Cabaña del bosque",
		texto = "Las hachas no bastan contra lo que sale del bosque. Hay que darles antes de que se acerquen.\n\n"
			.. "He dibujado los planos de una ballesta con lo que se puede encontrar por aquí: chatarra y buena madera.\n\n"
			.. "Los he escondido arriba, en la torre de vigilancia, donde los lobos no pueden subir.",
	},
	[13] = {
		titulo = "Lápida de Sultán",
		autor = "Capilla en ruinas · El bosque",
		texto = "«SULTÁN · El mejor amigo de la familia»\n\n"
			.. "Debajo, con otra letra: «No está aquí. Bebió del agua del invernadero la noche en que "
			.. "Aurelio regó la flor negra. Creció, y creció, y se fue al bosque.\n\n"
			.. "Ahora lo llaman el Huargo. Cuando aúlla, todos los lobos le siguen hacia la casa.»",
	},
	[14] = {
		titulo = "Notas de laboratorio",
		autor = "Aurelio Velarde · Laboratorio del ala oeste",
		texto = "Muestra 31: las raíces de la flor negra ya no caben en el invernadero. "
			.. "Pasan bajo el muro y llegan hasta el bosque.\n\n"
			.. "Muestra 32: el bosque entero es ahora su raíz. Los caminos se doblan: quien intenta salir "
			.. "por la niebla vuelve siempre a la verja.\n\n"
			.. "Solo hay una salida: la verja, con su llave, y al amanecer.",
	},
}

Historia.HALLAZGOS = {
	Planos_Ballesta = {
		nombre = "Planos de la Ballesta",
		icono = "📐",
		aviso = "¡Ya se puede fabricar la Ballesta en la mesa de trabajo!",
	},
}
Historia.TOTAL_PAGINAS = #Historia.PAGINAS

return Historia
