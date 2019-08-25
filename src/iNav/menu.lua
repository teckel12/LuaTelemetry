local function view(data, config, units, lang, event, gpsDegMin, getTelemetryId, getTelemetryUnit, FILE_PATH, SMLCD, FLASH, PREV, NEXT, HORUS, env)

	local CONFIG_X = HORUS and 90 or (SMLCD and 0 or 46)
	local TOP = HORUS and 37 or 11
	local LINE = HORUS and 22 or 9
	local RSIDE = HORUS and 200 or 83
	local GPS = HORUS and 45 or 21
	local ROWS = HORUS and 9 or 5
	local FONT = HORUS and 0 or SMLSIZE
	local text = lcd.drawText
	local min = math.min
	local max = math.max
	local floor = math.floor
	local format = string.format
	local offOn = {[0] = "Off", "On"}

	-- Config options: o=display Order / t=Text / c=Characters / v=default Value / l=Lookup text / d=Decimal / m=Min / x=maX / i=Increment / a=Append text
	local config2 = {
		{ t = "Battery View",     l = {[0] = "Cell", "Total"} }, -- 1
		{ t = "Cell Low",         m = 2.7, i = 0.1, a = "V" }, -- 2
		{ t = "Cell Critical",    m = 2.6, i = 0.1, a = "V" }, -- 3
		{ t = "Voice Alerts",     l = {[0] = "Off", "Critical", "All"} }, -- 4
		{ t = "Feedback",         l = {[0] = "Off", "Haptic", "Beeper", "All"} }, -- 5
		{ t = "Max Altitude",     i = data.alt_unit == 10 and 10 or 1, a = units[data.alt_unit] }, -- 6
		{ t = "Variometer",       l = {[0] = "Off", "Graph", "Voice", "Both"} }, -- 7
		{ t = "RTH Feedback",     l = 1 }, -- 8
		{ t = "HeadFree Feedback",l = 1 }, -- 9
		{ t = "RSSI Feedback",    l = 1 }, -- 10
		{ t = "Battery Alerts",   l = {[0] = "Off", "Critical", "All"} }, -- 11
		{ t = "Altitude Alert",   l = 1 }, -- 12
		{ t = "Timer",            l = {[0] = "Off", "Auto", "1", "2"} }, -- 13
		{ t = "Rx Voltage",       l = 1 }, -- 14
		{ t = "HUD Home Icon",    l = 1 }, -- 15
		{ t = "GPS",              l = 0 }, -- 16
		{ t = "Fuel Critical",    m = 1, a = "%" }, -- 17
		{ t = "Fuel Low",         m = 2, a = "%" }, -- 18
		{ t = "Tx Voltage",       l = {[0] = "Number", "Graph", "Both"} }, -- 19
		{ t = "Speed Sensor",     l = {[0] = "GPS", "Pitot"} }, -- 20
		{ t = "GPS Warning",      m = 1.0, i = 0.5, a = " HDOP" }, -- 21
		{ t = "GPS HDOP View",    l = {[0] = "Graph", "Decimal"} }, -- 22
		{ t = "Fuel Unit",        l = {[0] = "Percent", "mAh", "mWh"} }, -- 23
		{ t = "Vario Steps",      m = 0, a = units[data.alt_unit], l = {[0] = 1, 2, 5, 10, 15, 20, 25, 30, 40, 50} }, -- 24
		{ t = "View Mode",        l = {[0] = "Classic", "Pilot", "Radar", "Altitude"} }, -- 25
		{ t = "AltHold Center FB",l = 1 }, -- 26
		{ t = "Battery Capacity", m = 150, i = 50, a = "mAh" }, -- 27
		{ t = "Altitude Graph",   l = {[0] = "Off", 1, 2, 3, 4, 5, 6}, a = " Min" }, -- 28
		{ t = "Cell Calculation", m = 4.2, i = 0.1, a = "V" }, -- 29
		{ t = "Aircraft Symbol",  a = "" }, -- 30
		{ t = "Center Map Home",  l = 1 }, -- 31
		{ t = "Orientation",      l = {[0] = "Launch", "Compass"} }, -- 32
		{ t = "Roll Scale",       l = 1 }, -- 33
		{ t = "Playback Log",     l = config[34].l }, -- 34
	}

	-- Import language changes
	if lang ~= nil then
		offOn = lang(config2)
	end

	if HORUS then
		lcd.setColor(CUSTOM_COLOR, GREY)
		lcd.drawFilledRectangle(CONFIG_X - 10, TOP - 7, LCD_W - CONFIG_X * 2 + 20, LINE * (ROWS + 1) + 12, CUSTOM_COLOR)
		lcd.setColor(CUSTOM_COLOR, 12678) -- Dark grey
	end
	if not SMLCD then
		lcd.drawRectangle(CONFIG_X - (HORUS and 10 or 5), TOP - (HORUS and 7 or 2), LCD_W - CONFIG_X * 2 + (HORUS and 20 or 10), LINE * (ROWS + 1) + (HORUS and 12 or 1), SOLID)
	end

	-- Special limit cases
	config[19].x = SMLCD and ((config[14].v == 1 or data.crsf) and 1 or 2) or 2
	config[19].v = min(config[19].x, config[19].v)
	config[25].x = config[28].v == 0 and 2 or 3
	if config[28].v == 0 and config[25].v == 3 then
		config[25].v = 2
	end

	-- Disabled options
	config2[7].p = data.vspeed_id == -1 and 1 or nil
	config2[15].p = not HORUS and 1 or nil
	config2[20].p = not data.pitot and 1 or nil
	config2[22].p = data.crsf and 1 or (HORUS and 1 or nil)
	config2[23].p = not data.showFuel and 1 or nil
	config2[24].p = data.crsf and 1 or (config[7].v < 2 and 1 or nil)
	config2[27].p = (not data.crsf or config[23].v > 0) and 1 or nil
	if config2[17].p == nil then
		config2[17].p = (not data.showCurr or config[23].v ~= 0) and 1 or nil
		config2[18].p = config2[17].p
	end
	if not data.showCurr then
		config2[17].p = 1
		config2[18].p = 1
	end
	if data.crsf then
		config2[9].p = 1
		config2[14].p = 1
		config2[21].p = 1
	end
	if HORUS then
		config2[25].p = 1
	else
		config2[30].p = 1
		config2[31].p = 1
		config2[33].p = 1
	end
	if config[11].v == 0 then
		config2[2].p = 1
		config2[3].p = 1
		config2[17].p = 1
		config2[18].p = 1
	end
	if config[12].v == 0 then
		config2[6].p = 1
	end
	if config[4].v == 0 then
		config2[8].p = 1
		config2[9].p = 1
		config2[10].p = 1
		config2[26].p = 1
	end
	if config[34].x == -1 or data.armed then
		config2[34].p = 1
	end

	if event == EVT_ENTER_BREAK and config2[config[data.configStatus].z].p == nil then
		data.configSelect = (data.configSelect == 0) and BLINK or 0
	end

	-- Select config option
	if data.configSelect == 0 then
		if event == NEXT or event == EVT_DOWN_REPT or event == EVT_MINUS_REPT then -- Next option
			data.configStatus = data.configStatus == #config and 1 or data.configStatus + 1
			data.configTop = data.configStatus > min(#config, data.configTop + ROWS) and data.configTop + 1 or (data.configStatus == 1 and 1 or data.configTop)
		elseif event == PREV or event == EVT_UP_REPT or event == EVT_PLUS_REPT then -- Previous option
			data.configStatus = data.configStatus == 1 and #config or data.configStatus - 1
			data.configTop = data.configStatus < data.configTop and data.configTop - 1 or (data.configStatus == #config and #config - ROWS or data.configTop)
		elseif event == EVT_ENTER_BREAK and data.configStatus == 34 and config2[34].p == nil then -- Log file selected
			data.doLogs = true
		end
	end

	-- Delete invisible menus
	local bottom = min(#config, data.configTop + ROWS)
	for line = 1, #config do
		if line < data.configTop or line > bottom then
			config2[config[line].z] = nil
		end
	end
	collectgarbage()

	-- Select config items
	if data.configSelect ~= 0 then
		local z = config[data.configStatus].z
		local i = config2[z].i == nil and 1 or config2[z].i
		if event == EVT_EXIT_BREAK then
			data.configSelect = 0
		elseif event == NEXT or event == EVT_UP_REPT or event == EVT_PLUS_REPT then
			config[z].v = min(floor(config[z].v * 10 + i * 10) * 0.1, config[z].x == nil and 1 or config[z].x)
		elseif event == PREV or event == EVT_DOWN_REPT or event == EVT_MINUS_REPT then
			config[z].v =max(floor(config[z].v * 10 - i * 10) * 0.1, config2[z].m == nil and 0 or config2[z].m)
		end

		-- Special cases
		if event ~= 0 and event ~= nil then
			if z == 2 then -- Cell low > critical
				config[2].v = max(config[2].v, config[3].v + 0.1)
			elseif z == 3 then -- Cell critical < low
				config[3].v = min(config[3].v, config[2].v - 0.1)
			elseif z == 18 then -- Fuel low > critical
				config[18].v = max(config[18].v, config[17].v + 1)
			elseif z == 17 then -- Fuel critical < low
				config[17].v = min(config[17].v, config[18].v - 1)
			elseif z == 20 then -- Speed sensor
				local tmp = config[20].v == 0 and "GSpd" or "ASpd"
				data.speed_id = getTelemetryId(tmp)
				data.speedMax_id = getTelemetryId(tmp .. "+")
				data.speed_unit = getTelemetryUnit(tmp)
			elseif z == 28 then -- Altitude graph
				for i = 1, 60 do
					data.alt[i] = 0
				end
			elseif i > 1 then
				config[z].v = floor(config[z].v / i) * i
			end
		end
	end

	-- Print screen
	for line = data.configTop, bottom do
		local y = (line - data.configTop) * LINE + TOP
		local z = config[line].z
		local tmp = (data.configStatus == line and INVERS + data.configSelect or 0) + (config[z].d ~= nil and PREC1 or 0)
		if config2[z].p == 1 and HORUS then
			tmp = tmp + CUSTOM_COLOR
		end
		text(CONFIG_X, y, config2[z].t, FONT + ((config2[z].p == 1 and HORUS) and CUSTOM_COLOR or 0))
		if config2[z].p == nil then
			if config2[z].l == nil then
				text(CONFIG_X + RSIDE, y, (config[z].d ~= nil and format("%.1f", config[z].v) or config[z].v) .. config2[z].a, FONT + tmp)
			else
				if config2[z].l == 0 then
					if config[z].v == 0 then
						config2[z].l = { [0] = format("%10.6f %11.6f", data.lastLock.lat, data.lastLock.lon) }
					else
						config2[z].l = { gpsDegMin(data.lastLock.lat, true) .. "  " .. gpsDegMin(data.lastLock.lon, false) }
					end
				elseif config2[z].l == 1 then
					config2[z].l = offOn
				end
				if not config2[z].l then
					text(CONFIG_X + RSIDE, y, config[z].v, FONT + tmp)
				else
					text(z == 16 and LCD_W - CONFIG_X or CONFIG_X + RSIDE, y, config2[z].l[config[z].v] .. ((config2[z].a == nil or config[z].v == 0) and "" or config2[z].a), FONT + tmp + (z == 16 and RIGHT or 0))
				end
			end
			config2[z] = nil
		else
			text(CONFIG_X + RSIDE, y, "--", FONT + tmp)
		end
	end

end

return view