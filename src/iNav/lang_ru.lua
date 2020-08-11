local modes, labels = ...

-- Max 7 characters
--modes[1].t  = "! TELEM !"	-- ! TELEM !
modes[2].t  = "Гориз."	-- HORIZON
modes[3].t  = "   УГОЛ"	-- ANGLE
--modes[4].t  = "   ACRO"	-- ACRO
modes[5].t  = "НЕ ОК"		-- NOT OK
modes[6].t  = " ГОТОВ"		-- READY
--modes[7].t  = "POS HOLD"	-- POS HOLD
modes[8].t  = "П.ТОЧКА"		-- WAYPOINT
modes[9].t  = "РУЧНОЙ"		-- MANUAL
--modes[10].t = "   RTH   "	-- RTH
--modes[11].t = "! FAIL !"	-- ! FAIL !
modes[12].t = " ! ГАЗ !"	-- ! THROT !
modes[13].t = " КРУИЗ"	-- CRUISE

-- Max 10 characters
labels[1] = "Топливо"	-- Fuel
labels[2] = "Батарея"		-- Battery
labels[3] = "Ток"		-- Current
labels[4] = "Высота"		-- Altitude
labels[5] = "Расстояние"	-- Distance

local function lang(config2)
	-- Max 16 characters
	config2[1].t  = "Батарея"		-- Battery View
	config2[2].t  = "Ячейка низ."		-- Cell Low
	config2[3].t  = "Ячейка крит."	-- Cell Critical
	config2[4].t  = "Голос. предупр."		-- Voice Alerts
	--config2[5].t  = "Meldungen"		-- Feedback
	config2[6].t  = "Макс. высота"		-- Max Altitude
	--config2[7].t  = "Variometer"		-- Variometer
	--config2[8].t  = "RTH Meldung"		-- RTH Feedback
	--config2[9].t  = "HeadFree Meld."	-- HeadFree Feedback
	--config2[10].t = "RSSI Meldung"		-- RSSI Feedback
	config2[11].t = "Предупр. баттареи"		-- Battery Alert
	config2[12].t = "Предупр. высоты"	-- Altitude Alert
	--config2[13].t = "Timer"		-- Timer
	config2[14].t = "Rx напряжение"		-- Rx Voltage
	config2[15].t = "HUD иконка дома"	-- HUD Home Icon
	--config2[16].t = "GPS"			-- GPS
	config2[17].t = "Топлива критич."	-- Fuel Critical
	config2[18].t = "Мало топлива"	-- Fuel Low
	config2[19].t = "Tx напряжение"		-- Tx Voltage
	config2[20].t = "Сенсор скорости"	-- Speed Sensor
	config2[21].t = "GPS предупрежд."		-- GPS Warning
	config2[22].t = "GPS HDOP"		-- GPS HDOP View
	config2[23].t = "Ед. топлива"		-- Fuel Unit
	config2[24].t = "Шаги Vario"	-- Vario Steps
	config2[25].t = "Режим просмотра"		-- View Mode
	--config2[26].t = "AlH Cntr Meld."	-- AltHold Center FB
	config2[27].t = "Емкость батареи"	-- Battery Capacity
	config2[28].t = "График высоты"		-- Altitude Graph
	config2[29].t = "Расчет ячеек бат"	-- Cell Calculation
	config2[30].t = "Символ модели"	-- Aircraft Symbol
	config2[31].t = "Центр. карту"	-- Center Map Home
	config2[32].t = "Ориентация"		-- Orientation
	config2[33].t = "Угол крена"		-- Roll Scale
	--config2[34].t = "Playback Log"	-- Playback Log

	-- Max 8 characters
	config2[1].l =  {[0] = "Ячейка", "Всего"}			-- "Cell", "Total"
	config2[4].l =  {[0] = "Выкл", "Критич.", "Всегда"}		-- "Off", "Critical", "All"
	config2[5].l =  {[0] = "Выкл", "Вибро", "Пищалка", "Всё"}	-- "Off", "Haptic", "Beeper", "All"
	config2[7].l =  {[0] = "Выкл", "Граф", "Голос", "Оба"}	-- "Off", "Graph", "Voice", "Both"
	config2[8].l =  {[0] = "Выкл", "Вкл"}				-- "Off", "On"
	config2[9].l =  {[0] = "Выкл", "Вкл"}				-- "Off", "On"
	config2[10].l = {[0] = "Выкл", "Вкл"}				-- "Off", "On"
	config2[11].l = {[0] = "Выкл", "Критич.", "Всегда"}		-- "Off", "Critical", "All"
	config2[12].l = {[0] = "Выкл", "Вкл"}				-- "Off", "On"
	config2[13].l = {[0] = "Выкл", "Авто", "1", "2"}			-- "Off", "Auto", "1", "2"
	config2[14].l = {[0] = "Выкл", "Вкл"}				-- "Off", "On"
	config2[16].l = {[0] = "Десятич.", "Градусы"}			-- "Decimal", "Deg/Min"
	config2[19].l = {[0] = "Nummer", "Graph", "Beide"}		-- "Number", "Graph", "Both"
	config2[20].l = {[0] = "GPS", "Pitot"}			-- "GPS", "Pitot"
	config2[22].l = {[0] = "Graph", "Dezimal"}			-- "Graph", "Decimal"
	config2[23].l = {[0] = "Percent", "mAh", "mWh"}		-- "Percent", "mAh", "mWh"
	config2[25].l = {[0] = "Original", "Pilot", "Radar", "Hoehe"}	-- "Classic", "Pilot", "Radar", "Altitude"
	config2[26].l = {[0] = "Выкл", "Вкл"}				-- "Off", "On"
	config2[28].l[0] = "Выкл"					-- "Off"
	config2[31].l = {[0] = "Выкл", "Вкл"}				-- "Off", "On"
	config2[32].l = {[0] = "Запуст.", "Компас"}			-- "Launch", "Compass"
	config2[33].l = {[0] = "Выкл", "Вкл"}				-- "Off", "On"

	return {[0] = "Aus", "An"}	-- "Off", "On"
end

return lang