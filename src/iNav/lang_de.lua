local modes, config = ...

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

-- Max 16 characters
config[1].t  = "Batterie"		-- Battery View
config[2].t  = "Zelle Niedrig"		-- Cell Low
config[3].t  = "Zelle Kritisch"		-- Cell Critical
config[4].t  = "Sprach Alarme"		-- Voice Alerts
config[5].t  = "Meldungen"		-- Feedback
config[6].t  = "Max Hoehe"		-- Max Altitude
--config[7].t  = "Variometer"		-- Variometer
config[8].t  = "RTH Meldung"		-- RTH Feedback
config[9].t  = "HeadFree Meld."		-- HeadFree Feedback
config[10].t = "RSSI Meldung"		-- RSSI Feedback
config[11].t = "Bat. Warnung"		-- Battery Alert
config[12].t = "Hoehen Warnung"		-- Altitude Alert
--config[13].t = "Timer"		-- Timer
config[14].t = "Rx Spng."		-- Rx Voltage
--config[15].t = "GPS"			-- GPS
config[16].t = "GPS Koordi."		-- GPS Coords
config[17].t = "Kapaz. Kritisch"	-- Fuel Critical
config[18].t = "Kapaz. Niedrig"		-- Fuel Low
config[19].t = "Tx Spng."		-- Tx Voltage
config[20].t = "Geschw. Sensor"		-- Speed Sensor
config[21].t = "GPS Warnung"		-- GPS Warning
config[22].t = "GPS HDOP"		-- GPS HDOP View
config[23].t = "Kapazität"		-- Fuel Unit
config[24].t = "Vario Schritte"		-- Vario Steps
config[25].t = "Ansichtsmodus"		-- View Mode
config[26].t = "AlH Cntr Meld."		-- Alt Hold Center Feedback

-- Max 9 characters
config[1].l =  {[0] = "Zelle", "Total"}				-- "Cell", "Total"
config[4].l =  {[0] = "Aus", "Kritisch", "Alle"}		-- "Off", "Critical", "All"
config[5].l =  {[0] = "Aus", "Haptisch", "Pieper", "Alle"}	-- "Off", "Haptic", "Beeper", "All"
config[7].l =  {[0] = "Aus", "Graph", "Stimme", "Beides"}	-- "Off", "Graph", "Voice", "Both"
config[8].l =  {[0] = "Aus", "An"}				-- "Off", "On"
config[9].l =  {[0] = "Aus", "An"}				-- "Off", "On"
config[10].l = {[0] = "Aus", "An"}				-- "Off", "On"
config[11].l = {[0] = "Aus", "Kritisch", "Alle"}		-- "Off", "Critical", "All"
config[12].l = {[0] = "Aus", "An"}				-- "Off", "On"
config[13].l = {[0] = "Aus", "Auto", "Timer1", "Timer2", "Timer3"}	-- "Off", "Auto", "Timer1", "Timer2", "Timer3"
config[14].l = {[0] = "Aus", "An"}				-- "Off", "On"
config[16].l = {[0] = "Dezimal", "Grad/Min"}			-- "Decimal", "Deg/Min"
config[19].l = {[0] = "Nummer", "Graph", "Beide"}		-- "Number", "Graph", "Both"
--config[20].l = {[0] = "GPS", "Pitot"}				-- "GPS", "Pitot"
config[22].l = {[0] = "Graph", "Dezimal"}			-- "Graph", "Decimal"
--config[23].l = {[0] = "Percent", "mAh", "mWh"}		-- "Percent", "mAh", "mWh"
config[25].l = {[0] = "Klassisch", "Pilot"}			-- "Classic", "Pilot"
config[26].l = {[0] = "Aus", "An"}				-- "Off", "On"

return 0
