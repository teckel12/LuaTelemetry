local function view(data, config, modes, units, labels, gpsDegMin, hdopGraph, icons, calcTrig, calcDir, VERSION, SMLCD, FLASH, FILE_PATH)

	local SKY = 982 --lcd.RGB(0, 121, 180)
	local GROUND = 25121 --lcd.RGB(98, 68, 8)
	--local SKY2 = 8943 --lcd.RGB(32, 92, 122)
	--local GROUND2 = 20996 --lcd.RGB(81, 65, 36)
	--local MAP = 800 --lcd.RGB(0, 100, 0)
	--local DKMAP = 544 --lcd.RGB(0, 70, 0)
	local LIGHTMAP = 1184 --lcd.RGB(0, 150, 0)
	--local DATA = 264 --lcd.RGB(0, 32, 65)
	local DKGREY = 12678 --lcd.RGB(48, 48, 48)
	local RIGHT_POS = 270
	local X_CNTR = 134 --(RIGHT_POS + LEFT_POS [0]) / 2 - 1
	local HEADING_DEG = 190
	local PIXEL_DEG = RIGHT_POS / HEADING_DEG --(RIGHT_POS - LEFT_POS [0]) / HEADING_DEG
	local TOP = 20
	local BOTTOM = 146
	local Y_CNTR = 83 --(TOP + BOTTOM) / 2
	local tmp, top2, bot2, pitch, roll, roll1, upsideDown

	function intersect(s1, e1, s2, e2)
		local d = (s1.x - e1.x) * (s2.y - e2.y) - (s1.y - e1.y) * (s2.x - e2.x)
		local a = s1.x * e1.y - s1.y * e1.x
		local b = s2.x * e2.y - s2.y * e2.x
		local x = (a * (s2.x - e2.x) - (s1.x - e1.x) * b) / d
		local y = (a * (s2.y - e2.y) - (s1.y - e1.y) * b) / d
		if x < math.min(s2.x, e2.x) - 1 or x > math.max(s2.x, e2.x) + 1 or y < math.min(s2.y, e2.y) - 1 or y > math.max(s2.y, e2.y) + 1 then
			return nil, nil
		end
		return math.floor(x + 0.5), math.floor(y + 0.5)
	end

	local function pitchLadder(r, adj)
		--[[ Caged mode
		local x = math.sin(roll1) * r
		local y = math.cos(roll1) * r
		local p = math.cos(math.rad(pitch - adj)) * 170
		local x1, y1, x2, y2 = X_CNTR - x, Y_CNTR + y - p, X_CNTR + x, Y_CNTR - y - p
		]]
		-- Uncaged mode
		local p = math.sin(math.rad(adj)) * 170
		local y = (Y_CNTR - math.cos(math.rad(pitch)) * 170) - math.sin(roll1) * p
		if y > top2 and y < bot2 then
			local x = X_CNTR - math.cos(roll1) * p
			local xd = math.sin(roll1) * r
			local yd = math.cos(roll1) * r
			local x1, y1, x2, y2 = x - xd, y + yd, x + xd, y - yd
			if (y1 > top2 or y2 > top2) and (y1 < bot2 or y2 < bot2) and y1 >= 0 and y2 >= 0 then
				lcd.setColor(CUSTOM_COLOR, r == 20 and WHITE or LIGHTGREY)
				lcd.drawLine(x1, y1, x2, y2, SOLID, CUSTOM_COLOR)
				if r == 20 and y1 > top2 and y1 < bot2 then
					lcd.drawText(x1 - 1, y1 - 8, upsideDown and -adj or adj, SMLSIZE + RIGHT)
				end
			end
		end
	end

	local function tics(v, p)
		tmp = math.floor((v + 25) / 10) * 10
		for i = tmp - 40, tmp, 5 do
			local tmp2 = Y_CNTR + ((v - i) * 3) - 9
			if tmp2 > 10 and tmp2 < BOTTOM - 8 then
				lcd.drawLine(p, tmp2 + 8, p + 2, tmp2 + 8, SOLID, TEXT_COLOR)
				if config[28].v == 0 and i % 10 == 0 and (i >= 0 or p > X_CNTR) and tmp2 < BOTTOM - 23 then
					lcd.drawText(p + (p > X_CNTR and -1 or 4), tmp2, i, SMLSIZE + (p > X_CNTR and RIGHT or 0) + TEXT_COLOR)
				end
			end
		end
	end

	-- Setup
	lcd.drawBitmap(icons.bg, 0, TOP)
	lcd.setColor(TEXT_COLOR, WHITE)
	lcd.setColor(WARNING_COLOR, data.telem and YELLOW or RED)

	-- Calculate orientation
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
	top2 = config[33].v == 0 and TOP or TOP + 20
	bot2 = BOTTOM - 15
	local i = { {}, {} }
	local tl = { x = 1, y = TOP }
	local tr = { x = RIGHT_POS - 2, y = TOP }
	local bl = { x = 1, y = BOTTOM - 1 }
	local br = { x = RIGHT_POS - 2, y = BOTTOM - 1 }
	local skip = false

	-- Calculate horizon (uses simple "caged" mode for less math)
	local x = math.sin(roll1) * 200
	local y = math.cos(roll1) * 200
	local p = math.cos(math.rad(pitch)) * 170
	local h1 = { x = X_CNTR + x, y = Y_CNTR - y - p }
	local h2 = { x = X_CNTR - x, y = Y_CNTR + y - p }

	-- Find intersections between horizon and edges of attitude indicator
	local x1, y1 = intersect(h1, h2, tl, bl)
	local x2, y2 = intersect(h1, h2, tr, br)
	if x1 and x2 then
		i[1].x, i[1].y = x1, y1
		i[2].x, i[2].y = x2, y2
	else
		local x3, y3 = intersect(h1, h2, bl, br)
		local x4, y4 = intersect(h1, h2, tl, tr)
		if x3 and x4 then
			i[1].x, i[1].y = x3, y3
			i[2].x, i[2].y = x4, y4
		elseif (x1 or x2) and (x3 or x4) then
			i[1].x, i[1].y = x1 and x1 or x2, y1 and y1 or y2
			i[2].x, i[2].y = x3 and x3 or x4, y3 and y3 or y4
		else
			skip = true
		end
	end

	-- Draw ground
	lcd.setColor(CUSTOM_COLOR, GROUND)
	if skip then
		-- Must be going down hard!
		if (pitch - 90) * (upsideDown and -1 or 1) < 0 then
			lcd.drawFilledRectangle(tl.x, tl.y, br.x - tl.x + 1, br.y - tl.y + 1, CUSTOM_COLOR)
		end
	else
		local trix, triy

		-- Find right angle coordinates of triangle
		if upsideDown then
			trix = roll > 90 and math.max(i[1].x, i[2].x) or math.min(i[1].x, i[2].x)
			triy = math.min(i[1].y, i[2].y)
		else
			trix = roll > 90 and math.min(i[1].x, i[2].x) or math.max(i[1].x, i[2].x)
			triy = math.max(i[1].y, i[2].y)
		end
		
		-- Find rectangle(s) and fill
		if upsideDown then
			if triy > tl.y then
				lcd.drawFilledRectangle(tl.x, tl.y, br.x - tl.x + 1, triy - tl.y, CUSTOM_COLOR)
			end
			if roll > 90 and trix < br.x then
				lcd.drawFilledRectangle(trix, triy, br.x - trix + 1, br.y - triy + 1, CUSTOM_COLOR)
			elseif roll <= 90 and trix > tl.x then
				lcd.drawFilledRectangle(tl.x, triy, trix - tl.x, br.y - triy + 1, CUSTOM_COLOR)
			end
		else
			if triy < br.y then
				lcd.drawFilledRectangle(tl.x, triy + 1, br.x - tl.x + 1, br.y - triy, CUSTOM_COLOR)
			end
			if roll > 90 and trix > tl.x then
				lcd.drawFilledRectangle(tl.x, tl.y, trix - tl.x, triy - tl.y + 1, CUSTOM_COLOR)
			elseif roll <= 90 and trix < br.x then
				lcd.drawFilledRectangle(trix, tl.y, br.x - trix + 1, triy - tl.y + 1, CUSTOM_COLOR)
			end
		end

		-- Fill remaining triangle
		local height = i[1].y - triy
		local top = i[1].y
		if height == 0 then
			height = i[2].y - triy
			top = i[2].y
		end
		local inc = 1
		if height ~= 0 then
			local width = math.abs(i[1].x - trix)
			local tx1 = i[1].x
			local tx2 = trix
			if width == 0 then
				width = math.abs(i[2].x - trix)
				tx1 = i[2].x
				tx2 = trix
			end
			inc = math.abs(height) < 10 and 1 or (math.abs(height) < 20 and 2 or ((math.abs(height) < width and math.abs(roll - 90) < 55) and 3 or 5))
			local steps = height > 0 and inc or -inc
			local slope = width / height * inc
			local s = slope > 0 and 0 or inc - 1
			slope = math.abs(slope) * (tx1 < tx2 and 1 or -1)
			for y = triy, top, steps do
				if math.abs(steps) == 1 then
					lcd.drawLine(tx1, y, tx2, y, SOLID, CUSTOM_COLOR)
				else
					if tx1 < tx2 then
					--if tx1 < tx2 and tx2 - tx1 + 1 > 0 then
						lcd.drawFilledRectangle(tx1, y - s, tx2 - tx1 + 1, inc, CUSTOM_COLOR)
					else
					--elseif tx1 > tx2 and tx1 - tx2 + 1 > 0 then
						lcd.drawFilledRectangle(tx2, y - s, tx1 - tx2 + 1, inc, CUSTOM_COLOR)
					end
				end
				tx1 = tx1 + slope
			end
		end

		-- Smooth horizon
		if not upsideDown and inc <= 3 then
			if inc > 1 then
				if inc > 2 then
					lcd.drawLine(i[1].x, i[1].y + 2, i[2].x, i[2].y + 2, SOLID, CUSTOM_COLOR)
				end
				lcd.drawLine(i[1].x, i[1].y + 1, i[2].x, i[2].y + 1, SOLID, CUSTOM_COLOR)
				lcd.setColor(CUSTOM_COLOR, SKY)
				lcd.drawLine(i[1].x, i[1].y - 1, i[2].x, i[2].y - 1, SOLID, CUSTOM_COLOR)
				if inc > 2 then
					lcd.drawLine(i[1].x, i[1].y - 2, i[2].x, i[2].y - 2, SOLID, CUSTOM_COLOR)
				end
				if 90 - roll > 25 then
					lcd.drawLine(i[1].x, i[1].y - 3, i[2].x, i[2].y - 3, SOLID, CUSTOM_COLOR)
				end
			end
			lcd.setColor(CUSTOM_COLOR, LIGHTGREY)
			lcd.drawLine(i[1].x, i[1].y, i[2].x, i[2].y, SOLID, CUSTOM_COLOR)
		end
	end

	-- Pitch ladder
	if data.telem then
		tmp = pitch - 90
		local tmp2 = math.max(math.min((tmp >= 0 and math.floor(tmp / 5) or math.ceil(tmp / 5)) * 5, 30), -30)
		for x = tmp2 - 20, tmp2 + 20, 5 do
			if x ~= 0 and (x % 10 == 0 or (x > -30 and x < 30)) then
				pitchLadder(x % 10 == 0 and 20 or 15, x)
			end
		end
		if not data.showMax then
			--[[ Adds a shadow to the pitch
			lcd.setColor(CUSTOM_COLOR, BLACK)
			lcd.drawText(X_CNTR - 64, Y_CNTR - 8, string.format("%.0f", upsideDown and -tmp or tmp) .. "\64", SMLSIZE + RIGHT + CUSTOM_COLOR)
			]]
			lcd.drawText(X_CNTR - 65, Y_CNTR - 9, string.format("%.0f", upsideDown and -tmp or tmp) .. "\64", SMLSIZE + RIGHT)
		end
	end

	-- Home direction
	if data.showHead and data.armed and data.telem and data.gpsHome ~= false and data.startup == 0 then
		if data.distanceLast >= data.distRef then
			local bearing = calcTrig(data.gpsHome, data.gpsLatLon, true) + 540 % 360
			local home = math.floor(((bearing - data.heading + (361 + HEADING_DEG / 2)) % 360) * PIXEL_DEG - 2.5)
			if home >= 3 and home <= RIGHT_POS - 6 then
				lcd.drawBitmap(icons.home, home - 3, BOTTOM - 26)
			end
		end
	end

	-- Compass
	if data.showHead then
		for i = 0, 348.75, 11.25 do
			tmp = math.floor(((i - data.heading + (361 + HEADING_DEG / 2)) % 360) * PIXEL_DEG - 2.5)
			if tmp >= 9 and tmp <= RIGHT_POS - 12 then
				if i % 90 == 0 then
					lcd.drawText(tmp - (i < 270 and 3 or 5), bot2, i == 0 and "N" or (i == 90 and "E" or (i == 180 and "S" or "W")), SMLSIZE)
				elseif i % 45 == 0 then
					lcd.drawText(tmp - (i < 225 and 7 or 9), bot2, i == 45 and "NE" or (i == 135 and "SE" or (i == 225 and "SW" or "NW")), SMLSIZE)
				else
					lcd.drawLine(tmp, BOTTOM - 4, tmp, BOTTOM - 1, SOLID, 0)
				end
			end
		end
	end

	-- Speed & altitude tics
	tics(data.speed, 1)
	tics(data.altitude, RIGHT_POS - 4)
	if config[28].v == 0 and config[33].v == 0 then
		lcd.drawText(42, TOP - 1, units[data.speed_unit], SMLSIZE)
		lcd.drawText(RIGHT_POS - 45, TOP - 1, "Alt " .. units[data.alt_unit], SMLSIZE + RIGHT)
	end

	-- View overlay
	lcd.drawBitmap(icons.fg, 1, 20)

	-- Speed & altitude
	tmp = data.showMax and data.speedMax or data.speed
	lcd.drawText(39, Y_CNTR - 9, tmp >= 99.5 and math.floor(tmp + 0.5) or string.format("%.1f", tmp), SMLSIZE + RIGHT + data.telemFlags)
	tmp = data.showMax and data.altitudeMax or data.altitude
	lcd.drawText(RIGHT_POS - 2, Y_CNTR - 9, math.floor(tmp + 0.5), SMLSIZE + RIGHT + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
	if data.altHold then
		lcd.drawBitmap(icons.lock, RIGHT_POS - 55, Y_CNTR - 5)
	end
	if data.showMax then
		lcd.drawText(41, Y_CNTR - 11, "\192", 0)
		lcd.drawText(RIGHT_POS - 43, Y_CNTR - 11, "\192", RIGHT)
	end

	-- Heading
	if data.showHead then
		lcd.drawText(X_CNTR + 18, bot2, math.floor(data.heading + 0.5) % 360 .. "\64", SMLSIZE + RIGHT + data.telemFlags)
	end

	-- Roll indicator
	if config[33].v == 1 then
		lcd.drawBitmap(icons.roll, 43, 20)
		if roll > 30 and roll < 150 and not upsideDown then
			local x1, y1, x2, y2, x3, y3 = calcDir(math.rad(roll - 90), math.rad(roll + 55), math.rad(roll - 235), X_CNTR - (math.cos(roll1) * 75), 79 - (math.sin(roll1) * 40), 7)
			lcd.setColor(CUSTOM_COLOR, YELLOW)
			lcd.drawLine(x1, y1, x2, y2, SOLID, CUSTOM_COLOR)
			lcd.drawLine(x1, y1, x3, y3, SOLID, CUSTOM_COLOR)
			lcd.drawLine(x2, y2, x3, y3, SOLID, CUSTOM_COLOR)
		end
	end

	-- Variometer
	if config[7].v % 2 == 1 then
		lcd.setColor(CUSTOM_COLOR, DKGREY)
		lcd.drawFilledRectangle(RIGHT_POS, TOP, 10, BOTTOM - 20, CUSTOM_COLOR)
		lcd.setColor(CUSTOM_COLOR, LIGHTGREY)
		lcd.drawLine(RIGHT_POS + 10, TOP, RIGHT_POS + 10, BOTTOM - 1, SOLID, CUSTOM_COLOR)
		lcd.setColor(CUSTOM_COLOR, GREY)
		lcd.drawLine(RIGHT_POS, Y_CNTR - 1, RIGHT_POS + 9, Y_CNTR - 1, SOLID, CUSTOM_COLOR)
		if data.telem then
			lcd.setColor(CUSTOM_COLOR, YELLOW)
			tmp = math.log(1 + math.min(math.abs(0.6 * (data.vspeed_unit == 6 and data.vspeed / 3.28084 or data.vspeed)), 10)) * (data.vspeed < 0 and -1 or 1)
			local y1 = Y_CNTR - (tmp / 2.4 * (Y_CNTR - 21))
			local y2 = Y_CNTR - (tmp / 2.6 * (Y_CNTR - 21))
			lcd.drawLine(RIGHT_POS, y1 - 1, RIGHT_POS + 9, y2 - 1, SOLID, CUSTOM_COLOR)
			lcd.drawLine(RIGHT_POS, y1, RIGHT_POS + 9, y2, SOLID, CUSTOM_COLOR)
		end
		if data.startup == 0 then
			lcd.drawText(RIGHT_POS + 13, TOP - 1, string.format(math.abs(data.vspeed) >= 9.95 and "%.0f" or "%.1f", data.vspeed) .. units[data.vspeed_unit], SMLSIZE + data.telemFlags)
		end
	end

	-- Calc orientation
	tmp = data.headingRef
	if data.showDir or data.headingRef < 0 then
		tmp = 0
	end
	local r1 = math.rad(data.heading - tmp)
	local r2 = math.rad(data.heading - tmp + 145)
	local r3 = math.rad(data.heading - tmp - 145)

	-- Radar
	local LEFT_POS = RIGHT_POS + (config[7].v % 2 == 1 and 11 or 0)
	RIGHT_POS = 479
	X_CNTR = (RIGHT_POS + LEFT_POS) / 2 - 1
	local tmp2 = data.showMax and data.distanceMax or data.distanceLast
	local dist = tmp2 < 1000 and math.floor(tmp2 + 0.5) .. units[data.dist_unit] or (string.format("%.1f", tmp2 / (data.dist_unit == 9 and 1000 or 5280)) .. (data.dist_unit == 9 and "km" or "mi"))
	if data.startup == 0 then
		-- Launch/north-based orientation
		if data.showDir or data.headingRef < 0 then
			lcd.drawText(LEFT_POS + 2, Y_CNTR - 9, "W", SMLSIZE)
			lcd.drawText(RIGHT_POS, Y_CNTR - 9, "E", SMLSIZE + RIGHT)
		end
		local cx, cy, d

		-- Altitude graph
		if config[28].v > 0 then
			local factor = 30 / (data.altMax - data.altMin)
			lcd.setColor(CUSTOM_COLOR, LIGHTMAP)
			for i = 1, 60 do
				cx = RIGHT_POS - 60 + i
				cy = math.floor(BOTTOM - (data.alt[((data.altCur - 2 + i) % 60) + 1] - data.altMin) * factor + 0.5)
				if cy < BOTTOM then
					lcd.drawLine(cx, cy, cx, BOTTOM - 1, SOLID, CUSTOM_COLOR)
				end
				if (i - 1) % (60 / config[28].v) == 0 then
					lcd.setColor(CUSTOM_COLOR, DKGREY)
					lcd.drawLine(cx, BOTTOM - 30, cx, BOTTOM - 1, DOTTED, CUSTOM_COLOR)
					lcd.setColor(CUSTOM_COLOR, LIGHTMAP)
				end
			end
			if data.altMin < -1 then
				cy = BOTTOM - (-data.altMin * factor)
				lcd.setColor(CUSTOM_COLOR, LIGHTGREY)
				lcd.drawLine(RIGHT_POS - 58, cy, RIGHT_POS - 1, cy, DOTTED, CUSTOM_COLOR)
				if cy < 142 then
					lcd.drawText(RIGHT_POS - 59, cy - 8, "0", SMLSIZE + RIGHT)
				end
			end
			lcd.drawText(RIGHT_POS + 2, BOTTOM - 46, math.floor(data.altMax + 0.5) .. units[data.alt_unit], SMLSIZE + RIGHT)
		end

		if data.gpsHome ~= false then
			-- Craft location
			tmp2 = config[31].v == 1 and 50 or 100
			d = data.distanceLast >= data.distRef and math.min(math.max((data.distanceLast / math.max(math.min(data.distanceMax, data.distanceLast * 4), data.distRef * 10)) * tmp2, 7), tmp2) or 1
			local bearing = calcTrig(data.gpsHome, data.gpsLatLon, true) - tmp
			local rad1 = math.rad(bearing)
			cx = math.floor(math.sin(rad1) * d + 0.5)
			cy = math.floor(math.cos(rad1) * d + 0.5)
			-- Home position
			local hx = X_CNTR + 2
			local hy = Y_CNTR
			if config[31].v ~= 1 then
				hx = hx - (d > 9 and cx / 2 or 0)
				hy = hy + (d > 9 and cy / 2 or 0)
			end
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
		local x1, y1, x2, y2, x3, y3 = calcDir(r1, r2, r3, cx, cy, 8)
		lcd.setColor(CUSTOM_COLOR, LIGHTGREY)
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
		lcd.setColor(CUSTOM_COLOR, BLACK)
		lcd.drawText(X_CNTR - 78, 55, "Lua Telemetry", MIDSIZE + CUSTOM_COLOR)
		lcd.drawText(X_CNTR - 38, 85, "v" .. VERSION, MIDSIZE + CUSTOM_COLOR)
		lcd.drawText(X_CNTR - 79, 54, "Lua Telemetry", MIDSIZE)
		lcd.drawText(X_CNTR - 39, 84, "v" .. VERSION, MIDSIZE)
	end

	-- Data
	local X1 = 140
	local X2 = 234
	local X3 = 346
	TOP = BOTTOM + 1
	BOTTOM = 271

	-- Box 1 (fuel, battery, rssi)
	tmp = (not data.telem or data.cell < config[3].v or (data.showFuel and config[23].v == 0 and data.fuel <= config[17].v)) and FLASH or 0
	if data.showFuel then
		if config[23].v == 0 then
			lcd.drawText(X1 - 3, TOP, data.fuel .. "%", MIDSIZE + RIGHT + tmp)
			local red = data.fuel >= config[18].v and math.max(math.floor((100 - data.fuel) / (100 - config[18].v) * 255), 0) or 255
			local green = data.fuel < config[18].v and math.max(math.floor((data.fuel - config[17].v) / (config[18].v - config[17].v) * 255), 0) or 255
			lcd.setColor(CUSTOM_COLOR, lcd.RGB(red, green, 60))
			lcd.drawGauge(0, TOP + 26, X1 - 3, 15, math.min(data.fuel, 99), 100, CUSTOM_COLOR)
		else
			lcd.drawText(X1, TOP + 1, data.fuel .. data.fUnit[config[23].v], MIDSIZE + RIGHT + tmp)
		end
		lcd.drawText(0, TOP + (config[23].v == 0 and 9 or 23), labels[1], SMLSIZE)
	end

	local val = data.showMax and data.cellMin or data.cell
	lcd.drawText(X1 - 3, TOP + 42, string.format(config[1].v == 0 and "%.2fV" or "%.1fV", config[1].v == 0 and val or (data.showMax and data.battMin or data.batt)), MIDSIZE + RIGHT + tmp)
	lcd.drawText(0, TOP + 51, labels[2], SMLSIZE)
	local red = val >= config[2].v and math.max(math.floor((4.2 - val) / (4.2 - config[2].v) * 255), 0) or 255
	local green = val < config[2].v and math.max(math.floor((val - config[3].v) / (config[2].v - config[3].v) * 255), 0) or 255
	lcd.setColor(CUSTOM_COLOR, lcd.RGB(red, green, 60))
	lcd.drawGauge(0, TOP + 68, X1 - 3, 15, math.min(math.max(val - config[3].v + 0.1, 0) * (100 / (4.2 - config[3].v + 0.1)), 99), 100, CUSTOM_COLOR)

	tmp = (not data.telem or data.rssi < data.rssiLow) and FLASH or 0
	val = data.showMax and data.rssiMin or data.rssiLast
	lcd.drawText(X1 - 3, TOP + 84, val .. (data.crsf and "%" or "dB"), MIDSIZE + RIGHT + tmp)
	lcd.drawText(0, TOP + 93, data.crsf and "LQ" or "RSSI", SMLSIZE)
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
		lcd.drawText(X2, TOP + 98, (tmp >= 99.5 and math.floor(tmp + 0.5) or string.format("%.1fA", tmp)), MIDSIZE + RIGHT + data.telemFlags)
	end

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
			lcd.drawText(X3 - 4, 211, "E", SMLSIZE + RIGHT)
			lcd.drawText(X2 + 10, 211, "W", SMLSIZE)
			lcd.drawText(X2 + 78, BOTTOM - 15, math.floor(data.heading + 0.5) % 360 .. "\64", SMLSIZE + RIGHT + data.telemFlags)
		end
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
	if data.crsf then
		if data.tpwr then
			lcd.drawText(RIGHT_POS, TOP, data.tpwr .. "mW", RIGHT + MIDSIZE + data.telemFlags)
		end
		lcd.drawText(RIGHT_POS + 1, TOP + 28, data.satellites % 100, MIDSIZE + RIGHT + data.telemFlags)
	else
		tmp = ((data.armed or data.modeId == 6) and data.hdop < 11 - config[21].v * 2) or not data.telem
		lcd.drawText(X3 + 48, TOP, (data.hdop == 0 and not data.gpsFix) and "-- --" or (9 - data.hdop) / 2 + 0.8, MIDSIZE + RIGHT + (tmp and FLASH or 0))
		lcd.drawText(X3 + 11, TOP + 24, "HDOP", SMLSIZE)
		lcd.drawText(RIGHT_POS + 1, TOP, data.satellites % 100, MIDSIZE + RIGHT + data.telemFlags)
	end
	hdopGraph(X3 + 65, TOP + (data.crsf and 51 or 23))
	tmp = RIGHT + ((not data.telem or not data.gpsFix) and FLASH or 0)
	if not data.crsf then
		lcd.drawText(RIGHT_POS, TOP + 28, math.floor(data.gpsAlt + 0.5) .. (data.gpsAlt_unit == 10 and "'" or units[data.gpsAlt_unit]), MIDSIZE + tmp)
	end
	lcd.drawText(RIGHT_POS, TOP + 54, config[16].v == 0 and string.format("%.6f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), tmp)
	lcd.drawText(RIGHT_POS, TOP + 74, config[16].v == 0 and string.format("%.6f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), tmp)
	tmp = data.showMax and data.speedMax or data.speed
	lcd.drawText(RIGHT_POS + 1, TOP + 98, tmp >= 99.5 and math.floor(tmp + 0.5) .. units[data.speed_unit] or string.format("%.1f", tmp) .. units[data.speed_unit], MIDSIZE + RIGHT + data.telemFlags)

	if data.showMax then
		lcd.setColor(CUSTOM_COLOR, GREY)
		lcd.drawText(2, TOP + 64, "\193", CUSTOM_COLOR)
		lcd.drawText(2, TOP + 106, "\193", CUSTOM_COLOR)
		lcd.drawText(X1 + 4, TOP + 18, "\192")
		lcd.drawText(X1 + 4, TOP + 61, "\192")
		lcd.drawText(X1 + 4, TOP + 104, "\192")
		lcd.drawText(X3 + 4, TOP + 104, "\192")
	end

	-- Dividers
	lcd.setColor(CUSTOM_COLOR, GREY)
	lcd.drawLine(X1 + 3, TOP, X1 + 3, BOTTOM, DOTTED, CUSTOM_COLOR)
	lcd.drawLine(X2 + 3, TOP, X2 + 3, BOTTOM, DOTTED, CUSTOM_COLOR)
	lcd.drawLine(X3 + 3, TOP, X3 + 3, BOTTOM, DOTTED, CUSTOM_COLOR)
	lcd.drawLine(X3 + 3, TOP + 95, RIGHT_POS, TOP + 95, DOTTED, CUSTOM_COLOR)
	if data.crsf then
		lcd.drawLine(X3 + 3, TOP + 28, RIGHT_POS, TOP + 28, DOTTED, CUSTOM_COLOR)
	end
	lcd.setColor(CUSTOM_COLOR, LIGHTGREY)
	lcd.drawLine(0, TOP - 1, LCD_W - 1, TOP - 1, SOLID, CUSTOM_COLOR)
end

return view