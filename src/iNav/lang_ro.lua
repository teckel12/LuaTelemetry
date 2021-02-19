local modes, labels = ...

-- Max 7 characters
--modes[1].t  = "! TELEM !"	-- ! TELEM !
--modes[2].t  = "HORIZON"	-- HORIZON
--modes[3].t  = "  ANGLE"	-- ANGLE
--modes[4].t  = "   ACRO"	-- ACRO
modes[5].t  = " NU OK "	-- NOT OK
modes[6].t  = "   GATA"		-- READY
modes[7].t  = "TINE POS"	-- POS HOLD
--modes[8].t  = "WAYPOINT"	-- WAYPOINT
--modes[9].t  = " MANUAL"		-- MANUAL
--modes[10].t = "   RTH   "	-- RTH
modes[11].t = "! ESUAT !"	-- ! FAIL !
modes[12].t = " ! ACC ! "	-- ! THROT !
--modes[13].t = " CRUISE"	-- CRUISE

-- Max 10 characters
labels[1] = "Energie"		-- Fuel
labels[2] = "Baterie"		-- Battery
labels[3] = "Amperaj"		-- Current
labels[4] = "Inaltime"	-- Altitude
labels[5] = "Distanta"	-- Distance

local function lang(config2)
	-- Max 16 characters
	config2[1].t  = "Vezi Baterie"		-- Battery View
	config2[2].t  = "Celula Niv.mic"		-- Cell Low
	config2[3].t  = "Celula Niv.Critic"	-- Cell Critical
	config2[4].t  = "Alerte Vocale"		-- Voice Alerts
	--config2[5].t  = "Feedback"		-- Feedback
	config2[6].t  = "Altitudine Maxima"	-- Max Altitude
	config2[7].t  = "Variometru"		-- Variometer
	config2[8].t  = "Feedback RTH"		-- RTH Feedback
	config2[9].t  = "Feedback HeadFree"	-- HeadFree Feedback
	config2[10].t = "Feedback RSSI"		-- RSSI Feedback
	config2[11].t = "Alerta Baterie"	-- Battery Alert
	config2[12].t = "Alerte Inaltime"	-- Altitude Alert
	config2[13].t = "Cronometru"		-- Timer
	config2[14].t = "Tensiune Rx"		-- Rx Voltage
	config2[15].t = "HUD Info"			-- HUD Home Icon
	--config2[16].t = "GPS"				-- GPS
	config2[17].t = "Niv.Energie Critic"		-- Fuel Critical
	config2[18].t = "Energie redusa"		-- Fuel Low
	config2[19].t = "Tensiune Tx"		-- Tx Voltage
	config2[20].t = "Senzor Viteza"	-- Speed Sensor
	config2[21].t = "Alerta GPS"		-- GPS Warning
	config2[22].t = "Vedere GPS HDOP"	-- GPS HDOP View
	config2[23].t = "Unitate Fuel"		-- Fuel Unit
	config2[24].t = "Pas Vario"			-- Vario Steps
	config2[25].t = "Tip Vizualizare"		-- View Mode
	config2[26].t = "Feedback AltHold"	-- AltHold Center FB
	config2[27].t = "Capacitate Batterie"	-- Battery Capacity
	config2[28].t = "Grafica Alt."	-- Altitude Graph
	config2[29].t = "Calcul de Celule"	-- Cell Calculation
	config2[30].t = "Simbol Avion"		-- Aircraft Symbol
	config2[31].t = "Centru Harta Acasa"	-- Center Map Home
	config2[32].t = "Orientare"		-- Orientation
	config2[33].t = "Pas Rotatie"	-- Roll Scale
	config2[34].t = "Redare Log"	-- Playback Log

	-- Max 8 characters
	config2[1].l =  {[0] = "Cellula", "Total"}			-- "Cell", "Total"
	config2[4].l =  {[0] = "Oprit", "Critic", "Toate"}		-- "Off", "Critical", "All"
	config2[5].l =  {[0] = "Oprit", "Haptic", "Biper", "Toate"}	-- "Off", "Haptic", "Beeper", "All"
	config2[7].l =  {[0] = "Oprit", "Grafic", "Voce", "Amandoua"}	-- "Off", "Graph", "Voice", "Both"
	config2[8].l =  {[0] = "Oprit", "Pornit"}				-- "Off", "On"
	config2[9].l =  {[0] = "Oprit", "Pornit"}				-- "Off", "On"
	config2[10].l = {[0] = "Oprit", "Pornit"}				-- "Off", "On"
	config2[11].l = {[0] = "Inchis", "Critic", "Tot"}		-- "Off", "Critical", "All"
	config2[12].l = {[0] = "Oprit", "Pornit"}				-- "Off", "On"
	config2[13].l = {[0] = "Inchis", "Auto", "1", "2"}		-- "Off", "Auto", "1", "2"
	config2[14].l = {[0] = "Oprit", "Pornit"}				-- "Off", "On"
	--config2[16].l = {[0] = "Decimal", "Deg/Min"}			-- "Decimal", "Deg/Min"
	config2[19].l = {[0] = "Numar", "Grafic", "Amandoua"}	-- "Number", "Graph", "Both"
	--config2[20].l = {[0] = "GPS", "Pitot"}			-- "GPS", "Pitot"
	config2[22].l = {[0] = "Grafic", "Decimal"}			-- "Graph", "Decimal"
	config2[23].l = {[0] = "Procentaj", "mAh", "mWh"}		-- "Percent", "mAh", "mWh"
	config2[25].l = {[0] = "Clasic", "Pilot", "Radar", "Inaltime"}-- "Classic", "Pilot", "Radar", "Altitude"
	config2[26].l = {[0] = "Oprit", "Pornit"}				-- "Off", "On"
	config2[28].l[0] = "Inchis"					-- "Off"
	config2[31].l = {[0] = "Oprit", "Pornit"}				-- "Off", "On"
	config2[32].l = {[0] = "Lansare", "Busola"}			-- "Launch", "Compass"
	config2[33].l = {[0] = "Oprit", "Pornit"}				-- "Off", "On"

	return {[0] = "Oprit", "Pornit"}	-- "Off", "On"
end

return lang