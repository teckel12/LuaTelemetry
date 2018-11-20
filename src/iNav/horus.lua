local function view(data, config, modes, units, gpsDegMin, gpsIcon, lockIcon, homeIcon, hdopGraph, calcTrig, calcDir, VERSION, SMLCD, FLASH, FILE_PATH)

	-- 480 x 272
	GREY_DEFAULT = 0
	FORCE = 0
	ERASE = 0

	local SKY = lcd.RGB(0, 121, 180)
	local GROUND = lcd.RGB(98, 68, 8)
	--local SKY = lcd.RGB(0, 101, 204)
	--local GROUND = lcd.RGB(101, 51, 0)
	--local SKY = lcd.RGB(1, 138, 195)
	--local GROUND = lcd.RGB(148, 67, 13)
	local MAP = lcd.RGB(51, 137, 47)
	local DATA = 15 -- lcd.RGB(0, 0, 120)

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
			lcd.setColor(TEXT_COLOR, GROUND)
			tmp = upsideDown and 20 or BOTTOM
			for x = LEFT_POS + 1, RIGHT_POS - 2, 2 do
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
		for i = v % 10 + 20, BOTTOM - 2, 10 do
			if i < Y_CNTR - 9 or i > Y_CNTR + 9 then
				lcd.drawLine(p, i, p + 2, i, SOLID, 0)
			end
			--lcd.drawText(p + 1, i - 8, math.floor(v), SMLSIZE)
		end
	end

	-- Attitude
	lcd.setColor(TEXT_COLOR, SKY)
	lcd.drawFilledRectangle(LEFT_POS, 20, RIGHT_POS, BOTTOM - 19)
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

	-- Level indicator
	lcd.setColor(TEXT_COLOR, WHITE)
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
	if data.showHead and data.armed and data.telem and data.gpsHome ~= false and data.startup == 0 and not data.showDir then
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
	--elseif data.showMax then
	--	lcd.drawText(LEFT_POS + 21, 33, "\192", SMLSIZE)
	--	lcd.drawText(RIGHT_POS - 22, 33, "\192", SMLSIZE + RIGHT)
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
		lcd.setColor(TEXT_COLOR, WHITE)
		lcd.drawRectangle(X_CNTR - 18, BOTTOM - 15, 37, 16)
	end

	-- Speed & Altitude
	lcd.setColor(TEXT_COLOR, DARKGREY)
	lcd.drawFilledRectangle(LEFT_POS + 1, Y_CNTR - 8, 38, 16)
	lcd.drawFilledRectangle(RIGHT_POS - 39, Y_CNTR - 8, 38, 16)
	lcd.setColor(TEXT_COLOR, WHITE)

	tics(data.speed, LEFT_POS + 1)
	lcd.drawText(LEFT_POS + 3, Y_CNTR - 9, "    ", SMLSIZE + data.telemFlags)
	tmp = data.showMax and data.speedMax or data.speed
	lcd.drawText(LEFT_POS + 39, Y_CNTR - 9, tmp >= 99.5 and math.floor(tmp + 0.5) or string.format("%.1f", tmp), SMLSIZE + RIGHT + data.telemFlags)

	tics(data.altitude, RIGHT_POS - 4)
	tmp = data.showMax and data.altitudeMax or data.altitude
	lcd.drawText(RIGHT_POS - 37, Y_CNTR - 9, "       ", SMLSIZE + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
	lcd.drawText(RIGHT_POS - 1, Y_CNTR - 9, math.floor(tmp + 0.5), SMLSIZE + RIGHT + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))

	lcd.drawLine(LEFT_POS, 8, LEFT_POS, BOTTOM, SOLID, 0)
	lcd.drawRectangle(LEFT_POS, Y_CNTR - 9, 40, 18)
	lcd.drawRectangle(RIGHT_POS - 40, Y_CNTR - 9, 40, 18)
	lcd.drawText(LEFT_POS + 5, Y_CNTR + 8, units[data.speed_unit], SMLSIZE)
	lcd.drawText(RIGHT_POS - 5, Y_CNTR + 8, units[data.alt_unit], SMLSIZE + RIGHT)
	if data.startup > 0 then
		lcd.drawText(LEFT_POS + 5, Y_CNTR - 26, "Spd", SMLSIZE)
		lcd.drawText(RIGHT_POS - 5, Y_CNTR - 26, "Alt", SMLSIZE + RIGHT)
	end

	-- Map
	lcd.setColor(TEXT_COLOR, MAP)
	lcd.drawFilledRectangle(RIGHT_POS, 20, LCD_W - RIGHT_POS, BOTTOM - 19)
	lcd.setColor(TEXT_COLOR, WHITE)
	
	-- Variometer
	if config[7].v % 2 == 1 then
		lcd.drawLine(RIGHT_POS - 1, 20, RIGHT_POS - 1, BOTTOM, SOLID, 0)
		lcd.setColor(TEXT_COLOR, DARKGREY)
		lcd.drawFilledRectangle(RIGHT_POS, 20, 5, BOTTOM - 20)
		lcd.setColor(TEXT_COLOR, WHITE)
		lcd.drawLine(RIGHT_POS + 5, 20, RIGHT_POS + 5, BOTTOM, SOLID, 0)
		local varioSpeed = math.log(1 + math.min(math.abs(0.6 * (data.vspeed_unit == 6 and data.vspeed / 3.28084 or data.vspeed)), 10)) / 2.4 * (data.vspeed < 0 and -1 or 1)
		if data.armed then
			tmp = Y_CNTR - math.floor(varioSpeed * 27 + 0.5)
			for i = Y_CNTR, tmp, (tmp > Y_CNTR and 1 or -1) do
				local w = (tmp > Y_CNTR and i + 1 or Y_CNTR - i) % 4
				if w < 3 then
					lcd.drawLine(RIGHT_POS + w, i, RIGHT_POS + 4 - w, i, SOLID, 0)
				end
			end
		end
	else
		lcd.drawLine(RIGHT_POS - 1, 20, RIGHT_POS - 1, BOTTOM, SOLID, 0)
	end

	-- Data background
	lcd.setColor(TEXT_COLOR, DATA)
	lcd.drawFilledRectangle(0, BOTTOM, LCD_W, LCD_H - BOTTOM)
	lcd.setColor(TEXT_COLOR, WHITE)
	lcd.drawLine(LEFT_POS, BOTTOM, LCD_W - 1, BOTTOM, SOLID, 0)
	
	-- Startup message
	if data.startup == 2 then
		lcd.setColor(TEXT_COLOR, BLACK)
		lcd.drawText(X_CNTR - 91, 51, "Lua Telemetry", MIDSIZE)
		lcd.drawText(X_CNTR - 51, 81, "v" .. VERSION, MIDSIZE)
		lcd.setColor(TEXT_COLOR, WHITE)
		lcd.drawText(X_CNTR - 90, 50, "Lua Telemetry", MIDSIZE)
		lcd.drawText(X_CNTR - 50, 80, "v" .. VERSION, MIDSIZE)
	end

end

return view