local Config = require(script.Parent.Config)

local Progreso = {}

local function tiene(estado: Instance, atributo: string): boolean
	return estado:GetAttribute(atributo) == true
end

function Progreso.objetivo(estado: Instance): string
	local fase = estado:GetAttribute("Fase")
	if fase == "Escape" then
		return "¡Amaneció y la verja está abierta! Sal del jardín por la entrada."
	end
	if fase == "UltimaNoche" then
		return "¡Resiste hasta el amanecer! El Jardinero ha despertado."
	end
	if not tiene(estado, "Pagina_1") then
		return "Lee la nota que hay sobre la mesa del Gran Salón."
	end
	if not tiene(estado, "Llave_Biblioteca") then
		return "Busca en la glorieta del jardín (al oeste de la fuente)."
	end
	if not tiene(estado, "Llave_Invernadero") then
		return "Abre la Biblioteca: se entra por la Sala de Música (planta baja, ala oeste)."
	end
	if not tiene(estado, "Llave_Estudio") then
		return "Abre el Invernadero: se entra por la Cocina (planta baja, ala este)."
	end
	if not tiene(estado, "Llave_Dormitorio") then
		return "Sube la escalera y abre el Estudio (planta alta, ala oeste)."
	end
	if not tiene(estado, "Llave_Cripta") then
		return "Abre el Dormitorio Principal (planta alta, ala este)."
	end
	if not tiene(estado, "Llave_Verja") then
		if not tiene(estado, "RaicesRetiradas") then
			local faltan = Config.NOCHE_CRIPTA - (estado:GetAttribute("NochesSobrevividas") or 0)
			if faltan <= 1 then
				return "Las raíces sellan la cripta. Sobrevive a esta noche y se retirarán."
			end
			return "Las raíces sellan la cripta. Sobrevive " .. faltan .. " noches más."
		end
		return "Las raíces se han retirado: abre la cripta del cementerio (al oeste de la mansión)."
	end
	return "Usa la Llave de la Verja en la entrada del jardín. Prepárate antes: será la última noche."
end

return Progreso
