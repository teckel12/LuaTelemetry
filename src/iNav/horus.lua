local function view(data, config, modes, units, gpsDegMin, gpsIcon, lockIcon, homeIcon, hdopGraph, calcTrig, calcDir, VERSION, SMLCD, FLASH, FILE_PATH)

	-- 480 x 272
	GREY_DEFAULT = 0
	FORCE = 0
	ERASE = 0

	local SKY = lcd.RGB(0, 121, 180)
	local GROUND = lcd.RGB(98, 68, 8)
	local SKY2 = lcd.RGB(32, 92, 122)
	local GROUND2 = lcd.RGB(81, 65, 36)
	local MAP = lcd.RGB(51, 137, 47)
	local DATA = 15 -- lcd.RGB(0, 0, 120)
	--local GREEN = lcd.RGB(0, 255, 0)
	--local LTRED = lcd.RGB(255, 90, 90)

	local LEFT_POS = 0
	local RIGHT_POS = LCD_W / 2 + 30
	local X_CNTR = (RIGHT_POS + LEFT_POS) / 2 - 1
	local HEADING_DEG = 190
	local PIXEL_DEG = (RIGHT_POS - LEFT_POS) / HEADING_DEG
	local gpsFlags = SMLSIZE + RIGHT + ((not data.telem or not data.gpsFix) and FLASH or 0)
	local tmp, pitch
	local Y_CNTR = 83
	local BOTTOM = 146

	local function attitude(r, adj)
		local py = Y_CNTR - math.cos(math.rad(pitch - adj)) * 170
		local x1 = math.sin(roll1) * r + X_CNTR
		local y1 = py - (math.cos(roll1) * r)
		local x2 = math.sin(roll2) * r + X_CNTR
		local y2 = py - (math.cos(roll2) * r)
		if r == 200 then
			local a = (y1 - y2) / (x1 - x2 + .001) * 2
			local y = y2 - ((x2 - LEFT_POS + 1) * a) / 2
			lcd.setColor(TEXT_COLOR, GROUND2)
			tmp = upsideDown and 20 or BOTTOM
			for x = LEFT_POS + 1, RIGHT_POS - 2, 2 do
				if x == LEFT_POS + 39 then
					lcd.setColor(TEXT_COLOR, GROUND)
				elseif x == RIGHT_POS - 43 then
					lcd.setColor(TEXT_COLOR, GROUND2)
				end
				local yy = y + 0.5
				if (not upsideDown and yy < BOTTOM) or (upsideDown and yy > 7) then
					local tmp2 = math.min(math.max(yy, 20), BOTTOM)
					lcd.drawLine(x, tmp, x, tmp2, SOLID, 0)
					lcd.drawLine(x + 1, tmp, x + 1, tmp2, SOLID, 0)
				end
				y = y + a
			end
		elseif (y1 > 20 or y2 > 20) and (y1 < BOTTOM - 15 or y2 < BOTTOM - 15) then
			lcd.setColor(TEXT_COLOR, adj % 10 == 0 and WHITE or (adj % 5 == 0 and LIGHTGREY or GREY))
			lcd.drawLine(x1, y1, x2, y2, SOLID, 0)
			if adj % 10 == 0 and adj ~= 0 and y2 > 20 and y2 < BOTTOM - 15 then
				lcd.drawText(x2 - 1, y2 - 8, adj, SMLSIZE + RIGHT)
			end
		end
	end

	local function tics(v, p)
		tmp = math.floor((v + 20) / 10) * 10
		for i = tmp - 40, tmp, 5 do
			local tmp2 = Y_CNTR + ((v - i) * 3) - 9
			if tmp2 > 10 and tmp2 < BOTTOM then
				lcd.drawLine(p, tmp2 + 8, p + 2, tmp2 + 8, SOLID, 0)
				if i % 10 == 0 and (i >= 0 or p > X_CNTR) and tmp2 < BOTTOM - 23 then
					lcd.drawText(p + (p > X_CNTR and -1 or 4), tmp2, i, SMLSIZE + (p > X_CNTR and RIGHT or 0))
				end
			end
		end
	end

	-- Attitude
	lcd.setColor(TEXT_COLOR, SKY2)
	lcd.drawFilledRectangle(LEFT_POS, 20, LEFT_POS + 39, BOTTOM - 19)
	lcd.drawFilledRectangle(RIGHT_POS - 43, 20, 42, BOTTOM - 19)
	lcd.setColor(TEXT_COLOR, SKY)
	lcd.drawFilledRectangle(LEFT_POS + 39, 20, RIGHT_POS - 82, BOTTOM - 19)
	lcd.setColor(TEXT_COLOR, WHITE)
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
			lcd.setColor(TEXT_COLOR, WHITE)
			lcd.drawText(X_CNTR - outside, Y_CNTR - 9, tmp2 .. "\64", SMLSIZE + RIGHT)
		end
		tmp2 = math.max(math.min((tmp >= 0 and math.floor(tmp / 5) or math.ceil(tmp / 5)) * 5, 30), -30)
		for x = tmp2 - 20, tmp2 + 20, 2.5 do
			if x ~= 0 then
				attitude(x % 10 == 0 and 20 or (x % 5 == 0 and 15 or 7), x)
			end
		end
	end

	-- Airplane symbol
	lcd.setColor(TEXT_COLOR, YELLOW)
	lcd.drawRectangle(X_CNTR - 2, Y_CNTR - 2, 5, 5, 0)
	lcd.drawRectangle(X_CNTR - outside - 1, Y_CNTR - 1, outside - inside + 3, 3, 0)
	lcd.drawRectangle(X_CNTR - inside - 1, Y_CNTR - 1, 3, 6, 0)
	lcd.drawRectangle(X_CNTR + inside - 2, Y_CNTR - 1, outside - inside + 3, 3, 0)
	lcd.drawRectangle(X_CNTR + inside - 2, Y_CNTR - 1, 3, 6, 0)
	lcd.setColor(TEXT_COLOR, BLACK)
	lcd.drawLine(X_CNTR - outside, Y_CNTR, X_CNTR - inside, Y_CNTR, SOLID, 0)
	lcd.drawLine(X_CNTR - inside, Y_CNTR + 1, X_CNTR - inside, Y_CNTR + 3, SOLID, 0)
	lcd.drawLine(X_CNTR + outside - 1, Y_CNTR, X_CNTR + inside - 1, Y_CNTR, SOLID, 0)
	lcd.drawLine(X_CNTR + inside - 1, Y_CNTR + 1, X_CNTR + inside - 1, Y_CNTR + 3, SOLID, 0)
	lcd.drawFilledRectangle(X_CNTR - 1, Y_CNTR - 1, 3, 3)

	-- Home direction
	if data.showHead and data.armed and data.telem and data.gpsHome ~= false and data.startup == 0 then
		local home = X_CNTR - 3
		if data.distanceLast >= data.distRef then
			local bearing = calcTrig(data.gpsHome, data.gpsLatLon, true) + 540 % 360
			home = math.floor(LEFT_POS + ((bearing - data.heading + (361 + HEADING_DEG / 2)) % 360) * PIXEL_DEG - 2.5)
		end
		if home >= LEFT_POS and home <= RIGHT_POS - 7 then
			lcd.setColor(TEXT_COLOR, data.distanceLast >= data.distRef and BLACK or LIGHTGREY)
			lcd.drawFilledRectangle(home + 2, BOTTOM - 19, 3, 2)
			lcd.setColor(TEXT_COLOR, data.distanceLast >= data.distRef and WHITE or BLACK)
			homeIcon(home, BOTTOM - 22)
		end
	end

	-- Heading
	if data.showHead then
		lcd.setColor(TEXT_COLOR, WHITE)
		for i = 0, 348.75, 11.25 do
			tmp = math.floor(LEFT_POS + ((i - data.heading + (361 + HEADING_DEG / 2)) % 360) * PIXEL_DEG - 2.5)
			if tmp >= LEFT_POS and tmp <= RIGHT_POS then
				if i % 90 == 0 then
					lcd.drawText(tmp - (i < 270 and 3 or 5), BOTTOM - 15, i == 0 and "N" or (i == 90 and "E" or (i == 180 and "S" or "W")), SMLSIZE)
				elseif i % 45 == 0 then
					lcd.drawText(tmp - (i < 225 and 7 or 9), BOTTOM - 15, i == 45 and "NE" or (i == 135 and "SE" or (i == 225 and "SW" or "NW")), SMLSIZE)
				else
					lcd.drawLine(tmp, BOTTOM - 4, tmp, BOTTOM, SOLID, 0)
				end
			end
		end
		lcd.setColor(TEXT_COLOR, DARKGREY)
		lcd.drawFilledRectangle(X_CNTR - 18, BOTTOM - 15, 37, 15)
		lcd.setColor(TEXT_COLOR, WHITE)
		lcd.drawText(X_CNTR - 15, BOTTOM - 15, "     ", SMLSIZE + data.telemFlags)
		lcd.drawText(X_CNTR + 18, BOTTOM - 15, math.floor(data.heading + 0.5) % 360 .. "\64", SMLSIZE + RIGHT + data.telemFlags)
		lcd.setColor(TEXT_COLOR, LIGHTGREY)
		lcd.drawRectangle(X_CNTR - 18, BOTTOM - 15, 37, 16)
	end

	-- Speed & Altitude
	lcd.setColor(TEXT_COLOR, LIGHTGREY)
	tics(data.speed, LEFT_POS + 1)
	tics(data.altitude, RIGHT_POS - 4)
	lcd.setColor(TEXT_COLOR, DARKGREY)
	lcd.drawFilledRectangle(LEFT_POS + 1, Y_CNTR - 8, 38, 16)
	lcd.drawFilledRectangle(RIGHT_POS - 43, Y_CNTR - 8, 43, 16)
	lcd.setColor(TEXT_COLOR, WHITE)
	tmp = data.showMax and data.speedMax or data.speed
	lcd.drawText(LEFT_POS + 3, Y_CNTR - 9, "    ", SMLSIZE + data.telemFlags)
	lcd.drawText(LEFT_POS + 39, Y_CNTR - 9, data.startup == 0 and (tmp >= 99.5 and math.floor(tmp + 0.5) or string.format("%.1f", tmp)) or "Spd", SMLSIZE + RIGHT + data.telemFlags)
	tmp = data.showMax and data.altitudeMax or data.altitude
	lcd.drawText(RIGHT_POS - 41, Y_CNTR - 9, "        ", SMLSIZE + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
	lcd.drawText(RIGHT_POS - 1, Y_CNTR - 9, data.startup == 0 and (math.floor(tmp + 0.5)) or "Alt", SMLSIZE + RIGHT + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
	if data.altHold then
		lockIcon(RIGHT_POS - 52, Y_CNTR - 3)
	end
	lcd.setColor(TEXT_COLOR, LIGHTGREY)
	lcd.drawLine(LEFT_POS, 8, LEFT_POS, BOTTOM, SOLID, 0)
	lcd.drawRectangle(LEFT_POS, Y_CNTR - 9, 40, 18)
	lcd.drawRectangle(RIGHT_POS - 44, Y_CNTR - 9, 44, 18)

	-- Variometer
	if config[7].v % 2 == 1 then
		lcd.setColor(TEXT_COLOR, DARKGREY)
		lcd.drawFilledRectangle(RIGHT_POS, 20, 10, BOTTOM - 20)
		if data.armed then
			tmp = math.log(1 + math.min(math.abs(0.6 * (data.vspeed_unit == 6 and data.vspeed / 3.28084 or data.vspeed)), 10)) / 2.4 * (data.vspeed < 0 and -1 or 1)
			lcd.setColor(TEXT_COLOR, YELLOW)
			lcd.drawLine(RIGHT_POS, Y_CNTR - (tmp * (Y_CNTR - 21)) - 1, RIGHT_POS + 100, Y_CNTR - 1, SOLID, 0)
			lcd.drawLine(RIGHT_POS, Y_CNTR - (tmp * (Y_CNTR - 21)), RIGHT_POS + 100, Y_CNTR, SOLID, 0)
		end
		lcd.setColor(TEXT_COLOR, LIGHTGREY)
		lcd.drawLine(RIGHT_POS - 1, 20, RIGHT_POS - 1, BOTTOM, SOLID, 0)
		lcd.drawLine(RIGHT_POS + 10, 20, RIGHT_POS + 10, BOTTOM, SOLID, 0)
	else
		lcd.setColor(TEXT_COLOR, LIGHTGREY)
		lcd.drawLine(RIGHT_POS - 1, 20, RIGHT_POS - 1, BOTTOM, SOLID, 0)
	end

	-- Radar
	lcd.setColor(TEXT_COLOR, MAP)
	lcd.drawFilledRectangle(RIGHT_POS + 11, 20, LCD_W - RIGHT_POS - 11, BOTTOM - 20)
	LEFT_POS = RIGHT_POS + 11
	RIGHT_POS = LCD_W - 1
	X_CNTR = (RIGHT_POS + LEFT_POS) / 2 - 1
	if data.startup == 0 then
		lcd.setColor(TEXT_COLOR, WHITE)
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
			if d >= 9 then
				lcd.setColor(TEXT_COLOR, BLACK)
				lcd.drawFilledRectangle(hx - 1, hy, 3, 2)
				lcd.setColor(TEXT_COLOR, WHITE)
				homeIcon(hx - 3, hy - 3)
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
		tmp = d == 1 and 12 or 8
		local x1, y1, x2, y2, x3, y3 = calcDir(r1, r2, r3, cx, cy, tmp)
		lcd.setColor(TEXT_COLOR, BLACK)
		lcd.drawLine(x2, y2, x3, y3, SOLID, 0)
		lcd.setColor(TEXT_COLOR, WHITE)
		lcd.drawLine(x1, y1, x2, y2, SOLID, 0)
		lcd.drawLine(x1, y1, x3, y3, SOLID, 0)
		tmp = data.showMax and data.distanceMax or data.distanceLast
		lcd.drawText(LEFT_POS + 2, BOTTOM - 18, data.startup > 0 and "Dist" or (tmp < 1000 and math.floor(tmp + 0.5) .. units[data.dist_unit] or (string.format("%.1f", tmp / (data.dist_unit == 9 and 1000 or 5280)) .. (data.dist_unit == 9 and "km" or "mi"))), SMLSIZE + data.telemFlags)
	end

	-- Startup message
	if data.startup == 2 then
		lcd.setColor(TEXT_COLOR, WHITE)
		lcd.drawText(X_CNTR - 79, 54, "Lua Telemetry", MIDSIZE)
		lcd.drawText(X_CNTR - 39, 84, "v" .. VERSION, MIDSIZE)
	end

	-- Data
	LEFT_POS = 0
	local X1 = 119 -- LCD_W / 4 - 1
	local X2 = 239 -- LCD_W / 2 - 1
	local X3 = 359 -- LCD_W - (LCD_W / 4) - 1
	RIGHT_POS = 479 -- LCD_W - 1
	local TOP = BOTTOM + 1
	BOTTOM = 271 -- LCD_H - 1

	lcd.setColor(TEXT_COLOR, DATA)
	lcd.drawFilledRectangle(0, TOP, LCD_W, BOTTOM - TOP + 1)
	lcd.setColor(TEXT_COLOR, LIGHTGREY)
	lcd.drawLine(LEFT_POS, TOP - 1, LCD_W - 1, TOP - 1, SOLID, 0)
	lcd.drawLine(X1, TOP, X1, BOTTOM, SOLID, 0)
	lcd.drawLine(X2, TOP, X2, BOTTOM, SOLID, 0)
	lcd.drawLine(X3, TOP, X3, BOTTOM, SOLID, 0)

	-- Box 1
	tmp = (not data.telem or data.cell < config[3].v or (data.showFuel and config[23].v == 0 and data.fuel <= config[17].v)) and FLASH or 0
	if data.showFuel then
		lcd.setColor(TEXT_COLOR, WHITE)
		if config[23].v == 0 then
			lcd.drawText(X1, TOP + 1, data.fuel .. "%", MIDSIZE + RIGHT + tmp)
			lcd.drawText(LEFT_POS, TOP + 10, "Fuel", SMLSIZE)
			local red = data.fuel >= config[18].v and math.max(math.floor((100 - data.fuel) / (100 - config[18].v) * 255), 0) or 255
			local green = data.fuel < config[18].v and math.max(math.floor((data.fuel - config[17].v) / (config[18].v - config[17].v) * 255), 0) or 255
			lcd.setColor(TEXT_COLOR, lcd.RGB(red, green, 60))
			lcd.drawGauge(LEFT_POS, TOP + 27, X1 - 1, 14, math.min(data.fuel, 99), 100)
		else
			lcd.drawText(X1, TOP + 1, data.fuel .. config[23].l[config[23].v], MIDSIZE + RIGHT + tmp)
		end
	end

	lcd.setColor(TEXT_COLOR, WHITE)
	local val = data.showMax and data.cellMin or data.cell
	lcd.drawText(X1, TOP + 43, string.format(config[1].v == 0 and "%.2f" or "%.1f", config[1].v == 0 and val or (data.showMax and data.battMin or data.batt)) .. "v", MIDSIZE + RIGHT + tmp)
	lcd.drawText(LEFT_POS, TOP + 52, "Battery", SMLSIZE)
	local red = val >= config[2].v and math.max(math.floor((4.2 - val) / (4.2 - config[2].v) * 255), 0) or 255
	local green = val < config[2].v and math.max(math.floor((val - config[3].v) / (config[2].v - config[3].v) * 255), 0) or 255
	lcd.setColor(TEXT_COLOR, lcd.RGB(red, green, 60))
	lcd.drawGauge(LEFT_POS, TOP + 69, X1 - 1, 14, math.min(math.max(val - config[3].v + 0.1, 0) * (100 / (4.2 - config[3].v + 0.1)), 99), 100)

	tmp = (not data.telem or data.rssi < data.rssiLow) and FLASH or 0
	val = data.showMax and data.rssiMin or data.rssiLast
	lcd.setColor(TEXT_COLOR, WHITE)
	lcd.drawText(X1, TOP + 85, val .. "dB", MIDSIZE + RIGHT + tmp)
	lcd.drawText(LEFT_POS, TOP + 94, "RSSI", SMLSIZE)
	local red = val >= data.rssiLow and math.max(math.floor((100 - val) / (100 - data.rssiLow) * 255), 0) or 255
	local green = val < data.rssiLow and math.max(math.floor((val - data.rssiCrit) / (data.rssiLow - data.rssiCrit) * 255), 0) or 255
	lcd.setColor(TEXT_COLOR, lcd.RGB(red, green, 60))
	lcd.drawGauge(LEFT_POS, TOP + 111, X1 - 1, 14, math.min(val, 99), 100)

	-- Flight modes
	lcd.setColor(TEXT_COLOR, WHITE)
	lcd.drawText(X2 + 3, TOP, modes[data.modeId].t, modes[data.modeId].f)
	if data.headFree then
		lcd.drawText(X2 + 3, TOP + 20, "HF", FLASH)
	end


end

return view