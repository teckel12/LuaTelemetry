local modes, labels = ...

-- Max 7 characters
--modes[1].t  = "! TELEM !"	-- ! TELEM !
--modes[2].t  = "HORIZON"	-- HORIZON
--modes[3].t  = "  ANGLE"	-- ANGLE
--modes[4].t  = "   ACRO"	-- ACRO
modes[5].t  = "NICH OK"		-- NOT OK
modes[6].t  = " BEREIT"		-- READY
--modes[7].t  = "POS HOLD"	-- POS HOLD
modes[8].t  = "WEGPUN."		-- WAYPOINT
modes[9].t  = "MANUELL"		-- MANUAL
--modes[10].t = "   RTH   "	-- RTH
--modes[11].t = "! FAIL !"	-- ! FAIL !
modes[12].t = " ! GAS ! "	-- ! THROT !
--modes[13].t = " CRUISE"	-- CRUISE

-- Max 10 characters
labels[1] = "Kapazitaet"	-- Fuel
labels[2] = "Batterie"		-- Battery
labels[3] = "Strom"		-- Current
labels[4] = "Hoehe"		-- Altitude
labels[5] = "Entfernung"	-- Distance

local function lang(config2)
	-- Max 16 characters
	config2[1].t  = "Batterie"		-- Battery View
	config2[2].t  = "Zelle Niedrig"		-- Cell Low
	config2[3].t  = "Zelle Kritisch"	-- Cell Critical
	config2[4].t  = "Sprach Alarme"		-- Voice Alerts
	config2[5].t  = "Meldungen"		-- Feedback
	config2[6].t  = "Max Hoehe"		-- Max Altitude
	--config2[7].t  = "Variometer"		-- Variometer
	config2[8].t  = "RTH Meldung"		-- RTH Feedback
	config2[9].t  = "HeadFree Meld."	-- HeadFree Feedback
	config2[10].t = "RSSI Meldung"		-- RSSI Feedback
	config2[11].t = "Bat. Warnung"		-- Battery Alert
	config2[12].t = "Hoehen Warnung"	-- Altitude Alert
	--config2[13].t = "Timer"		-- Timer
	config2[14].t = "Rx Spng."		-- Rx Voltage
	config2[15].t = "Flugpfad-Vektor"	-- Flight Path Vector
	--config2[16].t = "GPS"			-- GPS
	config2[17].t = "Kapaz. Kritisch"	-- Fuel Critical
	config2[18].t = "Kapaz. Niedrig"	-- Fuel Low
	config2[19].t = "Tx Spng."		-- Tx Voltage
	config2[20].t = "Geschw. Sensor"	-- Speed Sensor
	config2[21].t = "GPS Warnung"		-- GPS Warning
	config2[22].t = "GPS HDOP"		-- GPS HDOP View
	config2[23].t = "Kapazitaet"		-- Fuel Unit
	config2[24].t = "Vario Schritte"	-- Vario Steps
	config2[25].t = "Ansichtsmodus"		-- View Mode
	config2[26].t = "AlH Cntr Meld."	-- AltHold Center FB
	config2[27].t = "Bat. Kapazitaet"	-- Battery Capacity
	config2[28].t = "Hoehenkurve"		-- Altitude Graph
	config2[29].t = "Zellenberechnung"	-- Cell Calculation
	config2[30].t = "Flugzeug-Symbol"	-- Aircraft Symbol
	config2[31].t = "Karte Zentrieren"	-- Center Map Home
	config2[32].t = "Orientierung"		-- Orientation
	config2[33].t = "Rollenwaage"		-- Roll Scale

	-- Max 8 characters
	config2[1].l =  {[0] = "Zelle", "Total"}			-- "Cell", "Total"
	config2[4].l =  {[0] = "Aus", "Kritisch", "Alle"}		-- "Off", "Critical", "All"
	config2[5].l =  {[0] = "Aus", "Haptisch", "Pieper", "Alle"}	-- "Off", "Haptic", "Beeper", "All"
	config2[7].l =  {[0] = "Aus", "Graph", "Stimme", "Beides"}	-- "Off", "Graph", "Voice", "Both"
	config2[8].l =  {[0] = "Aus", "An"}				-- "Off", "On"
	config2[9].l =  {[0] = "Aus", "An"}				-- "Off", "On"
	config2[10].l = {[0] = "Aus", "An"}				-- "Off", "On"
	config2[11].l = {[0] = "Aus", "Kritisch", "Alle"}		-- "Off", "Critical", "All"
	config2[12].l = {[0] = "Aus", "An"}				-- "Off", "On"
	config2[13].l = {[0] = "Aus", "Auto", "Timer1", "Timer2"}	-- "Off", "Auto", "Timer1", "Timer2"
	config2[14].l = {[0] = "Aus", "An"}				-- "Off", "On"
	config2[16].l = {[0] = "Dezimal", "Grad"}			-- "Decimal", "Deg/Min"
	config2[19].l = {[0] = "Nummer", "Graph", "Beide"}		-- "Number", "Graph", "Both"
	--config2[20].l = {[0] = "GPS", "Pitot"}			-- "GPS", "Pitot"
	config2[22].l = {[0] = "Graph", "Dezimal"}			-- "Graph", "Decimal"
	--config2[23].l = {[0] = "Percent", "mAh", "mWh"}		-- "Percent", "mAh", "mWh"
	config2[25].l = {[0] = "Original", "Pilot", "Radar", "Hoehe"}	-- "Classic", "Pilot", "Radar", "Altitude"
	config2[26].l = {[0] = "Aus", "An"}				-- "Off", "On"
	config2[28].l[0] = "Aus"					-- "Off"
	config2[31].l = {[0] = "Aus", "An"}				-- "Off", "On"
	config2[32].l = {[0] = "Starten", "Kompass"}			-- "Launch", "Compass"
	config2[33].l = {[0] = "Aus", "An"}				-- "Off", "On"
end

return lang