local function view(data, config, modes, units, gpsDegMin, gpsIcon, lockIcon, homeIcon, hdopGraph, calcTrig, calcDir, VERSION, SMLCD, FLASH, FILE_PATH)

	-- 480 x 272
	GREY_DEFAULT = 0
	FORCE = 0
	ERASE = 0

	local LEFT_POS = 0
	local RIGHT_POS = LCD_W / 2
	local X_CNTR = (RIGHT_POS + LEFT_POS) / 2 - 1
	local gpsFlags = SMLSIZE + RIGHT + ((not data.telem or not data.gpsFix) and FLASH or 0)
	local tmp, pitch
	local Y_CNTR = 68

	local function attitude(r, adj)
		local py = Y_CNTR - math.cos(math.rad(pitch - adj)) * 85
		local x1 = math.sin(roll1) * r + X_CNTR
		local y1 = py - (math.cos(roll1) * r)
		local x2 = math.sin(roll2) * r + X_CNTR
		local y2 = py - (math.cos(roll2) * r)
		if adj == 0 then
			local a = (y1 - y2) / (x1 - x2 + .001)
			local y = y2 - ((x2 - LEFT_POS + 1) * a)
			for x = LEFT_POS + 1, RIGHT_POS - 1 do
				local yy = y + 0.5
				if (not upsideDown and yy < 64) or (upsideDown and yy > 7) then
					lcd.drawLine(x, math.min(math.max(yy, 8), 63), x, upsideDown and 8 or 63, SOLID, GREY_DEFAULT)
				end
				y = y + a
			end
		elseif (y1 > 15 or y2 > 15) and (y1 < 56 or y2 < 56) then
			lcd.drawLine(x1, y1, x2, y2, SMLCD and DOTTED or (adj % 10 == 0 and SOLID or DOTTED), adj > 0 and GREY_DEFAULT or 0)
			if adj % 10 == 0 and adj ~= 0 and y2 > 15 and y2 < 56 then
				lcd.drawText(x2 - 2, y2 - 3, math.abs(adj), SMLSIZE + RIGHT)
			end
		end
	end

	local function tics(v, p)
		for i = v % 10 + 8, 56, 10 do
			if i < 31 or i > 41 then
				lcd.drawLine(p, i, p + 1, i, SOLID, 0)
			end
		end
	end

	-- Startup message
	if data.startup == 2 then
		lcd.drawText(X_CNTR - 90, 50, "Lua Telemetry", MIDSIZE)
		lcd.drawText(X_CNTR - 50, 80, "v" .. VERSION, MIDSIZE)
	end

	-- Attitude part 1
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
	if data.startup == 0 and data.telem then
		tmp = pitch - 90
		local short = SMLCD and 4 or 6
		local tmp2 = tmp >= 0 and (tmp < 1 and 0 or math.floor(tmp + 0.5)) or (tmp > -1 and 0 or math.ceil(tmp - 0.5))
		if not data.showMax then
			lcd.drawText(X_CNTR - 24, Y_CNTR, math.abs(tmp2) .. "\64", SMLSIZE + RIGHT)
		end
		if tmp <= 25 and tmp >= -10 then
			attitude(short, 5)
			attitude(11, 10)
		end
		if tmp <= 10 and tmp >= -25 then	
			attitude(short, -5)
			attitude(11, -10)
		end
		if tmp >= 0 then
			attitude(short, 15)
			attitude(11, 20)
		else
			attitude(short, -15)
			attitude(11, -20)
		end
		if tmp >= 10 then
			attitude(short, 25)
			attitude(11, 30)
		elseif tmp <= -10 then
			attitude(short, -25)
			attitude(11, -30)
		end
	end

	-- Attitude part 2
	lcd.drawFilledRectangle(X_CNTR - 1, Y_CNTR + 1, 3, 3, ERASE)
	--attitude(200, 0)
	local inside = 13
	local outside = 24
	lcd.drawLine(X_CNTR - outside, Y_CNTR + 1, X_CNTR - inside, Y_CNTR + 1, SOLID, FORCE)
	lcd.drawLine(X_CNTR + outside, Y_CNTR + 1, X_CNTR + inside, Y_CNTR + 1, SOLID, FORCE)
	lcd.drawLine(X_CNTR - inside, Y_CNTR + 2, X_CNTR - inside, Y_CNTR + 5, SOLID, FORCE)
	lcd.drawLine(X_CNTR + inside, Y_CNTR + 2, X_CNTR + inside, Y_CNTR + 5, SOLID, FORCE)
	lcd.drawLine(X_CNTR - 1, Y_CNTR + 1, X_CNTR + 1, Y_CNTR + 1, SOLID, FORCE)
	if SMLCD then
		lcd.drawPoint(X_CNTR, Y_CNTR + 1, 0)
		lcd.drawPoint(X_CNTR, Y_CNTR + 2, 0)
	else
		lcd.drawLine(X_CNTR, Y_CNTR + 1, X_CNTR, Y_CNTR + 2, SOLID, FORCE)
	end

	local rssiFlags = RIGHT + ((not data.telem or data.rssi < data.rssiLow) and FLASH or 0)
	lcd.drawText(LCD_W, 52, math.min(data.showMax and data.rssiMin or data.rssiLast, 99) .. "dB", MIDSIZE + rssiFlags)

end

return view