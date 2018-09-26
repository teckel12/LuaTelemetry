local function view(data, config, modes, units, gpsDegMin, gpsIcon, lockIcon, homeIcon, hdopGraph, VERSION, SMLCD, FLASH, FILE_PATH)

	local LEFT_DIV = 36
	local LEFT_POS = SMLCD and LEFT_DIV or 74
	local RIGHT_POS = SMLCD and LCD_W - 31 or LCD_W - 53
	local X_CNTR = (RIGHT_POS + LEFT_POS) / 2 - 1
	local gpsFlags = SMLSIZE + RIGHT + ((not data.telem or not data.gpsFix) and FLASH or 0)
	local tmp, pitch

	-- Startup message
	if data.startup == 2 then
		if not SMLCD then
			lcd.drawText(LEFT_POS + 7, 28, "Lua Telemetry")
		end
		lcd.drawText(X_CNTR - 10, SMLCD and 34 or 40, "v" .. VERSION)
	end

	-- Flight modes
	tmp = X_CNTR - (SMLCD and 16 or 19)
	lcd.drawText(tmp + 1, 9, modes[data.modeId].t, SMLSIZE + modes[data.modeId].f)
	if data.headFree then
		lcd.drawText(tmp, 9, "HF", SMLSIZE + FLASH + RIGHT)
	end

	-- Radar bottom
	if SMLCD then
		if data.showDir and (not data.armed or not data.telem) then
			-- GPS coords
			lcd.drawText(RIGHT_POS, 50, config[16].v == 0 and string.format("%.5f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), gpsFlags)
			lcd.drawText(RIGHT_POS, 57, config[16].v == 0 and string.format("%.5f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), gpsFlags)
		else
			-- Distance
			tmp = data.showMax and data.distanceMax or data.distanceLast
			lcd.drawText(LEFT_POS + 25, 57, data.startup > 0 and "Dist " or (tmp < 1000 and math.floor(tmp + 0.5) .. units[data.dist_unit] or (string.format("%.1f", tmp / (data.dist_unit == 9 and 1000 or 5280)) .. (data.dist_unit == 9 and "km" or "mi"))), SMLSIZE + RIGHT + data.telemFlags)
			-- Altitude
			tmp = data.showMax and data.altitudeMax or data.altitude
			lcd.drawText(RIGHT_POS, 57, data.startup > 0 and "Alt" or (math.floor(tmp + 0.5) .. units[data.alt_unit]), SMLSIZE + RIGHT + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
			if data.altHold then
				lockIcon(RIGHT_POS - 6, 50)
			end
		end
	elseif (data.showDir or data.headingRef < 0) and not data.showMax then
		-- Heading
		lcd.drawText(X_CNTR + 15, 57, math.floor(data.heading + 0.5) % 360 .. "\64", SMLSIZE + RIGHT + data.telemFlags)
	end
	-- Min/Max
	if not data.showDir and data.showMax then
		lcd.drawText(X_CNTR + 1, 57, "\192", SMLSIZE)
	end

	-- Radar
	if data.startup == 0 then
		if data.gpsHome ~= false and data.showHead then
			-- Launch/north-based orientation
			if data.showDir or data.headingRef < 0 then
				lcd.drawText(LEFT_POS + 2, 35, "W", SMLSIZE)
				lcd.drawText(RIGHT_POS, 35, "E", SMLSIZE + RIGHT)
				tmp = 0
			else
				tmp = data.headingRef
			end
			-- Craft location
			local d = data.distanceLast >= data.distRef and math.min(math.max((data.distanceLast / math.max(math.min(data.distanceMax, data.distanceLast * 4), data.distRef * 2.5)) * 27, 7), 27) or 1
			local o1 = math.rad(data.gpsHome.lat)
			local a1 = math.rad(data.gpsHome.lon)
			local o2 = math.rad(data.gpsLatLon.lat)
			local a2 = math.rad(data.gpsLatLon.lon)
			local y = math.sin(a2 - a1) * math.cos(o2)
			local x = (math.cos(o1) * math.sin(o2)) - (math.sin(o1) * math.cos(o2) * math.cos(a2 - a1))
			local bearing = math.deg(math.atan2(y, x)) - tmp
			local rad1 = math.rad(bearing)
			local cx = math.floor(math.sin(rad1) * d + 0.5)
			local cy = math.floor(math.cos(rad1) * d + 0.5)
			-- Home position
			local hx = X_CNTR + 3 - (d > 17 and cx / 2 or 0)
			local hy = 38 + (d > 17 and cy / 2 or 0)
			if d >= 9 then
				homeIcon(hx - 3, hy - 3)
			elseif d > 1 then
				lcd.drawFilledRectangle(hx - 1, hy - 1, 3, 3, SOLID)
			elseif SMLCD and not data.armed then
				hy = hy + 7
			end
			-- Shift craft location
			cx = cx + hx
			cy = hy - cy
			-- Orientation
			rad1 = math.rad(data.heading - tmp)
			local rad2 = math.rad(data.heading - tmp + (data.headingHold and 140 or 145))
			local rad3 = math.rad(data.heading - tmp - (data.headingHold and 140 or 145))
			tmp = d == 1 and 8 or 5
			local x1 = math.sin(rad1) * tmp + cx
			local y1 = cy - math.cos(rad1) * tmp
			local x2 = math.sin(rad2) * tmp + cx
			local y2 = cy - math.cos(rad2) * tmp
			local x3 = math.sin(rad3) * tmp + cx
			local y3 = cy - math.cos(rad3) * tmp
			if data.headingHold then
				lcd.drawFilledRectangle((x2 + x3) / 2 - 1.5, (y2 + y3) / 2 - 1.5, 4, 4, SOLID)
			else
				lcd.drawLine(x2, y2, x3, y3, SMLCD and DOTTED or SOLID, FORCE + (SMLCD and 0 or GREY_DEFAULT))
			end
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
	lcd.drawLine(LEFT_DIV, 8, LEFT_DIV, 63, SOLID, FORCE)
	tmp = (not data.telem or data.cell < config[3].v or (data.showFuel and config[23].v == 0 and data.fuel <= config[17].v)) and FLASH or 0
	if data.showFuel then
		if config[23].v == 0 then
			lcd.drawText(LEFT_DIV - 5, data.showCurr and 8 or 12, data.fuel, DBLSIZE + RIGHT + tmp)
			lcd.drawText(LEFT_DIV, data.showCurr and 17 or 21, "%", SMLSIZE + RIGHT + tmp)
		else
			lcd.drawText(LEFT_DIV, data.showCurr and 8 or 10, data.fuel, MIDSIZE + RIGHT + tmp)
			lcd.drawText(LEFT_DIV, data.showCurr and 20 or 23, config[23].l[config[23].v], SMLSIZE + RIGHT + tmp)
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

	-- Second left column for wide screen
	if not SMLCD then
		lcd.drawLine(LEFT_POS, 8, LEFT_POS, 63, SOLID, FORCE)
		-- Altitude
		tmp = data.showMax and data.altitudeMax or data.altitude
		lcd.drawText(LEFT_DIV + 2, 9, "Alt", SMLSIZE)
		lcd.drawText(LEFT_POS, 16, math.floor(tmp + 0.5) .. units[data.alt_unit], MIDSIZE + RIGHT + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
		if data.altHold then
			lockIcon(LEFT_POS - 6, 9)
		end
		-- Distance
		tmp = data.showMax and data.distanceMax or data.distanceLast
		lcd.drawText(LEFT_DIV + 2, 30, "Dist", SMLSIZE)
		lcd.drawText(LEFT_POS, 37, tmp < 1000 and (math.floor(tmp + 0.5) .. units[data.dist_unit]) or (string.format("%.1f", tmp / (data.dist_unit == 9 and 1000 or 5280)) .. (data.dist_unit == 9 and "km" or "mi")), MIDSIZE + RIGHT + data.telemFlags)
		--Pitch
		if data.pitchRoll then
			pitch = (math.abs(data.roll) > 900 and -1 or 1) * (270 - data.pitch / 10) % 180
		else
			pitch = 90 - math.deg(math.atan2(data.accx * (data.accz >= 0 and -1 or 1), math.sqrt(data.accy * data.accy + data.accz * data.accz)))
		end
		tmp = pitch - 90
		tmp = tmp >= 0 and math.floor(tmp + 0.5) or math.ceil(tmp - 0.5)
		lcd.drawText(LEFT_DIV + 6, 55, tmp > 0 and "\194" or (tmp == 0 and "->" or "\195"), SMLSIZE)
		lcd.drawText(LEFT_POS, 53, "\64", SMLSIZE + RIGHT + data.telemFlags)
		lcd.drawText(LEFT_POS - 4, 52, tmp, MIDSIZE + RIGHT + data.telemFlags)
	end
end

return view