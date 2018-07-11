local FILE_PATH, LCD_W, PREV, INCR, NEXT, DECR, gpsDegMin, gpsGeocoding, config, data, event = ...

local CONFIG_X = LCD_W < 212 and 6 or 48

local function saveConfig()
	local fh = io.open(FILE_PATH .. "config.dat", "w")
	if fh == nil then
		data.systemError = "Folder \"iNav\" not found"
	else
		for line = 1, config.cnt do
			if config[line].d == nil then
				io.write(fh, string.format("%0" .. config[line].c .. "d", config[line].v))
			else 
				io.write(fh, math.floor(config[line].v * 10))
			end
		end
		io.close(fh)
	end
end

lcd.drawFilledRectangle(CONFIG_X, 10, 116, 52, ERASE)
lcd.drawRectangle(CONFIG_X, 10, 116, 52, SOLID)

-- Disabled options
for line = 1, config.cnt do
	local z = config[line].z
	config[z].p = (config[z].b ~= nil and config[config[config[z].b].z].v == 0) and 1 or nil
end
-- Special disabled option cases
config[7].p = data.accZ_id == -1 and 1 or nil
if config[17].p == nil then
  config[17].p = (not data.showCurr or config[23].v ~= 0) and 1 or nil
  config[18].p = config[17].p
end
config[20].p = not data.pitot and 1 or nil
for line = config.top, math.min(config.cnt, config.top + 5) do
	local y = (line - config.top) * 8 + 10 + 3
	local z = config[line].z
	local tmp = (config.status == line and INVERS + config.select or 0) + (config[z].d ~= nil and PREC1 or 0)
	if not data.showCurr and z >= 17 and z <= 18 then
		config[z].p = 1
	end
	if z == 19 then
		config[19].x = config[14].v == 0 and 2 or SMLCD and 1 or 2
		config[19].v = math.min(config[19].x, config[19].v)
	end
	lcd.drawText(CONFIG_X + 4, y, config[z].t, SMLSIZE)
	if config[z].p == nil then
		if config[z].l == nil then
			lcd.drawText(CONFIG_X + 78, y, (config[z].d ~= nil and string.format("%.1f", config[z].v) or config[z].v) .. config[z].a, SMLSIZE + tmp)
		else
			if not config[z].l then
				lcd.drawText(CONFIG_X + 78, y, config[z].v, SMLSIZE + tmp)
			else
				if z == 15 then
					if config[16].v == 0 then
						lcd.drawText(CONFIG_X + 22, y, string.format("%9.5f %10.5f", config[z].l[config[z].v].lat, config[z].l[config[z].v].lon), SMLSIZE + tmp)
					elseif config[16].v == 1 then
						lcd.drawText(CONFIG_X + 22, y, gpsDegMin(config[z].l[config[z].v].lat, true) .. " " .. gpsDegMin(config[z].l[config[z].v].lon, false), SMLSIZE + tmp)
					else
						lcd.drawText(CONFIG_X + 22, y, gpsGeocoding(config[z].l[config[z].v].lat, true) .. " " .. gpsGeocoding(config[z].l[config[z].v].lon, false), SMLSIZE + tmp)
					end
				else
					lcd.drawText(CONFIG_X + 78, y, config[z].l[config[z].v], SMLSIZE + tmp)
				end
			end
		end
	else
		lcd.drawText(CONFIG_X + 78, y, "--", SMLSIZE + tmp)
	end
end

if config.select == 0 then
	-- Select config option
	if event == EVT_EXIT_BREAK then
		saveConfig()
		config.status = 0
	elseif event == NEXT then -- Next option
		config.status = config.status == config.cnt and 1 or config.status + 1
		config.top = config.status > math.min(config.cnt, config.top + 5) and config.top + 1 or (config.status == 1 and 1 or config.top)
		while config[config[config.status].z].p ~= nil do
			config.status = math.min(config.status + 1, config.cnt)
			config.top = config.status > math.min(config.cnt, config.top + 5) and config.top + 1 or config.top
		end
	elseif event == PREV then -- Previous option
		config.status = config.status == 1 and config.cnt or config.status - 1
		config.top = config.status < config.top and config.top - 1 or (config.status == config.cnt and config.cnt - 5 or config.top)
		while config[config[config.status].z].p ~= nil do
			config.status = math.max(config.status - 1, 1)
			config.top = config.status < config.top and config.top - 1 or config.top
		end
	end
else
	local z = config[config.status].z
	if event == EVT_EXIT_BREAK then
		config.select = 0
	elseif event == INCR then
		config[z].v = math.min(math.floor(config[z].v * 10 + config[z].i * 10) / 10, config[z].x == nil and 1 or config[z].x)
	elseif event == DECR then
		config[z].v = math.max(math.floor(config[z].v * 10 - config[z].i * 10) / 10, config[z].m == nil and 0 or config[z].m)
	end

	-- Special cases
	if event then
		if z == 2 then -- Cell low > critical
			config[2].v = math.max(config[2].v, config[3].v + 0.1)
		elseif z == 3 then -- Cell critical < low
			config[3].v = math.min(config[3].v, config[2].v - 0.1)
		elseif z == 18 then -- Fuel low > critical
			config[18].v = math.max(config[18].v, config[17].v + 5)
		elseif z == 17 then -- Fuel critical < low
			config[17].v = math.min(config[17].v, config[18].v - 5)
		elseif z == 20 then -- Speed sensor
			setSpeedSensor(config[20].v == 0 and "GSpd" or "ASpd")
		elseif config[z].i > 1 then
			config[z].v = math.floor(config[z].v / config[z].i) * config[z].i
		end
	end
end

if event == EVT_ENTER_BREAK then
	config.select = (config.select == 0) and BLINK or 0
end

return 0