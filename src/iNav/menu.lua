local function view(data, config, event, configCnt, gpsDegMin, getTelemetryId, getTelemetryUnit, FILE_PATH, SMLCD, FLASH, PREV, INCR, NEXT, DECR)

	local CONFIG_X = SMLCD and 0 or 46
	local HORUS = LCD_W >= 480	

	local function saveConfig()
		--local fh = io.open(FILE_PATH .. "config.dat", "w")
		local fh = io.open(FILE_PATH .. "cfg/" .. model.getInfo().name .. ".dat", "w")
		if fh == nil then
			data.msg = "Folder iNav/cfg missing"
			data.startup = 1
		else
			for line = 1, configCnt do
				if config[line].d == nil then
					io.write(fh, string.format("%0" .. config[line].c .. "d", config[line].v))
				else 
					io.write(fh, math.floor(config[line].v * 10))
				end
			end
			io.close(fh)
		end
	end

	if not SMLCD then
		lcd.drawRectangle(CONFIG_X - 3, 9, 134, 55, SOLID)
	end

	-- Disabled options
	for line = 1, configCnt do
		local z = config[line].z
		config[z].p = (config[z].b ~= nil and config[config[config[z].b].z].v == 0) and 1 or nil
	end
	-- Special disabled option and limit cases
	config[7].p = data.vspeed_id == -1 and 1 or nil
	if config[17].p == nil then
		config[17].p = (not data.showCurr or config[23].v ~= 0) and 1 or nil
		config[18].p = config[17].p
	end
	config[19].x = config[14].v == 0 and 2 or SMLCD and 1 or 2
	config[19].v = math.min(config[19].x, config[19].v)
	config[24].p = config[7].v < 2 and 1 or nil
	config[20].p = not data.pitot and 1 or nil
	config[23].p = not data.showFuel and 1 or nil
	for line = data.configTop, math.min(configCnt, data.configTop + 5) do
		local y = (line - data.configTop) * 9 + 11
		local z = config[line].z
		local tmp = (data.configStatus == line and INVERS + data.configSelect or 0) + (config[z].d ~= nil and PREC1 or 0)
		if not data.showCurr and z >= 17 and z <= 18 then
			config[z].p = 1
		end
		lcd.drawText(CONFIG_X, y, config[z].t, SMLSIZE)
		if config[z].p == nil then
			if config[z].l == nil then
				lcd.drawText(CONFIG_X + 83, y, (config[z].d ~= nil and string.format("%.1f", config[z].v) or config[z].v) .. config[z].a, SMLSIZE + tmp)
			else
				if not config[z].l then
					lcd.drawText(CONFIG_X + 83, y, config[z].v, SMLSIZE + tmp)
				else
					if z == 15 then
						lcd.drawText(CONFIG_X + 21, y, config[16].v == 0 and string.format("%10.6f %11.6f", config[z].l[config[z].v].lat, config[z].l[config[z].v].lon) or " " .. gpsDegMin(config[z].l[config[z].v].lat, true) .. "  " .. gpsDegMin(config[z].l[config[z].v].lon, false), SMLSIZE + tmp)
					else
						lcd.drawText(CONFIG_X + 83, y, config[z].l[config[z].v] .. (config[z].a == nil and "" or config[z].a), SMLSIZE + tmp)
					end
				end
			end
		else
			lcd.drawText(CONFIG_X + 83, y, "--", SMLSIZE + tmp)
		end
	end

	if data.configSelect == 0 then
		-- Select config option
		if event == EVT_EXIT_BREAK then
			saveConfig()
			data.configLast = data.configStatus
			data.configStatus = 0
		elseif event == NEXT or event == EVT_DOWN_REPT or event == EVT_MINUS_REPT then -- Next option
			data.configStatus = data.configStatus == configCnt and 1 or data.configStatus + 1
			data.configTop = data.configStatus > math.min(configCnt, data.configTop + 5) and data.configTop + 1 or (data.configStatus == 1 and 1 or data.configTop)
			while config[config[data.configStatus].z].p ~= nil do
				data.configStatus = math.min(data.configStatus + 1, configCnt)
				data.configTop = data.configStatus > math.min(configCnt, data.configTop + 5) and data.configTop + 1 or data.configTop
			end
		elseif event == PREV or event == EVT_UP_REPT or event == EVT_PLUS_REPT then -- Previous option
			data.configStatus = data.configStatus == 1 and configCnt or data.configStatus - 1
			data.configTop = data.configStatus < data.configTop and data.configTop - 1 or (data.configStatus == configCnt and configCnt - 5 or data.configTop)
			while config[config[data.configStatus].z].p ~= nil do
				data.configStatus = math.max(data.configStatus - 1, 1)
				data.configTop = data.configStatus < data.configTop and data.configTop - 1 or data.configTop
			end
		end
	else
		local z = config[data.configStatus].z
		if event == EVT_EXIT_BREAK then
			data.configSelect = 0
		elseif event == INCR or event == EVT_UP_REPT or event == EVT_PLUS_REPT then
			config[z].v = math.min(math.floor(config[z].v * 10 + config[z].i * 10) / 10, config[z].x == nil and 1 or config[z].x)
		elseif event == DECR or event == EVT_DOWN_REPT or event == EVT_MINUS_REPT then
			config[z].v = math.max(math.floor(config[z].v * 10 - config[z].i * 10) / 10, config[z].m == nil and 0 or config[z].m)
		end

		-- Special cases
		if event then
			if z == 2 then -- Cell low > critical
				config[2].v = math.max(config[2].v, config[3].v + 0.1)
			elseif z == 3 then -- Cell critical < low
				config[3].v = math.min(config[3].v, config[2].v - 0.1)
			elseif z == 18 then -- Fuel low > critical
				config[18].v = math.max(config[18].v, config[17].v + 1)
			elseif z == 17 then -- Fuel critical < low
				config[17].v = math.min(config[17].v, config[18].v - 1)
			elseif z == 20 then -- Speed sensor
				local tmp = config[20].v == 0 and "GSpd" or "ASpd"
				data.speed_id = getTelemetryId(tmp)
				data.speedMax_id = getTelemetryId(tmp .. "+")
				data.speed_unit = getTelemetryUnit(tmp)
			elseif config[z].i > 1 then
				config[z].v = math.floor(config[z].v / config[z].i) * config[z].i
			end
		end
	end

	if event == EVT_ENTER_BREAK then
		data.configSelect = (data.configSelect == 0) and BLINK or 0
	end

end

return view