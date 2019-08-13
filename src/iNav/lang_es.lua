local modes, labels = ...

-- Max 7 characters
--modes[1].t  = "! TELEM !"	-- ! TELEM !
--modes[2].t  = "HORIZON"	-- HORIZON
--modes[3].t  = "  ANGLE"	-- ANGLE
--modes[4].t  = "   ACRO"	-- ACRO
modes[5].t  = " NO OK "		-- NOT OK
modes[6].t  = "  LISTO"		-- READY
--modes[7].t  = "POS HOLD"	-- POS HOLD
--modes[8].t  = "WAYPOINT"	-- WAYPOINT
--modes[9].t  = " MANUAL"	-- MANUAL
--modes[10].t = "   RTH   "	-- RTH
--modes[11].t = "! FAIL !"	-- ! FAIL !
modes[12].t = " ! GAS ! "	-- ! THROT !
--modes[13].t = " CRUISE"	-- CRUISE

-- Max 10 characters
labels[1] = "Bateria"		-- Fuel
labels[2] = "Tension"		-- Battery
labels[3] = "Consumo"		-- Current
labels[4] = "Altitud"		-- Altitude
labels[5] = "Distancia"		-- Distance

local function lang(config2)
	-- Max 16 characters
	config2[1].t  = "Bateria"		-- Battery View
	config2[2].t  = "Celda baja"		-- Cell Low
	config2[3].t  = "Celda Critica"		-- Cell Critical
	config2[4].t  = "Alerta Voces"		-- Voice Alerts
	--config2[5].t  = "Feedback"		-- Feedback
	config2[6].t  = "Max Altura"		-- Max Altitude
	config2[7].t  = "Variometro"		-- Variometer
	--config2[8].t  = "RTH Feedback"	-- RTH Feedback
	--config2[9].t  = "HeadFree Feedback"	-- HeadFree Feedback
	--config2[10].t = "RSSI Feedback"	-- RSSI Feedback
	config2[11].t = "Bateria Alerta"	-- Battery Alert
	config2[12].t = "Altitud Alerta"	-- Altitude Alert
	--config2[13].t = "Timer"		-- Timer
	config2[14].t = "Rx Voltaje"		-- Rx Voltage
	config2[15].t = "Inicio de HUD"		-- HUD Home Icon
	--config2[16].t = "GPS"			-- GPS
	config2[17].t = "Bateria Critica"	-- Fuel Critical
	config2[18].t = "Bateria Baja"		-- Fuel Low
	config2[19].t = "Tx Voltaje"		-- Tx Voltage
	config2[20].t = "Sensor Velocidad"	-- Speed Sensor
	config2[21].t = "GPS Aviso"		-- GPS Warning
	config2[22].t = "GPS HDOP"		-- GPS HDOP View
	config2[23].t = "Capacidad"		-- Fuel Unit
	config2[24].t = "Vario Pasos"		-- Vario Steps
	config2[25].t = "Vista"			-- View Mode
	config2[26].t = "AlH Centrado FB."	-- AltHold Center FB
	config2[27].t = "Capacidad Bateria"	-- Battery Capacity
	config2[28].t = "Grafico Altura"	-- Altitude Graph
	config2[29].t = "Calculo Celda"		-- Cell Calculation
	config2[30].t = "Simbolo Aeronave"	-- Aircraft Symbol
	config2[31].t = "Mapa del Centro"	-- Center Map Home
	config2[32].t = "Orientacion"		-- Orientation
	--config2[33].t = "Roll Scale"		-- Roll Scale
	--config2[34].t = "Playback Log"	-- Playback Log

	-- Max 8 characters
	--config2[1].l =  {[0] = "Cell", "Total"}			-- "Cell", "Total"
	config2[4].l =  {[0] = "Off", "Critico", "Todo"}		-- "Off", "Critical", "All"
	config2[5].l =  {[0] = "Off", "Haptic", "Beeper", "Todo"}	-- "Off", "Haptic", "Beeper", "All"
	config2[7].l =  {[0] = "Off", "Grafico", "Voz", "Ambos"}	-- "Off", "Graph", "Voice", "Both"
	--config2[8].l =  {[0] = "Off", "On"}				-- "Off", "On"
	--config2[9].l =  {[0] = "Off", "On"}				-- "Off", "On"
	--config2[10].l = {[0] = "Off", "On"}				-- "Off", "On"
	config2[11].l = {[0] = "Off", "Critico", "Todo"}		-- "Off", "Critical", "All"
	--config2[12].l = {[0] = "Off", "On"}				-- "Off", "On"
	--config2[13].l = {[0] = "Off", "Auto", "1", "2"}		-- "Off", "Auto", "1", "2"
	--config2[14].l = {[0] = "Off", "On"}				-- "Off", "On"
	config2[16].l = {[0] = "Decimal", "Grados"}			-- "Decimal", "Deg/Min"
	config2[19].l = {[0] = "Numero", "Grafico", "Ambos"}		-- "Number", "Graph", "Both"
	--config2[20].l = {[0] = "GPS", "Pitot"}			-- "GPS", "Pitot"
	config2[22].l = {[0] = "Grafico", "Decimal"}			-- "Graph", "Decimal"
	--config2[23].l = {[0] = "Percent", "mAh", "mWh"}		-- "Percent", "mAh", "mWh"
	config2[25].l = {[0] = "Clasica", "Pilot", "Radar", "Altitud"}	-- "Classic", "Pilot", "Radar", "Altitude"
	--config2[26].l = {[0] = "Off", "On"}				-- "Off", "On"
	--config2[28].l[0] = "Off"					-- "Off"
	--config2[31].l = {[0] = "Off", "On"}				-- "Off", "On"
	config2[32].l = {[0] = "Brazo", "Brujula"}			-- "Launch", "Compass"
	--config2[33].l = {[0] = "Off", "On"}				-- "Off", "On"

	return {[0] = "Off", "On"}	-- "Off", "On"
end

return lang