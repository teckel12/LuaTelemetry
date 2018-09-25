local function view(data, config, modes, units, gpsDegMin, gpsIcon, lockIcon, homeIcon, hdopGraph, VERSION, SMLCD, FLASH, FILE_PATH)

	--local LEFT_POS = SMLCD and 0 or 36
	local LEFT_POS = 36
	local RIGHT_POS = SMLCD and LCD_W - 31 or LCD_W - 53
	local X_CNTR = (RIGHT_POS + LEFT_POS) / 2 - 2
	local HEADING_DEG = SMLCD and 170 or 190
	local PIXEL_DEG = (RIGHT_POS - LEFT_POS) / HEADING_DEG
	local gpsFlags = SMLSIZE + RIGHT + ((not data.telem or not data.gpsFix) and FLASH or 0)
	local tmp, pitch, roll, roll1, roll2, upsideDown

	-- Startup message
	if data.startup == 2 then
		if not SMLCD then
			lcd.drawText(50, 28, "INAV Lua Telemetry")
		end
		lcd.drawText(X_CNTR - 12, SMLCD and 28 or 40, "v" .. VERSION)
	end

	-- Flight modes
	tmp = X_CNTR - (SMLCD and 16 or 19)
	lcd.drawLine(tmp, 9, tmp, 15, SOLID, ERASE)
	lcd.drawText(tmp + 1, 9, modes[data.modeId].t, SMLSIZE + modes[data.modeId].f)
	if data.headFree then
		lcd.drawText(tmp, 9, "HF", SMLSIZE + FLASH + RIGHT)
	end
	if data.headingHold then
		lockIcon(RIGHT_POS - 6, 9)
	end

	-- Bottom data
	if SMLCD and data.showDir then
		lcd.drawText(RIGHT_POS, 50, config[16].v == 0 and string.format("%.5f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), gpsFlags)
		lcd.drawText(RIGHT_POS, 57, config[16].v == 0 and string.format("%.5f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), gpsFlags)
	else
		-- Distance
		tmp = data.showMax and data.distanceMax or data.distanceLast
		lcd.drawText(LEFT_POS + 25, 57, data.startup == 0 and (tmp < 1000 and math.floor(tmp + 0.5) .. units[data.dist_unit] or (string.format("%.1f", tmp / (data.dist_unit == 9 and 1000 or 5280)) .. (data.dist_unit == 9 and "km" or "mi"))) or "Dist", SMLSIZE + RIGHT + data.telemFlags)

		-- Altitude
		tmp = data.showMax and data.altitudeMax or data.altitude
		lcd.drawText(RIGHT_POS - 6, 57, data.startup == 0 and (math.floor(tmp + 0.5) .. units[data.alt_unit]) or "Alt", SMLSIZE + RIGHT + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
		if data.altHold then
			lockIcon(RIGHT_POS - 6, 57)
		end
	end

	-- Radar
	if data.startup == 0 then
		if data.gpsHome ~= false and data.distanceLast >= data.distRef then
			-- Craft location
			local d = math.min(math.max((data.distanceLast / data.distanceMax) * 25, 7), 25)
			local o1 = math.rad(data.gpsHome.lat)
			local a1 = math.rad(data.gpsHome.lon)
			local o2 = math.rad(data.gpsLatLon.lat)
			local a2 = math.rad(data.gpsLatLon.lon)
			local y = math.sin(a2 - a1) * math.cos(o2)
			local x = (math.cos(o1) * math.sin(o2)) - (math.sin(o1) * math.cos(o2) * math.cos(a2 - a1))
			local bearing = math.deg(math.atan2(y, x)) - data.headingRef
			local rad1 = math.rad(bearing)
			local cx = math.floor(math.sin(rad1) * d + 0.5)
			local cy = math.floor(math.cos(rad1) * d + 0.5)
			-- Home position
			local hx = X_CNTR + 3 - (d > 17 and cx / 3 or 0)
			local hy = 38 + (d > 17 and cy / 3 or 0)
			if d >= 9 then
				homeIcon(hx - 3, hy - 3)
			else
				lcd.drawFilledRectangle(hx - 1, hy - 1, 3, 3, ERASE)
				lcd.drawFilledRectangle(hx - 1, hy - 1, 3, 3, SOLID)
			end
			-- Shift craft location
			cx = cx + hx
			cy = hy - cy
			-- Orientation
			rad1 = math.rad(data.heading - data.headingRef)
			local rad2 = math.rad(data.heading - data.headingRef + 145)
			local rad3 = math.rad(data.heading - data.headingRef - 145)
			local x1 = math.sin(rad1) * 5 + cx
			local y1 = cy - math.cos(rad1) * 5
			local x2 = math.sin(rad2) * 5 + cx
			local y2 = cy - math.cos(rad2) * 5
			local x3 = math.sin(rad3) * 5 + cx
			local y3 = cy - math.cos(rad3) * 5
			lcd.drawLine(x2, y2, x3, y3, SMLCD and DOTTED or SOLID, FORCE + (SMLCD and 0 or GREY_DEFAULT))
			lcd.drawLine(x1, y1, x2, y2, SOLID, FORCE)
			lcd.drawLine(x1, y1, x3, y3, SOLID, FORCE)
		else
			homeIcon(X_CNTR, 35)
		end
	end

	-- Variometer
	if config[7].v % 2 == 1 then
		lcd.drawLine(RIGHT_POS, 8, RIGHT_POS, 63, SOLID, FORCE)
		lcd.drawLine(RIGHT_POS + (SMLCD and 4 or 6), 8, RIGHT_POS + (SMLCD and 4 or 6), 63, SOLID, FORCE)
		local varioSpeed = math.log(1 + math.min(math.abs(0.6 * (data.vspeed_unit == 6 and data.vspeed / 3.28084 or data.vspeed)), 10)) / 2.4 * (data.vspeed < 0 and -1 or 1)
		if data.armed then
			tmp = 35 - math.floor(varioSpeed * 27 + 0.5)
			for i = 35, tmp, (tmp > 35 and 1 or -1) do
				local w = SMLCD and (tmp > 35 and i + 1 or 35 - i) % 3 or (tmp > 35 and i + 1 or 35 - i) % 4
				if w < (SMLCD and 2 or 3) then
					lcd.drawLine(RIGHT_POS + 1 + w, i, RIGHT_POS + (SMLCD and 3 or 5) - w, i, SOLID, 0)
				end
			end
		end
	else
		lcd.drawLine(RIGHT_POS, 8, RIGHT_POS, 63, SOLID, FORCE)
	end

	-- Right data - GPS
	lcd.drawText(LCD_W, 8, data.satellites % 100, MIDSIZE + RIGHT + data.telemFlags)
	gpsIcon(LCD_W - (SMLCD and 23 or 22), 12)
	if SMLCD then
		lcd.drawText(LCD_W + 1, config[22].v == 1 and 22 or 32, "HDOP", RIGHT + SMLSIZE)
		hdopGraph(LCD_W - 12, config[22].v == 1 and 31 or 24, MIDSIZE)
	else
		hdopGraph(LCD_W - 39, 10, MIDSIZE)
		lcd.drawText(LCD_W - (config[22].v == 0 and 24 or 25), config[22].v == 0 and 18 or 20, "HDOP", RIGHT + SMLSIZE)
		lcd.drawText(LCD_W + 1, 33, config[16].v == 0 and string.format("%.5f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), gpsFlags)
		lcd.drawText(LCD_W + 1, 42, config[16].v == 0 and string.format("%.5f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), gpsFlags)
		lcd.drawText(RIGHT_POS + 8, 57, "RSSI", SMLSIZE)
	end
	lcd.drawText(LCD_W + 1, SMLCD and 43 or 24, math.floor(data.gpsAlt + 0.5) .. units[data.gpsAlt_unit], gpsFlags)
	lcd.drawLine(RIGHT_POS + (config[7].v % 2 == 1 and (SMLCD and 5 or 7) or 0), 50, LCD_W, 50, SOLID, FORCE)
	local rssiFlags = RIGHT + ((not data.telem or data.rssi < data.rssiLow) and FLASH or 0)
	lcd.drawText(LCD_W - 10, 52, math.min(data.showMax and data.rssiMin or data.rssiLast, 99), MIDSIZE + rssiFlags)
	lcd.drawText(LCD_W, 57, "dB", SMLSIZE + rssiFlags)

	-- Left data - Battery
	lcd.drawLine(LEFT_POS, 8, LEFT_POS, 63, SOLID, FORCE)
	lcd.drawFilledRectangle(LEFT_POS - 7, 49, 7, 14, ERASE)
	tmp = (not data.telem or data.cell < config[3].v or (data.showFuel and config[23].v == 0 and data.fuel <= config[17].v)) and FLASH or 0
	if data.showFuel then
		if config[23].v == 0 then
			lcd.drawText(LEFT_POS - 5, data.showCurr and 8 or 12, data.fuel, DBLSIZE + RIGHT + tmp)
			lcd.drawText(LEFT_POS, data.showCurr and 17 or 21, "%", SMLSIZE + RIGHT + tmp)
		else
			lcd.drawText(LEFT_POS, data.showCurr and 8 or 10, data.fuel, MIDSIZE + RIGHT + tmp)
			lcd.drawText(LEFT_POS, data.showCurr and 20 or 23, config[23].l[config[23].v], SMLSIZE + RIGHT + tmp)
		end
	end
	lcd.drawText(LEFT_POS - 5, data.showCurr and 25 or 32, string.format(config[1].v == 0 and "%.2f" or "%.1f", config[1].v == 0 and (data.showMax and data.cellMin or data.cell) or (data.showMax and data.battMin or data.batt)), DBLSIZE + RIGHT + tmp)
	lcd.drawText(LEFT_POS, data.showCurr and 34 or 41, "V", SMLSIZE + RIGHT + tmp)
	if data.showCurr then
		tmp = data.showMax and data.currentMax or data.current
		lcd.drawText(LEFT_POS - 5, 42, tmp >= 99.5 and math.floor(tmp + 0.5) or string.format("%.1f", tmp), MIDSIZE + RIGHT + data.telemFlags)
		lcd.drawText(LEFT_POS, 47, "A", SMLSIZE + RIGHT + data.telemFlags)
	end
	lcd.drawLine(0, data.showCurr and 54 or 53, LEFT_POS, data.showCurr and 54 or 53, SOLID, FORCE)
	tmp = data.showMax and data.speedMax or data.speed
	lcd.drawText(LEFT_POS, 57, tmp >= 99.5 and math.floor(tmp + 0.5) .. units[data.speed_unit] or string.format("%.1f", tmp) .. units[data.speed_unit], SMLSIZE + RIGHT + data.telemFlags)

end

return view