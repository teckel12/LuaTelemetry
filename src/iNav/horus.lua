local function view(data, config, 
	modes, units, labels, gpsDegMin, hdopGraph, icons, calcTrig, calcDir, VERSION, SMLCD, FLASH, FILE_PATH)

	--local SKY = 982 --lcd.RGB(0, 121, 180)
	local GROUND = 25121 --lcd.RGB(98, 68, 8)
	--local SKY2 = 8943 --lcd.RGB(32, 92, 122)
	local GROUND2 = 20996 --lcd.RGB(81, 65, 36)
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
	local tmp, pitch, roll, roll1, roll2, roll3, upsideDown

	local function horCalc(r, adj)
		local py = Y_CNTR - math.cos(math.rad(pitch - adj)) * 170
		local x1 = math.sin(roll1) * r + X_CNTR
		local y1 = py - (math.cos(roll1) * r)
		local x2 = math.sin(roll2) * r + X_CNTR
		local y2 = py - (math.cos(roll2) * r)
		return x1, y1, x2, y2
	end

	function intersect(s1, e1, s2, e2)
		local d = (s1.x - e1.x) * (s2.y - e2.y) - (s1.y - e1.y) * (s2.x - e2.x)
		local a = s1.x * e1.y - s1.y * e1.x
		local b = s2.x * e2.y - s2.y * e2.x
		local x = math.floor((a * (s2.x - e2.x) - (s1.x - e1.x) * b) / d + 0.5)
		local y = math.floor((a * (s2.y - e2.y) - (s1.y - e1.y) * b) / d + 0.5)
		if x < math.min(s2.x, e2.x) or x > math.max(s2.x, e2.x) or y < math.min(s2.y, e2.y) or y > math.max(s2.y, e2.y) then
			return nil, nil
		end
		return x, y
	end

	local function horizon()
		local h1, h2, i = {}, {}, { {}, {} }
		local tl = { x = 1, y = TOP }
		local tr = { x = RIGHT_POS - 2, y = TOP }
		local bl = { x = 1, y = BOTTOM - 1 }
		local br = { x = RIGHT_POS - 2, y = BOTTOM - 1 }
		local i1x, i1y, i2x, i2y, x1, x2, x3, x4, y1, y2, y3, y4
		local ii = 1
		local l, r, t, b = false, false, false, false

		-- Calculate horizon
		h1.x, h1.y, h2.x, h2.y = horCalc(200, 0)

		-- Find intersections between horizon and edges of attitude indicator
		x1, y1 = intersect(h1, h2, tl, bl)
		if x1 then
			--lcd.drawText(1, 55, x1 .. "x" .. y1)
			--lcd.drawText(270, 60, "left")
			i[ii].x = x1
			i[ii].y = y1
			ii = ii + 1
			l = true
		end
		x2, y2 = intersect(h1, h2, tr, br)
		if x2 then
			--lcd.drawText(268, 90, x2 .. "x" .. y2, RIGHT)
			--lcd.drawText(270, 80, "right")
			i[ii].x = x2
			i[ii].y = y2
			ii = ii + 1
			r = true
		end
		if ii < 3 then
			x3, y3 = intersect(h1, h2, bl, br)
			if x3 and (ii ~= 2 or (x3 < 267 and x3 > 1)) then
				--lcd.drawText(40, 115, x3 .. "x" .. y3)
				--lcd.drawText(270, 100, "bottom")
				i[ii].x = x3
				i[ii].y = y3
				ii = ii + 1
				b = true
			end
			if ii < 3 then
				x4, y4 = intersect(h1, h2, tl, tr)
				if x4 then
					--lcd.drawText(225, 20, x4 .. "x" .. y4, RIGHT)
					--lcd.drawText(270, 120, "top")
					i[ii].x = x4
					i[ii].y = y4
					ii = ii + 1
					t = true
				end
			end
		end

		-- Draw horizon
		lcd.setColor(CUSTOM_COLOR, GROUND)
		if ii < 3 then
			-- Must be going down hard!
			if (pitch - 90) * (upsideDown and -1 or 1) < 0 then
				lcd.drawFilledRectangle(tl.x, tl.y, br.x - tl.x + 1, br.y - tl.y + 1, CUSTOM_COLOR)
			end
		else
			-- Find rectangles to fill
			local r1x, r1y, r2x, r2y = tl.x, tl.y, br.x, br.y
			local trix, triy, rec = r2x, r2y, true
			if upsideDown then
				if l and r then
					r2y = math.min(i[1].y, i[2].y)
					trix, triy = roll > 90 and r2x or r1x, r2y
				elseif t and b and roll < 90 then
					r2x = math.min(i[1].x, i[2].x)
					trix, triy = i[1].x, r1y
				elseif t and b and roll > 90 then
					r1x = math.max(i[1].x, i[2].x)
					trix, triy = r1x, r1y
				elseif (l and b) or (r and b) then
					r2y = math.min(i[1].y, i[2].y)
					trix, triy = i[2].x, r2y
					if l and b then
						lcd.drawFilledRectangle(trix, triy + 1, br.x - trix, br.y - triy, CUSTOM_COLOR)
					else
						lcd.drawFilledRectangle(bl.x, r2y + 1, trix - bl.x + 1, bl.y - r2y, CUSTOM_COLOR)
					end
				elseif l and t then
					rec = false
					trix, triy = r1x, r1y
				elseif r and t then
					triy = r1y
					rec = false
				end
			else
				if l and r then
					r1y = math.max(i[1].y, i[2].y)
					trix, triy = roll > 90 and r1x or r2x, r1y
				elseif t and b and roll < 90 then
					r1x = math.max(i[1].x, i[2].x)
					trix, triy = r1x, r2y
				elseif t and b and roll > 90 then
					r2x = math.min(i[1].x, i[2].x)
					trix, triy = r2x, r2y
				elseif (l and t) or (r and t) then
					r1y = math.max(i[1].y, i[2].y)
					trix, triy = i[2].x, r1y
					if l and t then
						lcd.drawFilledRectangle(trix, tr.y, tr.x - trix + 1, triy - tr.y, CUSTOM_COLOR)
					else
						lcd.drawFilledRectangle(tl.x, tl.y, trix - tl.x + 1, triy - tl.y, CUSTOM_COLOR)
					end
				elseif l and b then
					rec = false
					trix = r1x
				elseif r and b then
					rec = false
				end
			end
			if rec then
				lcd.drawFilledRectangle(r1x, r1y, r2x - r1x + 1, r2y - r1y + 1, CUSTOM_COLOR)
			end

			--lcd.drawText(270, 20, i[1].x .. " x " .. i[1].y)
			--lcd.drawText(270, 40, i[2].x .. " x " .. i[2].y)
			--lcd.drawText(270, 60, trix .. " x " .. triy)
			--lcd.drawText(270, 80, roll)

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
				--inc = math.abs(height) < 20 and 1 or (math.abs(height) < 40 and 2 or (math.abs(height) < width and 3 or 5))
				inc = math.abs(height) < width and 3 or 5
				local steps = height > 0 and inc or -inc
				local slope = width / height * inc
				local s = slope > 0 and 0 or inc - 1
				slope = math.abs(slope) * (tx1 < tx2 and 1 or -1)

				--lcd.drawText(270, 20, width .. " x " .. height .. " " .. inc)
				--lcd.drawText(270, 40, triy .. " " .. top .. " " .. steps)
				--lcd.drawText(270, 60, tx1 .. " " .. tx2)

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

				--lcd.drawLine(i[1].x, i[1].y, i[2].x, i[2].y, SOLID, WARNING_COLOR)
				--lcd.drawLine(i[1].x, i[1].y, trix, triy, SOLID, WARNING_COLOR)
				--lcd.drawLine(i[2].x, i[2].y, trix, triy, SOLID, WARNING_COLOR)
	
				--lcd.drawText(270, 20, i[1].x .. " x " .. i[1].y)
				--lcd.drawText(270, 40, i[2].x .. " x " .. i[2].y)
				--lcd.drawText(270, 60, roll)
			end

			-- Bonus smooth horizon, see if this actually makes it faster
			if not upsideDown and inc <= 3 then
				if inc ~= 1 then
					lcd.drawLine(i[1].x, i[1].y + 2, i[2].x, i[2].y + 2, SOLID, CUSTOM_COLOR)
					lcd.drawLine(i[1].x, i[1].y + 1, i[2].x, i[2].y + 1, SOLID, CUSTOM_COLOR)
					lcd.setColor(CUSTOM_COLOR, 982)
					lcd.drawLine(i[1].x, i[1].y - 1, i[2].x, i[2].y - 1, SOLID, CUSTOM_COLOR)
					lcd.drawLine(i[1].x, i[1].y - 2, i[2].x, i[2].y - 2, SOLID, CUSTOM_COLOR)
				end
				lcd.setColor(CUSTOM_COLOR, LIGHTGREY)
				lcd.drawLine(i[1].x, i[1].y, i[2].x, i[2].y, SOLID, CUSTOM_COLOR)
			end

		end

		--[[ Old method, tweaked to be fast, but maybe a more elegant method is more approprate
		local steps = roll3 <= 7 and 32 or (roll3 <= 20 and 16 or 8)
		local a = (y1 - y2) / (x1 - x2 + .001) * steps
		local y = y2 - ((x2 + 1) * a) / steps
		lcd.setColor(CUSTOM_COLOR, GROUND2)
		tmp = upsideDown and TOP or BOTTOM - 1
		for x = 1, RIGHT_POS - 2, steps do
			if x >= RIGHT_POS - 45 then
				lcd.setColor(CUSTOM_COLOR, GROUND2)
			elseif x >= 41 then
				lcd.setColor(CUSTOM_COLOR, GROUND)
			end
			local yy = y + 0.5
			if (not upsideDown and yy < BOTTOM) or (upsideDown and yy > 7) then
				local tmp2 = math.min(math.max(yy, TOP), BOTTOM)
				local tmp3 = upsideDown and tmp2 - tmp or tmp - tmp2 + 2
				tmp4 = upsideDown and tmp or tmp2
				if x == 33 and steps > 8 then
					lcd.drawFilledRectangle(x, tmp4, 8, tmp3, CUSTOM_COLOR)
					lcd.setColor(CUSTOM_COLOR, GROUND)
					lcd.drawFilledRectangle(x + 8, tmp4, steps == 16 and 8 or 24, tmp3, CUSTOM_COLOR)
				else
					lcd.drawFilledRectangle(x, tmp4, (x + steps > RIGHT_POS - 1) and RIGHT_POS - x - 1 or steps, tmp3, CUSTOM_COLOR)
				end
				if math.abs(a) > 3 then
					if not upsideDown then
						if roll > 90 then
							lcd.drawFilledRectangle(x, tmp4 - (a / 2), steps / (x > RIGHT_POS - 14 and 3 or 2), a / 2 + 1, CUSTOM_COLOR)
						elseif x > 8 and tmp4 - a < BOTTOM then
							lcd.drawFilledRectangle(x - steps / 2, tmp4 - (a / 2), steps / 2, -a / 2 + 1, CUSTOM_COLOR)
						end
					-- Upsidedown not totally fleshed out yet, but maybe it doesn't matter?
					--else
					--	if roll > 90 and x > 8 then
					--		lcd.drawFilledRectangle(x - steps / 2, tmp2 - a, steps / 2, a / 2 + 1, CUSTOM_COLOR)
					--	elseif tmp2 > TOP and tmp2 -a / 2 < BOTTOM then
					--		lcd.drawFilledRectangle(x, tmp2, steps / (x > RIGHT_POS - 14 and 3 or 2), -a / 2 + 1, CUSTOM_COLOR)
					--	end
					--
					end
				end
			end
			y = y + a
		end
		]]
	end

	local function pitchLine(r, adj)
		local x1, y1, x2, y2 = horCalc(r, adj)
		local py = Y_CNTR - math.cos(math.rad(pitch - adj)) * 170
		local x1 = math.sin(roll1) * r + X_CNTR
		local y1 = py - (math.cos(roll1) * r)
		local x2 = math.sin(roll2) * r + X_CNTR
		local y2 = py - (math.cos(roll2) * r)
		if (y1 > TOP or y2 > TOP) and (y1 < BOTTOM - 15 or y2 < BOTTOM - 15) and y1 >= 0 and y2 >= 0 then
			lcd.setColor(CUSTOM_COLOR, r == TOP and WHITE or LIGHTGREY)
			lcd.drawLine(x1, y1, x2, y2, SOLID, CUSTOM_COLOR)
			if r == TOP and y2 > TOP and y2 < BOTTOM - 15 then
				lcd.drawText(x2 - 1, y2 - 8, upsideDown and -adj or adj, SMLSIZE + RIGHT)
			end
		end
	end

	local function pitchLines(c, s, w, t, o) -- Center, Spread, Width, sTeps, cOlor
		local x1, y1, x2, y2 = horCalc(w, c - s)
		local x3, y3, x4, y4 = horCalc(w, c + s)
		local ys = (y3 - y1) / t
		lcd.setColor(CUSTOM_COLOR, o)
		for y = y1, y3 - 5, ys do
			if (y > TOP or y2 > TOP) and (y < BOTTOM - 15 or y2 < BOTTOM - 15) then
				lcd.drawLine(x1, y, x2, y2, SOLID, CUSTOM_COLOR)
			end
			y2 = y2 + ys
		end
	end

	local function tics(v, p)
		tmp = math.floor((v + TOP) / 10) * 10
		for i = tmp - 40, tmp, 5 do
			local tmp2 = Y_CNTR + ((v - i) * 3) - 9
			if tmp2 > 10 and tmp2 < BOTTOM - 8 then
				lcd.drawLine(p, tmp2 + 8, p + 2, tmp2 + 8, SOLID, CUSTOM_COLOR)
				if config[28].v == 0 and i % 10 == 0 and (i >= 0 or p > X_CNTR) and tmp2 < BOTTOM - 23 then
					lcd.drawText(p + (p > X_CNTR and -1 or 4), tmp2, i, SMLSIZE + (p > X_CNTR and RIGHT or 0) + CUSTOM_COLOR)
				end
			end
		end
	end

	-- Initalize variables on flight/telemetry reset
	if not data.armed and data.widget then
		tmp = model.getTimer(2)
		if tmp.value == 0 then
			loadfile(FILE_PATH .. "reset.luac")(data)
			tmp.value = 3600
			model.setTimer(2, tmp)
		end
	end

	-- Setup
	lcd.drawBitmap(icons.bg, 0, TOP)
	lcd.setColor(TEXT_COLOR, WHITE)
	lcd.setColor(WARNING_COLOR, data.telem and YELLOW or RED)

	-- Attitude indicator
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
	roll3 = math.abs(roll - 90)
	horizon()
	-- Pitch lines
	if data.telem and roll3 < 75 then
		tmp = pitch - 90
		if not data.showMax then
			lcd.drawText(X_CNTR - 65, Y_CNTR - 9, string.format("%.0f", upsideDown and -tmp or tmp) .. "\64", SMLSIZE + RIGHT)
		end
		-- 10% pitch lines
		local tmp2 = math.max(math.min((tmp >= 0 and math.floor(tmp / 5) or math.ceil(tmp / 5)) * 5, 30), -30)
		for x = tmp2 - 20, tmp2 + 20, 5 do
			if x ~= 0 and x % 10 == 0 then
				pitchLine(20, x)
			end
		end
		-- 5% pitch lines
		local tmp3 = tmp2
		if math.floor(math.abs(tmp2 / 10)) ~= math.abs(tmp2) / 10 then
			tmp3 = tmp2 + 5
		end
		pitchLines(tmp3, 15, 15, 3, LIGHTGREY) -- Center, Spread, Width, sTeps, cOlor
		-- 2.5% pitch lines if altitude graph is off
		if config[28].v == 0 and roll3 <= 20 then
			pitchLines(tmp2, 17.5, 7, 7, GREY) -- Center, Spread, Width, sTeps, cOlor
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
					lcd.drawText(tmp - (i < 270 and 3 or 5), BOTTOM - 15, i == 0 and "N" or (i == 90 and "E" or (i == 180 and "S" or "W")), SMLSIZE)
				elseif i % 45 == 0 then
					lcd.drawText(tmp - (i < 225 and 7 or 9), BOTTOM - 15, i == 45 and "NE" or (i == 135 and "SE" or (i == 225 and "SW" or "NW")), SMLSIZE)
				else
					lcd.drawLine(tmp, BOTTOM - 4, tmp, BOTTOM - 1, SOLID, 0)
				end
			end
		end
	end

	-- Speed & altitude tics
	lcd.setColor(CUSTOM_COLOR, LIGHTGREY)
	tics(data.speed, 1)
	tics(data.altitude, RIGHT_POS - 4)
	if config[28].v == 0 then
		lcd.drawText(42, TOP - 1, units[data.speed_unit], SMLSIZE)
		lcd.drawText(RIGHT_POS - 45, TOP - 1, "Alt " .. units[data.alt_unit], SMLSIZE + RIGHT)
	end

	-- View overlay
	lcd.drawBitmap(icons.fg, 1, 74)

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
		lcd.drawText(X_CNTR + 18, BOTTOM - 15, math.floor(data.heading + 0.5) % 360 .. "\64", SMLSIZE + RIGHT + data.telemFlags)
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
			lcd.drawText(X1, TOP + 1, data.fuel .. config[23].l[config[23].v], MIDSIZE + RIGHT + tmp)
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