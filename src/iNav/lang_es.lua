local modes, config = ...

-- Max 7 characters
--modes[1].t  = "! TELEM !"	-- ! TELEM !
--modes[2].t  = "HORIZON"	-- HORIZON
--modes[3].t  = "  ANGLE"	-- ANGLE
--modes[4].t  = "   ACRO"	-- ACRO
modes[5].t  = "NO OK"		-- NOT OK
modes[6].t  = " LISTO"		-- READY
--modes[7].t  = "POS HOLD"	-- POS HOLD
--modes[8].t  = "WAYPOINT"	-- WAYPOINT
--modes[9].t  = "MANUAL"	-- MANUAL
--modes[10].t = "   RTH   "	-- RTH
--modes[11].t = "! FAIL !"	-- ! FAIL !
modes[12].t = " ! GAS ! "	-- ! THROT !
--modes[13].t = " CRUISE"	-- CRUISE

-- Max 16 characters
config[1].t  = "Bateria"		-- Battery View
config[2].t  = "Celda baja"		-- Cell Low
config[3].t  = "Celda Critica"	-- Cell Critical
config[4].t  = "Alerta Voces"		-- Voice Alerts
--config[5].t  = "Feedback"		-- Feedback
config[6].t  = "Max Altura"		-- Max Altitude
config[7].t  = "Variometro"		-- Variometer
--config[8].t  = "RTH Feedback"	-- RTH Feedback
--config[9].t  = "HeadFree Feedback"-- HeadFree Feedback
--config[10].t = "RSSI Feedback"	-- RSSI Feedback
config[11].t = "Bateria Alerta"	-- Battery Alert
config[12].t = "Altitud Alerta"	-- Altitude Alert
--config[13].t = "Timer"		-- Timer
config[14].t = "Rx Voltaje"		-- Rx Voltage
--config[15].t = "GPS"			-- GPS
config[16].t = "Coordenadas GPS"	-- GPS Coordinates
config[17].t = "Bateria Critica"	-- Fuel Critical
config[18].t = "Bateria Baja"		-- Fuel Low
config[19].t = "Tx Voltaje"		-- Tx Voltage
config[20].t = "Sensor Velocidad"	-- Speed Sensor
config[21].t = "GPS Aviso"		-- GPS Warning
config[22].t = "GPS HDOP"		-- GPS HDOP View
config[23].t = "Capacidad"		-- Fuel Unit
config[24].t = "Vario Pasos"		-- Vario Steps
config[25].t = "Vista"			-- View Mode
config[26].t = "AlH Centrado FB."	-- AltHold Center FB

-- Max 9 characters
--config[1].l =  {[0] = "Cell", "Total"}						-- "Cell", "Total"
config[4].l =  {[0] = "Off", "Critico", "Todo"}					-- "Off", "Critical", "All"
config[5].l =  {[0] = "Off", "Haptic", "Beeper", "Todo"}			-- "Off", "Haptic", "Beeper", "All"
config[7].l =  {[0] = "Off", "Graph", "Voz", "Ambos"}				-- "Off", "Graph", "Voice", "Both"
--config[8].l =  {[0] = "Off", "On"}						-- "Off", "On"
--config[9].l =  {[0] = "Off", "On"}						-- "Off", "On"
--config[10].l = {[0] = "Off", "On"}						-- "Off", "On"
config[11].l = {[0] = "Off", "Critico", "Todo"}					-- "Off", "Critical", "All"
--config[12].l = {[0] = "Off", "On"}						-- "Off", "On"
--config[13].l = {[0] = "Off", "Auto", "Timer1", "Timer2", "Timer3"}	-- "Off", "Auto", "Timer1", "Timer2", "Timer3"
--config[14].l = {[0] = "Off", "On"}						-- "Off", "On"
config[16].l = {[0] = "Decimal", "Grados/Min"}					-- "Decimal", "Deg/Min"
config[19].l = {[0] = "Numero", "Grafico", "Ambos"}				-- "Number", "Graph", "Both"
--config[20].l = {[0] = "GPS", "Pitot"}						-- "GPS", "Pitot"
config[22].l = {[0] = "Grafico", "Decimal"}					-- "Graph", "Decimal"
--config[23].l = {[0] = "Percent", "mAh", "mWh"}				-- "Percent", "mAh", "mWh"
config[25].l = {[0] = "Clasica", "Pilot", "Radar"}				-- "Classic", "Pilot", "Radar"
--config[26].l = {[0] = "Off", "On"}						-- "Off", "On"

return 0