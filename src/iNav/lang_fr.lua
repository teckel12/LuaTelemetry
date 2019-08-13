local modes, labels = ...

-- Max 7 characters
--modes[1].t  = "! TELEM !"	-- ! TELEM !
--modes[2].t  = "HORIZON"	-- HORIZON
--modes[3].t  = "  ANGLE"	-- ANGLE
--modes[4].t  = "   ACRO"	-- ACRO
modes[5].t  = " PAS OK "	-- NOT OK
modes[6].t  = "   PRET"		-- READY
--modes[7].t  = "POS HOLD"	-- POS HOLD
--modes[8].t  = "WAYPOINT"	-- WAYPOINT
modes[9].t  = " MANUEL"		-- MANUAL
--modes[10].t = "   RTH   "	-- RTH
--modes[11].t = "! FAIL !"	-- ! FAIL !
modes[12].t = " ! GAZ ! "	-- ! THROT !
--modes[13].t = " CRUISE"	-- CRUISE

-- Max 10 characters
--labels[1] = "Fuel"		-- Fuel
labels[2] = "Batterie"		-- Battery
labels[3] = "Courant"		-- Current
--labels[4] = "Altitude"	-- Altitude
--labels[5] = "Distance"	-- Distance

local function lang(config2)
	-- Max 16 characters
	config2[1].t  = "Vue Batterie"		-- Battery View
	config2[2].t  = "Cellule Basse"		-- Cell Low
	config2[3].t  = "Cellule Critique"	-- Cell Critical
	config2[4].t  = "Alerte Vocale"		-- Voice Alerts
	--config2[5].t  = "Feedback"		-- Feedback
	config2[6].t  = "Altitude Maximum"	-- Max Altitude
	config2[7].t  = "Variometre"		-- Variometer
	config2[8].t  = "Feedback RTH"		-- RTH Feedback
	config2[9].t  = "Feedback HeadFree"	-- HeadFree Feedback
	config2[10].t = "Feedback RSSI"		-- RSSI Feedback
	config2[11].t = "Alerte Batterie"	-- Battery Alert
	config2[12].t = "Alerte Altitude"	-- Altitude Alert
	config2[13].t = "Chronometre"		-- Timer
	config2[14].t = "Voltage Rx"		-- Rx Voltage
	config2[15].t = "HUD Accueil"		-- HUD Home Icon
	--config2[16].t = "GPS"			-- GPS
	config2[17].t = "Fuel Critique"		-- Fuel Critical
	config2[18].t = "Fuel Bas"		-- Fuel Low
	config2[19].t = "Voltage Tx"		-- Tx Voltage
	config2[20].t = "Capteur Vitesse"	-- Speed Sensor
	config2[21].t = "Alerte GPS"		-- GPS Warning
	config2[22].t = "Vue GPS HDOP"		-- GPS HDOP View
	config2[23].t = "Unite Fuel"		-- Fuel Unit
	config2[24].t = "Avance Vario"		-- Vario Steps
	config2[25].t = "Mode de Vue"		-- View Mode
	config2[26].t = "Feedback AltHold"	-- AltHold Center FB
	config2[27].t = "Capacite Batterie"	-- Battery Capacity
	config2[28].t = "Graphique d'Alt"	-- Altitude Graph
	config2[29].t = "Calcul de Cellule"	-- Cell Calculation
	config2[30].t = "Symbole D'avion"	-- Aircraft Symbol
	config2[31].t = "Carte du Centre"	-- Center Map Home
	--config2[32].t = "Orientation"		-- Orientation
	config2[33].t = "Echelle Rouleau"	-- Roll Scale
	--config2[34].t = "Playback Log"	-- Playback Log

	-- Max 8 characters
	config2[1].l =  {[0] = "Cellule", "Total"}			-- "Cell", "Total"
	config2[4].l =  {[0] = "Eteint", "Critique", "Tous"}		-- "Off", "Critical", "All"
	config2[5].l =  {[0] = "Eteint", "Haptique", "Beeper", "Tous"}	-- "Off", "Haptic", "Beeper", "All"
	config2[7].l =  {[0] = "Eteint", "Graph", "Voix", "Les deux"}	-- "Off", "Graph", "Voice", "Both"
	--config2[8].l =  {[0] = "Off", "On"}				-- "Off", "On"
	--config2[9].l =  {[0] = "Off", "On"}				-- "Off", "On"
	--config2[10].l = {[0] = "Off", "On"}				-- "Off", "On"
	config2[11].l = {[0] = "Eteint", "Critique", "Tous"}		-- "Off", "Critical", "All"
	--config2[12].l = {[0] = "Off", "On"}				-- "Off", "On"
	config2[13].l = {[0] = "Eteint", "Auto", "1", "2"}		-- "Off", "Auto", "1", "2"
	--config2[14].l = {[0] = "Off", "On"}				-- "Off", "On"
	--config2[16].l = {[0] = "Decimal", "Deg/Min"}			-- "Decimal", "Deg/Min"
	config2[19].l = {[0] = "Numerique", "Graph", "Les deux"}	-- "Number", "Graph", "Both"
	--config2[20].l = {[0] = "GPS", "Pitot"}			-- "GPS", "Pitot"
	config2[22].l = {[0] = "Graph", "Decimal"}			-- "Graph", "Decimal"
	config2[23].l = {[0] = "Pourcent", "mAh", "mWh"}		-- "Percent", "mAh", "mWh"
	config2[25].l = {[0] = "Classique", "Pilote", "Radar", "Altitude"}-- "Classic", "Pilot", "Radar", "Altitude"
	--config2[26].l = {[0] = "Off", "On"}				-- "Off", "On"
	config2[28].l[0] = "Eteint"					-- "Off"
	--config2[31].l = {[0] = "Off", "On"}				-- "Off", "On"
	config2[32].l = {[0] = "Bras", "Boussole"}			-- "Launch", "Compass"
	--config2[33].l = {[0] = "Off", "On"}				-- "Off", "On"

	return {[0] = "Eteint", "Actif"}	-- "Off", "On"
end

return lang