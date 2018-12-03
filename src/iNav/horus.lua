local function view(data, config, modes, units, labels, gpsDegMin, hdopGraph, icons, calcTrig, calcDir, VERSION, SMLCD, FLASH, FILE_PATH)

	--local SKY = 982 --lcd.RGB(0, 121, 180)
	local GROUND = 25121 --lcd.RGB(98, 68, 8)
	--local SKY2 = 8943 --lcd.RGB(32, 92, 122)
	local GROUND2 = 20996 --lcd.RGB(81, 65, 36)
	local MAP = 13381 --lcd.RGB(51, 137, 47)
	local DATA = 11 --lcd.RGB(0, 0, 90)
	local DKGREY = 12678 --lcd.RGB(48, 48, 48)
	local RIGHT_POS = 270
	local X_CNTR = 134 --(RIGHT_POS + LEFT_POS [0]) / 2 - 1
	local HEADING_DEG = 190
	local PIXEL_DEG = RIGHT_POS / HEADING_DEG --(RIGHT_POS - LEFT_POS [0]) / HEADING_DEG
	local BOTTOM = 146
	local Y_CNTR = 83 --(TOP + BOTTOM) / 2
	local tmp, pitch

	local function attitude(r, adj)
		local py = Y_CNTR - math.cos(math.rad(pitch - adj)) * 170
		local x1 = math.sin(roll1) * r + X_CNTR
		local y1 = py - (math.cos(roll1) * r)
		local x2 = math.sin(roll2) * r + X_CNTR
		local y2 = py - (math.cos(roll2) * r)
		if r == 200 then
			local a = (y1 - y2) / (x1 - x2 + .001) * 2
			local y = y2 - ((x2 + 1) * a) / 2
			lcd.setColor(CUSTOM_COLOR, GROUND2)
			tmp = upsideDown and TOP or BOTTOM - 1
			for x = 1, RIGHT_POS - 2, 2 do
				if x == 39 then
					lcd.setColor(CUSTOM_COLOR, GROUND)
				elseif x == RIGHT_POS - 43 then
					lcd.setColor(CUSTOM_COLOR, GROUND2)
				end
				local yy = y + 0.5
				if (not upsideDown and yy < BOTTOM) or (upsideDown and yy > 7) then
					local tmp2 = math.min(math.max(yy, 20), BOTTOM)
					lcd.drawLine(x, tmp, x, tmp2, SOLID, CUSTOM_COLOR)
					lcd.drawLine(x + 1, tmp, x + 1, tmp2, SOLID, CUSTOM_COLOR)
				end
				y = y + a
			end
		elseif (y1 > 20 or y2 > 20) and (y1 < BOTTOM - 15 or y2 < BOTTOM - 15) then
			lcd.setColor(CUSTOM_COLOR, adj % 10 == 0 and WHITE or (adj % 5 == 0 and LIGHTGREY or GREY))
			lcd.drawLine(x1, y1, x2, y2, SOLID, CUSTOM_COLOR)
			if adj % 10 == 0 and adj ~= 0 and y2 > 20 and y2 < BOTTOM - 15 then
				lcd.drawText(x2 - 1, y2 - 8, adj, SMLSIZE + RIGHT)
			end
		end
	end

	local function tics(v, p)
		tmp = math.floor((v + 20) / 10) * 10
		for i = tmp - 40, tmp, 5 do
			local tmp2 = Y_CNTR + ((v - i) * 3) - 9
			if tmp2 > 10 and tmp2 < BOTTOM - 8 then
				lcd.drawLine(p, tmp2 + 8, p + 2, tmp2 + 8, SOLID, CUSTOM_COLOR)
				if i % 10 == 0 and (i >= 0 or p > X_CNTR) and tmp2 < BOTTOM - 23 then
					lcd.drawText(p + (p > X_CNTR and -1 or 4), tmp2, i, SMLSIZE + (p > X_CNTR and RIGHT or 0) + CUSTOM_COLOR)
				end
			end
		end
	end

	-- Setup
	lcd.drawBitmap(icons.bg, 0, 20)
	lcd.setColor(TEXT_COLOR, WHITE)
	lcd.setColor(WARNING_COLOR, data.telem and YELLOW or RED)

	-- Attitude
	--lcd.setColor(CUSTOM_COLOR, SKY2)
	--lcd.drawFilledRectangle(0, 20, RIGHT_POS - 1, BOTTOM - 20, CUSTOM_COLOR)
	--lcd.setColor(CUSTOM_COLOR, SKY)
	--lcd.drawFilledRectangle(39, 20, RIGHT_POS - 82, BOTTOM - 20, CUSTOM_COLOR)
	if data.pitchRoll then
		pitch = (math.abs(data.roll) > 900 and -1 or 1) * (270 - data.pitch / 10) % 180
		roll = (270 - data.roll / 10) % 180
		upsideDown = math.abs(data.roll) > 900
	else
		pitch = 90 - math.deg(math.atan2(data.accx * (data.accz >= 0 and -1 or 1), math.sqrt(data.accy * data.accy + data.accz * data.accz)))
		roll = 90 - math.deg(math.atan2(data.accy * (data.accz >= 0 and 1 or -1), math.sqrt(data.accx * data.accx + data.accz * data.accz)))
		upsideDown = data.accz < 0
	end
	roll1 = math.rad(roll)
	roll2 = math.rad(roll + 180)
	local inside = 45
	local outside = 65
	attitude(200, 0)
	if data.startup == 0 and data.telem then
		tmp = pitch - 90
		local tmp2 = tmp >= 0 and (tmp < 1 and 0 or math.floor(tmp + 0.5)) or (tmp > -1 and 0 or math.ceil(tmp - 0.5))
		if not data.showMax then
			lcd.drawText(X_CNTR - outside, Y_CNTR - 9, tmp2 .. "\64", SMLSIZE + RIGHT)
		end
		tmp2 = math.max(math.min((tmp >= 0 and math.floor(tmp / 5) or math.ceil(tmp / 5)) * 5, 30), -30)
		for x = tmp2 - 20, tmp2 + 20, 2.5 do
			if x ~= 0 then
				attitude(x % 10 == 0 and 20 or (x % 5 == 0 and 15 or 7), x)
			end
		end
	end

	-- Home direction
	if data.showHead and data.armed and data.telem and data.gpsHome ~= false and data.startup == 0 then
		local home = X_CNTR - 1
		if data.distanceLast >= data.distRef then
			local bearing = calcTrig(data.gpsHome, data.gpsLatLon, true) + 540 % 360
			home = math.floor(((bearing - data.heading + (361 + HEADING_DEG / 2)) % 360) * PIXEL_DEG - 2.5)
		else
			lcd.drawText(home - 2, BOTTOM - 27, "  ", FLASH)
		end
		if home >= 3 and home <= RIGHT_POS - 6 then
			lcd.drawBitmap(icons.home, home - 3, BOTTOM - 26)
		end
	end

	-- Heading
	if data.showHead then
		for i = 0, 348.75, 11.25 do
			tmp = math.floor(((i - data.heading + (361 + HEADING_DEG / 2)) % 360) * PIXEL_DEG - 2.5)
			if tmp >= 9 and tmp <= RIGHT_POS - 9 then
				if i % 90 == 0 then
					lcd.drawText(tmp - (i < 270 and 3 or 5), BOTTOM - 15, i == 0 and "N" or (i == 90 and "E" or (i == 180 and "S" or "W")), SMLSIZE)
				elseif i % 45 == 0 then
					lcd.drawText(tmp - (i < 225 and 7 or 9), BOTTOM - 15, i == 45 and "NE" or (i == 135 and "SE" or (i == 225 and "SW" or "NW")), SMLSIZE)
				else
					lcd.drawLine(tmp, BOTTOM - 4, tmp, BOTTOM - 1, SOLID, 0)
				end
			end
		end
		lcd.setColor(CUSTOM_COLOR, DKGREY)
		lcd.drawFilledRectangle(X_CNTR - 18, BOTTOM - 15, 37, 15, CUSTOM_COLOR)
		lcd.drawText(X_CNTR - 15, BOTTOM - 15, "     ", SMLSIZE + data.telemFlags)
		lcd.drawText(X_CNTR + 18, BOTTOM - 15, math.floor(data.heading + 0.5) % 360 .. "\64", SMLSIZE + RIGHT + data.telemFlags)
		--lcd.setColor(CUSTOM_COLOR, LIGHTGREY)
		--lcd.drawRectangle(X_CNTR - 18, BOTTOM - 15, 37, 16, CUSTOM_COLOR)
	end

	-- Speed & Altitude
	lcd.setColor(CUSTOM_COLOR, LIGHTGREY)
	tics(data.speed, 1)
	tics(data.altitude, RIGHT_POS - 4)
	lcd.setColor(CUSTOM_COLOR, DKGREY)
	lcd.drawFilledRectangle(1, Y_CNTR - 8, 38, 16, CUSTOM_COLOR)
	lcd.drawFilledRectangle(RIGHT_POS - 43, Y_CNTR - 8, 42, 16, CUSTOM_COLOR)
	tmp = data.showMax and data.speedMax or data.speed
	lcd.drawText(40, 19, units[data.speed_unit], SMLSIZE)
	lcd.drawText(3, Y_CNTR - 9, "    ", SMLSIZE + data.telemFlags)
	lcd.drawText(39, Y_CNTR - 9, tmp >= 99.5 and math.floor(tmp + 0.5) or string.format("%.1f", tmp), SMLSIZE + RIGHT + data.telemFlags)
	tmp = data.showMax and data.altitudeMax or data.altitude
	lcd.drawText(RIGHT_POS - 43, 19, "Alt " .. units[data.alt_unit], SMLSIZE + RIGHT)
	lcd.drawText(RIGHT_POS - 41, Y_CNTR - 9, "        ", SMLSIZE + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
	lcd.drawText(RIGHT_POS - 1, Y_CNTR - 9, math.floor(tmp + 0.5), SMLSIZE + RIGHT + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
	if data.altHold then
		lcd.drawBitmap(icons.lock, RIGHT_POS - 54, Y_CNTR - 5)
	end
	if data.showMax then
		lcd.drawText(40, Y_CNTR - 11, "\192", 0)
		lcd.drawText(RIGHT_POS - 42, Y_CNTR - 11, "\192", RIGHT)
	end
	--lcd.setColor(CUSTOM_COLOR, LIGHTGREY)
	--lcd.drawLine(0, 20, 0, BOTTOM - 1, SOLID, CUSTOM_COLOR)

	-- Variometer
	if config[7].v % 2 == 1 then
		lcd.setColor(CUSTOM_COLOR, DKGREY)
		lcd.drawFilledRectangle(RIGHT_POS, 20, 10, BOTTOM - 20, CUSTOM_COLOR)
		if data.armed then
			tmp = math.log(1 + math.min(math.abs(0.6 * (data.vspeed_unit == 6 and data.vspeed / 3.28084 or data.vspeed)), 10)) / 2.4 * (data.vspeed < 0 and -1 or 1)
			lcd.setColor(CUSTOM_COLOR, YELLOW)
			lcd.drawLine(RIGHT_POS, Y_CNTR - (tmp * (Y_CNTR - 21)) - 1, RIGHT_POS + 100, Y_CNTR - 1, SOLID, CUSTOM_COLOR)
			lcd.drawLine(RIGHT_POS, Y_CNTR - (tmp * (Y_CNTR - 21)), RIGHT_POS + 100, Y_CNTR, SOLID, CUSTOM_COLOR)
		end
		lcd.setColor(CUSTOM_COLOR, LIGHTGREY)
		--lcd.drawLine(RIGHT_POS - 1, 20, RIGHT_POS - 1, BOTTOM - 1, SOLID, CUSTOM_COLOR)
		lcd.drawLine(RIGHT_POS + 10, 20, RIGHT_POS + 10, BOTTOM - 1, SOLID, CUSTOM_COLOR)
		lcd.setColor(CUSTOM_COLOR, MAP)
		lcd.drawFilledRectangle(RIGHT_POS + 11, 20, 90, BOTTOM - 20, CUSTOM_COLOR)
	--else
	--	lcd.setColor(CUSTOM_COLOR, LIGHTGREY)
	--	lcd.drawLine(RIGHT_POS - 1, 20, RIGHT_POS - 1, BOTTOM - 1, SOLID, CUSTOM_COLOR)
	end

	-- Radar
	local LEFT_POS = RIGHT_POS + (config[7].v % 2 == 1 and 11 or 0)
	RIGHT_POS = 479
	X_CNTR = (RIGHT_POS + LEFT_POS) / 2 - 1
	tmp = data.showMax and data.distanceMax or data.distanceLast
	local dist = tmp < 1000 and math.floor(tmp + 0.5) .. units[data.dist_unit] or (string.format("%.1f", tmp / (data.dist_unit == 9 and 1000 or 5280)) .. (data.dist_unit == 9 and "km" or "mi"))
	if data.startup == 0 then
		-- Launch/north-based orientation
		if data.showDir or data.headingRef < 0 then
			lcd.drawText(LEFT_POS + 2, Y_CNTR - 9, "W", SMLSIZE)
			lcd.drawText(RIGHT_POS, Y_CNTR - 9, "E", SMLSIZE + RIGHT)
			tmp = 0
		else
			tmp = data.headingRef
		end
		local cx, cy, d
		if data.gpsHome ~= false then
			-- Craft location
			d = data.distanceLast >= data.distRef and math.min(math.max((data.distanceLast / math.max(math.min(data.distanceMax, data.distanceLast * 4), data.distRef * 10)) * 100, 7), 100) or 1
			local bearing = calcTrig(data.gpsHome, data.gpsLatLon, true) - tmp
			local rad1 = math.rad(bearing)
			cx = math.floor(math.sin(rad1) * d + 0.5)
			cy = math.floor(math.cos(rad1) * d + 0.5)
			-- Home position
			local hx = X_CNTR + 2 - (d > 9 and cx / 2 or 0)
			local hy = Y_CNTR + (d > 9 and cy / 2 or 0)
			if d >= 12 then
				lcd.drawBitmap(icons.home, hx - 4, hy - 5)
			elseif d > 1 then
				lcd.drawFilledRectangle(hx - 1, hy - 1, 3, 3, SOLID)
			end
			-- Shift craft location
			cx = d == 1 and X_CNTR + 2 or cx + hx
			cy = d == 1 and Y_CNTR or hy - cy
		else
			cx = X_CNTR + 2
			cy = Y_CNTR
			d = 1
		end
		-- Orientation
		local r1 = math.rad(data.heading - tmp)
		local r2 = math.rad(data.heading - tmp + 145)
		local r3 = math.rad(data.heading - tmp - 145)
		local x1, y1, x2, y2, x3, y3 = calcDir(r1, r2, r3, cx, cy, 8)
		lcd.setColor(CUSTOM_COLOR, GREY)
		lcd.drawLine(x2, y2, x3, y3, SOLID, CUSTOM_COLOR)
		lcd.drawLine(x1, y1, x2, y2, SOLID, TEXT_COLOR)
		lcd.drawLine(x1, y1, x3, y3, SOLID, TEXT_COLOR)
		if data.showMax then
			lcd.drawText(LEFT_POS, BOTTOM - 19, "\192", 0)
		end
		lcd.drawText(LEFT_POS + (data.showMax and 12 or 2), BOTTOM - 16, dist, SMLSIZE + data.telemFlags)
	end

	-- Startup message
	if data.startup == 2 then
		lcd.drawText(X_CNTR - 79, 54, "Lua Telemetry", MIDSIZE)
		lcd.drawText(X_CNTR - 39, 84, "v" .. VERSION, MIDSIZE)
	end

	-- Data
	local X1 = 140
	local X2 = 234
	local X3 = 346
	local TOP = BOTTOM + 1
	BOTTOM = 271

	--lcd.setColor(CUSTOM_COLOR, DATA)
	--lcd.drawFilledRectangle(0, TOP, LCD_W, BOTTOM - TOP + 1, CUSTOM_COLOR)

	-- Box 1 (fuel, battery, rssi)
	tmp = (not data.telem or data.cell < config[3].v or (data.showFuel and config[23].v == 0 and data.fuel <= config[17].v)) and FLASH or 0
	if data.showFuel then
		if config[23].v == 0 then
			lcd.drawText(X1 - 3, TOP, data.fuel .. "%", MIDSIZE + RIGHT + tmp)
			lcd.drawText(0, TOP + 9, labels[1], SMLSIZE)
			local red = data.fuel >= config[18].v and math.max(math.floor((100 - data.fuel) / (100 - config[18].v) * 255), 0) or 255
			local green = data.fuel < config[18].v and math.max(math.floor((data.fuel - config[17].v) / (config[18].v - config[17].v) * 255), 0) or 255
			lcd.setColor(CUSTOM_COLOR, lcd.RGB(red, green, 60))
			lcd.drawGauge(0, TOP + 26, X1 - 3, 15, math.min(data.fuel, 99), 100, CUSTOM_COLOR)
		else
			lcd.drawText(X1, TOP + 1, data.fuel .. config[23].l[config[23].v], MIDSIZE + RIGHT + tmp)
		end
	end

	local val = data.showMax and data.cellMin or data.cell
	lcd.drawText(X1 - 3, TOP + 42, string.format(config[1].v == 0 and "%.2f" or "%.1f", config[1].v == 0 and val or (data.showMax and data.battMin or data.batt)) .. "v", MIDSIZE + RIGHT + tmp)
	lcd.drawText(0, TOP + 51, labels[2], SMLSIZE)
	local red = val >= config[2].v and math.max(math.floor((4.2 - val) / (4.2 - config[2].v) * 255), 0) or 255
	local green = val < config[2].v and math.max(math.floor((val - config[3].v) / (config[2].v - config[3].v) * 255), 0) or 255
	lcd.setColor(CUSTOM_COLOR, lcd.RGB(red, green, 60))
	lcd.drawGauge(0, TOP + 68, X1 - 3, 15, math.min(math.max(val - config[3].v + 0.1, 0) * (100 / (4.2 - config[3].v + 0.1)), 99), 100, CUSTOM_COLOR)

	tmp = (not data.telem or data.rssi < data.rssiLow) and FLASH or 0
	val = data.showMax and data.rssiMin or data.rssiLast
	lcd.drawText(X1 - 3, TOP + 84, val .. "dB", MIDSIZE + RIGHT + tmp)
	--lcd.drawText(0, TOP + 93, "RSSI", SMLSIZE)
	local red = val >= data.rssiLow and math.max(math.floor((100 - val) / (100 - data.rssiLow) * 255), 0) or 255
	local green = val < data.rssiLow and math.max(math.floor((val - data.rssiCrit) / (data.rssiLow - data.rssiCrit) * 255), 0) or 255
	lcd.setColor(CUSTOM_COLOR, lcd.RGB(red, green, 60))
	lcd.drawGauge(0, TOP + 110, X1 - 3, 15, math.min(val, 99), 100, CUSTOM_COLOR)

	-- Box 2 (altitude, distance, current)
	tmp = data.showMax and data.altitudeMax or data.altitude
	lcd.drawText(X1 + 9, TOP + 1, labels[4], SMLSIZE)
	lcd.drawText(X2, TOP + 12, math.floor(tmp + 0.5) .. units[data.alt_unit], MIDSIZE + RIGHT + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
	lcd.drawText(X1 + 9, TOP + 44, labels[5], SMLSIZE)
	lcd.drawText(X2, TOP + 55, dist, MIDSIZE + RIGHT + data.telemFlags)
	if data.showCurr then
		tmp = data.showMax and data.currentMax or data.current
		lcd.drawText(X1 + 9, TOP + 87, labels[3], SMLSIZE)
		lcd.drawText(X2, TOP + 98, (tmp >= 99.5 and math.floor(tmp + 0.5) or string.format("%.1f", tmp)) .. "A", MIDSIZE + RIGHT + data.telemFlags)
	end
	--lcd.setColor(CUSTOM_COLOR, DATA)
	--lcd.drawFilledRectangle(X1 + 6, TOP + 11, X2 - X1 - 6, 4, CUSTOM_COLOR)
	--lcd.drawFilledRectangle(X1 + 6, TOP + 54, X2 - X1 - 6, 4, CUSTOM_COLOR)
	--lcd.drawFilledRectangle(X1 + 6, TOP + 97, X2 - X1 - 6, 4, CUSTOM_COLOR)

	-- Box 3 (flight modes, orientation)
	lcd.drawText(X2 + 20, TOP, modes[data.modeId].t, modes[data.modeId].f == 3 and WARNING_COLOR or 0)
	if data.altHold then
		lcd.drawBitmap(icons.lock, X1 + 63, TOP + 4)
	end
	if data.headFree then
		lcd.drawText(X2 + 7, TOP + 19, "HF", FLASH)
	end

	if data.showHead then
		if data.showDir or data.headingRef < 0 then
			lcd.drawText((X2 + X3) / 2, TOP + 18, "N", SMLSIZE)
			--lcd.drawText((X2 + X3) / 2, BOTTOM - 15, "S", SMLSIZE)
			lcd.drawText(X3 - 4, 211, "E", SMLSIZE + RIGHT)
			lcd.drawText(X2 + 10, 211, "W", SMLSIZE)
			lcd.drawText(X2 + 78, BOTTOM - 15, math.floor(data.heading + 0.5) % 360 .. "\64", SMLSIZE + RIGHT + data.telemFlags)
			tmp = 0
		else
			tmp = data.headingRef
		end
		local r1 = math.rad(data.heading - tmp)
		local r2 = math.rad(data.heading - tmp + 145)
		local r3 = math.rad(data.heading - tmp - 145)
		local x1, y1, x2, y2, x3, y3 = calcDir(r1, r2, r3, (X2 + X3) / 2 + 4, 219, 25)
		if data.headingHold then
			lcd.drawFilledRectangle((x2 + x3) / 2 - 2, (y2 + y3) / 2 - 2, 5, 5, SOLID)
		else
			lcd.setColor(CUSTOM_COLOR, GREY)
			lcd.drawLine(x2, y2, x3, y3, SOLID, CUSTOM_COLOR)
		end
		lcd.drawLine(x1, y1, x2, y2, SOLID, TEXT_COLOR)
		lcd.drawLine(x1, y1, x3, y3, SOLID, TEXT_COLOR)
	end

	-- Box 4 (GPS info, speed)
	tmp = ((data.armed or data.modeId == 6) and data.hdop < 11 - config[21].v * 2) or not data.telem
	lcd.drawText(X3 + 48, TOP, (data.hdop == 0 and not data.gpsFix) and "-- --" or (9 - data.hdop) / 2 + 0.8, MIDSIZE + RIGHT + (tmp and FLASH or 0))
	--lcd.drawText(X3 + 11, TOP + 24, "HDOP", SMLSIZE)
	hdopGraph(X3 + 65, TOP + 23)
	lcd.drawText(RIGHT_POS + 1, TOP, data.satellites % 100, MIDSIZE + RIGHT + data.telemFlags)
	tmp = RIGHT + ((not data.telem or not data.gpsFix) and FLASH or 0)
	lcd.drawText(RIGHT_POS, TOP + 28, math.floor(data.gpsAlt + 0.5) .. (data.gpsAlt_unit == 10 and "'" or units[data.gpsAlt_unit]), MIDSIZE + tmp)
	lcd.drawText(RIGHT_POS, TOP + 54, config[16].v == 0 and string.format("%.6f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), tmp)
	lcd.drawText(RIGHT_POS, TOP + 74, config[16].v == 0 and string.format("%.6f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), tmp)
	tmp = data.showMax and data.speedMax or data.speed
	lcd.drawText(RIGHT_POS + 1, TOP + 98, tmp >= 99.5 and math.floor(tmp + 0.5) .. units[data.speed_unit] or string.format("%.1f", tmp) .. units[data.speed_unit], MIDSIZE + RIGHT + data.telemFlags)

	if data.showMax then
		lcd.setColor(CUSTOM_COLOR, GREY)
		lcd.drawText(1, TOP + 64, "\193", CUSTOM_COLOR)
		lcd.drawText(1, TOP + 106, "\193", CUSTOM_COLOR)
		lcd.drawText(X1 + 4, TOP + 18, "\192")
		lcd.drawText(X1 + 4, TOP + 61, "\192")
		lcd.drawText(X1 + 4, TOP + 104, "\192")
		lcd.drawText(X3 + 4, TOP + 104, "\192")
	end

	-- Attitude overlay
	lcd.drawBitmap(icons.fg, 1, 74)

	--lcd.setColor(CUSTOM_COLOR, GREY)
	--lcd.drawLine(X1 + 3, TOP, X1 + 3, BOTTOM, DOTTED, CUSTOM_COLOR)
	--lcd.drawLine(X2 + 3, TOP, X2 + 3, BOTTOM, DOTTED, CUSTOM_COLOR)
	--lcd.drawLine(X3 + 3, TOP, X3 + 3, BOTTOM, DOTTED, CUSTOM_COLOR)
	--lcd.drawLine(X3 + 3, TOP + 95, RIGHT_POS, TOP + 95, DOTTED, CUSTOM_COLOR)
	--lcd.setColor(CUSTOM_COLOR, LIGHTGREY)
	--lcd.drawLine(0, TOP - 1, LCD_W - 1, TOP - 1, SOLID, CUSTOM_COLOR)

	lcd.setColor(WARNING_COLOR, YELLOW)

end

return view