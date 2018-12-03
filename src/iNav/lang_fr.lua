local modes, config, labels = ...

-- Max 7 characters
--modes[1].t  = "! TELEM !"	-- ! TELEM !
--modes[2].t  = "HORIZON"	-- HORIZON
--modes[3].t  = "  ANGLE"	-- ANGLE
--modes[4].t  = "   ACRO"	-- ACRO
modes[5].t  = " PAS OK "	-- NOT OK
modes[6].t  = "  PRET"		-- READY
--modes[7].t  = "POS HOLD"	-- POS HOLD
--modes[8].t  = "WAYPOINT"	-- WAYPOINT
modes[9].t  = "MANUEL"		-- MANUAL
--modes[10].t = "   RTH   "	-- RTH
--modes[11].t = "! FAIL !"	-- ! FAIL !
modes[12].t = " ! GAZ ! "	-- ! THROT !
--modes[13].t = " CRUISE"	-- CRUISE

-- Max 16 characters
config[1].t  = "Vue batterie"		-- Battery View
config[2].t  = "Cellule basse"		-- Cell Low
config[3].t  = "Cellule critique"	-- Cell Critical
config[4].t  = "Alerte vocale"		-- Voice Alerts
--config[5].t  = "Feedback"			-- Feedback
config[6].t  = "Altitude Maximum"	-- Max Altitude
config[7].t  = "Variometre"			-- Variometer
config[8].t  = "Feedback RTH"		-- RTH Feedback
config[9].t  = "Feedback HeadFree"	-- HeadFree Feedback
config[10].t = "Feedback RSSI"		-- RSSI Feedback
config[11].t = "Alerte batterie"	-- Battery Alert
config[12].t = "Alerte altitude"	-- Altitude Alert
config[13].t = "Chronometre"		-- Timer
config[14].t = "Voltage Rx"			-- Rx Voltage
--config[15].t = "GPS"				-- GPS
--config[16].t = "Coordonnees GPS"	-- GPS Coordinates
--config[17].t = "Fuel critique"	-- Fuel Critical
config[18].t = "Fuel bas"			-- Fuel Low
config[19].t = "Voltage Tx"			-- Tx Voltage
config[20].t = "Capteur Vitesse"	-- Speed Sensor
config[21].t = "Alerte GPS"			-- GPS Warning
config[22].t = "Vue GPS HDOP"		-- GPS HDOP View
config[23].t = "Unite Fuel"			-- Fuel Unit
config[24].t = "Avance vario"		-- Vario Steps
config[25].t = "Mode de vue"		-- View Mode
config[26].t = "Feedback AltHold"	-- AltHold Center FB

-- Max 9 characters
config[1].l =  {[0] = "Cellule", "Total"}						-- "Cell", "Total"
config[4].l =  {[0] = "Eteint", "Critique", "Tous"}				-- "Off", "Critical", "All"
config[5].l =  {[0] = "Eteint", "Haptique", "Beeper", "Tous"}	-- "Off", "Haptic", "Beeper", "All"
config[7].l =  {[0] = "Eteint", "Graphique", "Voix", "Les deux"}-- "Off", "Graph", "Voice", "Both"
config[8].l =  {[0] = "Eteint", "Actif"}						-- "Off", "On"
config[9].l =  {[0] = "Eteint", "Actif"}						-- "Off", "On"
config[10].l = {[0] = "Eteint", "Actif"}						-- "Off", "On"
config[11].l = {[0] = "Eteint", "Critique", "Tous"}				-- "Off", "Critical", "All"
config[12].l = {[0] = "Eteint", "Actif"}						-- "Off", "On"
config[13].l = {[0] = "Eteint", "Auto", "Chrono1", "Chrono2", "Chrono3"}	-- "Off", "Auto", "Timer1", "Timer2", "Timer3"
config[14].l = {[0] = "Eteint", "Actif"}						-- "Off", "On"
--config[16].l = {[0] = "Decimal", "Deg/Min"}					-- "Decimal", "Deg/Min"
config[19].l = {[0] = "Numerique", "Graphique", "Les deux"}		-- "Number", "Graph", "Both"
--config[20].l = {[0] = "GPS", "Pitot"}							-- "GPS", "Pitot"
config[22].l = {[0] = "Graphique", "Decimal"}					-- "Graph", "Decimal"
config[23].l = {[0] = "Pourcent", "mAh", "mWh"}					-- "Percent", "mAh", "mWh"
config[25].l = {[0] = "Classique", "Pilote", "Radar"}			-- "Classic", "Pilot", "Radar"
config[26].l = {[0] = "Eteint", "Actif"}						-- "Off", "On"

-- Max 10 characters
--labels[1] = "Fuel"		-- Fuel
--labels[2] = "Battery"		-- Battery
--labels[3] = "Current"		-- Current
--labels[4] = "Altitude"	-- Altitude
--labels[5] = "Distance"	-- Distance

return 0