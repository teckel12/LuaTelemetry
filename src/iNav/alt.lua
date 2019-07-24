local function view(data, config, modes, units, labels, gpsDegMin, hdopGraph, icons, calcBearing, calcDir, VERSION, SMLCD, FLASH, FILE_PATH)

	local LEFT_DIV = 36
	local LEFT_POS = SMLCD and LEFT_DIV or 73
	local RIGHT_POS = SMLCD and LCD_W - 31 or LCD_W - 53
	local X_CNTR = (RIGHT_POS + LEFT_POS) * 0.5 - 1
	local gpsFlags = SMLSIZE + RIGHT + ((not data.telem or not data.gpsFix) and FLASH or 0)
	local tmp, pitch

	-- Startup message
	if data.startup == 2 then
		if not SMLCD then
			lcd.drawText(LEFT_POS + 8, 28, "Lua Telemetry")
		end
		lcd.drawText(X_CNTR - 10, SMLCD and 29 or 40, "v" .. VERSION)
	end

	-- Flight modes
	tmp = X_CNTR - (SMLCD and 16 or 19)
	lcd.drawText(tmp + 1, 9, modes[data.modeId].t, SMLSIZE + modes[data.modeId].f)
	if data.headFree then
		lcd.drawText(tmp, 9, "HF", SMLSIZE + FLASH + RIGHT)
	end

	-- Pitch calculation
	if data.pitchRoll then
		pitch = ((math.abs(data.roll) > 900 and -1 or 1) * (270 - data.pitch * 0.1) % 180) - 90
	else
		pitch = math.deg(math.atan2(data.accx * (data.accz >= 0 and -1 or 1), math.sqrt(data.accy * data.accy + data.accz * data.accz))) * -1
	end
	pitch = pitch >= 0 and (pitch < 1 and 0 or math.floor(pitch + 0.5)) or (pitch > -1 and 0 or math.ceil(pitch - 0.5))

	-- Bottom center
	if SMLCD then
		if data.showDir then
			-- GPS coords
			lcd.drawText(RIGHT_POS, 49, config[16].v == 0 and string.format("%.5f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), gpsFlags)
			lcd.drawText(RIGHT_POS, 57, config[16].v == 0 and string.format("%.5f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), gpsFlags)
		else
			lcd.drawLine(LEFT_POS + 31, 48, LEFT_POS + 31, 63, SOLID, FORCE)
			-- Distance
			tmp = data.showMax and data.distanceMax or data.distanceLast
			lcd.drawText(LEFT_POS + 29, 57, tmp < 1000 and math.floor(tmp + 0.5) .. units[data.dist_unit] or (string.format("%.1f", tmp / (data.dist_unit == 9 and 1000 or 5280)) .. (data.dist_unit == 9 and "km" or "mi")), SMLSIZE + RIGHT + data.telemFlags)
			lcd.drawText(LEFT_POS + 10, 49, "Dist", SMLSIZE)
			icons.home(LEFT_POS + 2, 49)
			-- Altitude
			tmp = data.showMax and data.altitudeMax or data.altitude
			lcd.drawText(RIGHT_POS, 57, math.floor(tmp + 0.5) .. units[data.alt_unit], SMLSIZE + RIGHT + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
			lcd.drawText(RIGHT_POS, 49, "Alt", SMLSIZE + RIGHT)
			if data.altHold then
				icons.lock(RIGHT_POS - 20, 49)
			end
		end
	end
	-- Min/Max
	if not data.showDir and data.showMax then
		lcd.drawText(RIGHT_POS, 9, "\192", SMLSIZE + RIGHT)
	end

	if data.startup == 0 then
		-- Altitude graph
		local BOTTOM = SMLCD and 47 or 63
		tmp = (SMLCD and 30 or 40) / (data.altMax - data.altMin)
		lcd.drawLine(RIGHT_POS - 60, BOTTOM,  RIGHT_POS - 1, BOTTOM, SOLID, SMLCD and FORCE or GREY_DEFAULT + FORCE)
		for i = 1, 60 do
			local cx = RIGHT_POS - 61 + i
			local cy = math.floor(BOTTOM - (data.alt[((data.altCur - 2 + i) % 60) + 1] - data.altMin) * tmp)
			if cy < BOTTOM then
				lcd.drawLine(cx, cy, cx, BOTTOM - 1, SOLID, SMLCD and FORCE or GREY_DEFAULT + FORCE)
			end
			if (i ~= 1 or not SMLCD) and (i - 1) % (60 / config[28].v) == 0 then
				lcd.drawLine(cx, BOTTOM - (SMLCD and 30 or 40), cx, BOTTOM, DOTTED, 0)
			end
		end
		if data.altMin < -1 then
			local cy = data.altMin * tmp + BOTTOM
			lcd.drawLine(RIGHT_POS - 60, cy, RIGHT_POS - 1, cy, DOTTED, 0)
		end
		if not SMLCD then
			lcd.drawText(RIGHT_POS - 60, 19, math.floor(data.altMax + 0.5) .. units[data.alt_unit], SMLSIZE + RIGHT)
		end

		-- Orientation
		if not SMLCD and data.telem then
			if data.showDir or data.headingRef == -1 then
				lcd.drawText(LEFT_POS + 12, 29, "N", SMLSIZE)
				lcd.drawText(LEFT_POS + 25 - (data.heading < 100 and 3 or 0) - (data.heading < 10 and 3 or 0), 57, math.floor(data.heading + 0.5) % 360 .. "\64", SMLSIZE + RIGHT + data.telemFlags)
				tmp = data.heading
			else
				tmp = data.heading - data.headingRef
			end
			local r1 = math.rad(tmp)
			local r2 = math.rad(tmp + 145)
			local r3 = math.rad(tmp - 145)
			local x1, y1, x2, y2, x3, y3 = calcDir(r1, r2, r3, LEFT_POS + 14, 45, 7)
			if data.headingHold then
				lcd.drawFilledRectangle((x2 + x3) * 0.5 - 1, (y2 + y3) * 0.5 - 1, 3, 3, SOLID)
			else
				lcd.drawLine(x2, y2, x3, y3, SMLCD and DOTTED or SOLID, FORCE + (SMLCD and 0 or GREY_DEFAULT))
			end
			lcd.drawLine(x1, y1, x2, y2, SOLID, FORCE)
			lcd.drawLine(x1, y1, x3, y3, SOLID, FORCE)
		end
	end

	-- Variometer
	if config[7].v % 2 == 1 then
		lcd.drawLine(RIGHT_POS, 8, RIGHT_POS, 63, SOLID, FORCE)
		lcd.drawLine(RIGHT_POS + (SMLCD and 4 or 6), 8, RIGHT_POS + (SMLCD and 4 or 6), 63, SOLID, FORCE)
		lcd.drawLine(RIGHT_POS + 1, 35, RIGHT_POS + (SMLCD and 3 or 5), 35, SMLCD and DOTTED or SOLID, SMLCD and 0 or GREY_DEFAULT)
		if data.armed then
			tmp = math.log(1 + math.min(math.abs(0.6 * (data.vspeed_unit == 6 and data.vspeed * 0.3048 or data.vspeed)), 10)) * (data.vspeed < 0 and -1 or 1)
			local y1 = 36 - (tmp * 11)
			local y2 = 36 - (tmp * 9)
			lcd.drawLine(RIGHT_POS + 1, y1 - 1, RIGHT_POS + (SMLCD and 3 or 5), y2 - 1, SOLID, FORCE)
			lcd.drawLine(RIGHT_POS + 1, y1, RIGHT_POS + (SMLCD and 3 or 5), y2, SOLID, FORCE)
		end
	else
		lcd.drawLine(RIGHT_POS, 8, RIGHT_POS, 63, SOLID, FORCE)
	end

	-- Right data - GPS
	lcd.drawText(LCD_W, data.crsf and 20 or 8, data.satellites % 100, MIDSIZE + RIGHT + data.telemFlags)
	icons.gps(LCD_W - (SMLCD and 23 or 22), data.crsf and 24 or 12)
	if data.crsf then
		lcd.drawText(LCD_W, SMLCD and 9 or 11, data.tpwr < 1000 and data.tpwr .. "mW" or data.tpwr * 0.001 .. "W", SMLSIZE + RIGHT + data.telemFlags)
	else
		lcd.drawText(LCD_W + 1, SMLCD and 43 or 24, math.floor(data.gpsAlt + 0.5) .. units[data.gpsAlt_unit], gpsFlags)
	end
	if SMLCD then
		if data.crsf == false then
			lcd.drawText(LCD_W + 1, config[22].v == 0 and 32 or 22, "HDOP", RIGHT + SMLSIZE)
		end
		hdopGraph(LCD_W - 12, config[22].v == 0 and (data.crsf and 37 or 24) or 31, MIDSIZE, SMLCD)
	else
		hdopGraph(LCD_W - 39, data.crsf and 24 or 10, MIDSIZE, SMLCD)
		if data.crsf == false then
			lcd.drawText(LCD_W - (config[22].v == 0 and 24 or 25), config[22].v == 0 and 18 or 20, "HDOP", RIGHT + SMLSIZE)
		end
		lcd.drawText(LCD_W + 1, 33, config[16].v == 0 and string.format("%.5f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), gpsFlags)
		lcd.drawText(LCD_W + 1, 42, config[16].v == 0 and string.format("%.5f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), gpsFlags)
		lcd.drawText(RIGHT_POS + 8, 57, data.crsf and "LQ" or "RSSI", SMLSIZE)
	end
	lcd.drawLine(RIGHT_POS + (config[7].v % 2 == 1 and (SMLCD and 5 or 7) or 0), 50, LCD_W, 50, SOLID, FORCE)
	local rssiFlags = RIGHT + ((not data.telem or data.rssi < data.rssiLow) and FLASH or 0)
	lcd.drawText(LCD_W - (data.crsf and 6 or 10), 52, math.min(data.showMax and data.rssiMin or data.rssiLast, data.crsf and 100 or 99), MIDSIZE + rssiFlags)
	lcd.drawText(LCD_W, 57, data.crsf and "%" or "dB", SMLSIZE + rssiFlags)

	-- Left data - Battery
	lcd.drawLine(LEFT_DIV, 8, LEFT_DIV, 63, SOLID, FORCE)
	tmp = (not data.telem or data.cell < config[3].v or (data.showFuel and config[23].v == 0 and data.fuel <= config[17].v)) and FLASH or 0
	if data.showFuel then
		if config[23].v > 0 or (data.crsf and data.showMax) then
			lcd.drawText(LEFT_DIV, data.showCurr and 8 or 10, (data.crsf and data.fuelRaw or data.fuel), MIDSIZE + RIGHT + tmp)
			lcd.drawText(LEFT_DIV, data.showCurr and 20 or 23, data.fUnit[data.crsf and 1 or config[23].v], SMLSIZE + RIGHT + tmp)
		else
			lcd.drawText(LEFT_DIV - 5, data.showCurr and 8 or 12, data.fuel, DBLSIZE + RIGHT + tmp)
			lcd.drawText(LEFT_DIV, data.showCurr and 17 or 21, "%", SMLSIZE + RIGHT + tmp)
		end
end
	lcd.drawText(LEFT_DIV - 5, data.showCurr and 25 or 32, string.format(config[1].v == 0 and "%.2f" or "%.1f", config[1].v == 0 and (data.showMax and data.cellMin or data.cell) or (data.showMax and data.battMin or data.batt)), DBLSIZE + RIGHT + tmp)
	lcd.drawText(LEFT_DIV, data.showCurr and 34 or 41, "V", SMLSIZE + RIGHT + tmp)
	if data.showCurr then
		tmp = data.showMax and data.currentMax or data.current
		lcd.drawText(LEFT_DIV - 5, 42, tmp >= 99.5 and math.floor(tmp + 0.5) or string.format("%.1f", tmp), MIDSIZE + RIGHT + data.telemFlags)
		lcd.drawText(LEFT_DIV, 47, "A", SMLSIZE + RIGHT + data.telemFlags)
	end
	lcd.drawLine(0, data.showCurr and 55 or 53, LEFT_DIV, data.showCurr and 55 or 53, SOLID, FORCE)
	tmp = data.showMax and data.speedMax or data.speed
	lcd.drawText(LEFT_DIV, data.showCurr and 57 or 56, tmp >= 99.5 and math.floor(tmp + 0.5) .. units[data.speed_unit] or string.format("%.1f", tmp) .. units[data.speed_unit], SMLSIZE + RIGHT + data.telemFlags)

	-- Left data - Wide screen
	if not SMLCD then
		lcd.drawLine(LEFT_POS, 8, LEFT_POS, 63, SOLID, FORCE)
		-- Altitude
		tmp = data.showMax and data.altitudeMax or data.altitude
		local tmp2 = data.alt_unit == 9 and 6 or 2
		lcd.drawText(LEFT_DIV + 2, 9, "Alt", SMLSIZE)
		lcd.drawText(LEFT_POS - tmp2, data.alt_unit == 9 and 21 or 17, units[data.alt_unit], SMLSIZE + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
		lcd.drawText(LEFT_POS - tmp2, 16, math.floor(tmp + 0.5), MIDSIZE + RIGHT + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
		if data.altHold then
			icons.lock(LEFT_POS - 6, 9)
		end
		-- Distance
		tmp = data.showMax and data.distanceMax or data.distanceLast
		tmp2 = data.dist_unit == 9 and (tmp < 1000 and 6 or 11) or (tmp < 1000 and 2 or 10)
		lcd.drawText(LEFT_DIV + 2, 30, "Dist", SMLSIZE)
		lcd.drawText(LEFT_POS - tmp2, (data.dist_unit == 9 or tmp >= 1000) and 42 or 38, tmp < 1000 and units[data.dist_unit] or (data.dist_unit == 9 and "km" or "mi"), SMLSIZE + data.telemFlags)
		lcd.drawText(LEFT_POS - tmp2, 37, tmp < 1000 and math.floor(tmp + 0.5) or string.format("%.1f", tmp / (data.dist_unit == 9 and 1000 or 5280)), MIDSIZE + RIGHT + data.telemFlags)
		--Pitch
		lcd.drawLine(LEFT_DIV, 50, LEFT_POS, 50, SOLID, FORCE)
		lcd.drawText(LEFT_DIV + 5, 54, pitch > 0 and "\194" or (pitch == 0 and "->" or "\195"), SMLSIZE)
		lcd.drawText(LEFT_POS, 53, "\64", SMLSIZE + RIGHT + data.telemFlags)
		lcd.drawText(LEFT_POS - 4, 52, pitch, MIDSIZE + RIGHT + data.telemFlags)
	end
end

return view