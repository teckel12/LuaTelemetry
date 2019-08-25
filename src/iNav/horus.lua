local function view(data, config, modes, units, labels, gpsDegMin, hdopGraph, icons, calcBearing, calcDir, VERSION, SMLCD, FLASH, FILE_PATH)

	local SKY = 982 --rgb(0, 121, 180)
	local GROUND = 25121 --rgb(98, 68, 8)
	--local SKY2 = 8943 --rgb(32, 92, 122)
	--local GROUND2 = 20996 --rgb(81, 65, 36)
	--local MAP = 800 --rgb(0, 100, 0)
	--local DKMAP = 544 --rgb(0, 70, 0)
	local LIGHTMAP = 1184 --rgb(0, 150, 0)
	--local DATA = 264 --rgb(0, 32, 65)
	local DKGREY = 12744 --rgb(48, 56, 65) (was 12678 rgb(48, 48, 48))
	local RIGHT_POS = 270
	local X_CNTR = 134 --(RIGHT_POS + LEFT_POS [0]) / 2 - 1
	local HEADING_DEG = 190
	local PIXEL_DEG = RIGHT_POS / HEADING_DEG --(RIGHT_POS - LEFT_POS [0]) / HEADING_DEG
	local TOP = 20
	local BOTTOM = 146
	local Y_CNTR = 83 --(TOP + BOTTOM) / 2
	local DEGV = 160
	local tmp, tmp2, top2, bot2, pitch, roll, roll1, upsideDown
	local text = lcd.drawText
	local line = lcd.drawLine
	local fill = lcd.drawFilledRectangle
	local bmap = lcd.drawBitmap
	local rgb = lcd.RGB
	local color = lcd.setColor
	local max = math.max
	local min = math.min
	local floor = math.floor
	local abs = math.abs
	local rad = math.rad
	local deg = math.deg
	local sin = math.sin
	local cos = math.cos
	local fmt = string.format

	function intersect(s1, e1, s2, e2)
		local d = (s1.x - e1.x) * (s2.y - e2.y) - (s1.y - e1.y) * (s2.x - e2.x)
		local a = s1.x * e1.y - s1.y * e1.x
		local b = s2.x * e2.y - s2.y * e2.x
		local x = (a * (s2.x - e2.x) - (s1.x - e1.x) * b) / d
		local y = (a * (s2.y - e2.y) - (s1.y - e1.y) * b) / d
		if x < min(s2.x, e2.x) - 1 or x > max(s2.x, e2.x) + 1 or y < min(s2.y, e2.y) - 1 or y > max(s2.y, e2.y) + 1 then
			return nil, nil
		end
		return floor(x + 0.5), floor(y + 0.5)
	end

	local function pitchLadder(r, adj)
		--[[ Caged mode
		local x = sin(roll1) * r
		local y = cos(roll1) * r
		local p = cos(rad(pitch - adj)) * DEGV
		local x1, y1, x2, y2 = X_CNTR - x, Y_CNTR + y - p, X_CNTR + x, Y_CNTR - y - p
		]]
		-- Uncaged mode
		local p = sin(rad(adj)) * DEGV
		local y = (Y_CNTR - cos(rad(pitch)) * DEGV) - sin(roll1) * p
		if y > top2 and y < bot2 then
			local x = X_CNTR - cos(roll1) * p
			local xd = sin(roll1) * r
			local yd = cos(roll1) * r
			local x1, y1, x2, y2 = x - xd, y + yd, x + xd, y - yd
			if (y1 > top2 or y2 > top2) and (y1 < bot2 or y2 < bot2) and x1 >= 0 and x2 >= 0 then
				color(CUSTOM_COLOR, r == 20 and WHITE or LIGHTGREY)
				line(x1, y1, x2, y2, SOLID, CUSTOM_COLOR)
				if r == 20 and y1 > top2 and y1 < bot2 then
					text(x1 - 1, y1 - 8, upsideDown and -adj or adj, SMLSIZE + RIGHT)
				end
			end
		end
	end

	local function tics(v, p)
		tmp = floor((v + 25) * 0.1) * 10
		for i = tmp - 40, tmp, 5 do
			local tmp2 = Y_CNTR + ((v - i) * 3) - 9
			if tmp2 > 10 and tmp2 < BOTTOM - 8 then
				line(p, tmp2 + 8, p + 2, tmp2 + 8, SOLID, TEXT_COLOR)
				if config[28].v == 0 and i % 10 == 0 and (i >= 0 or p > X_CNTR) and tmp2 < BOTTOM - 23 then
					text(p + (p > X_CNTR and -1 or 4), tmp2, i, SMLSIZE + (p > X_CNTR and RIGHT or 0) + TEXT_COLOR)
				end
			end
		end
	end

	-- Setup
	bmap(icons.bg, 0, TOP)
	color(TEXT_COLOR, WHITE)
	color(WARNING_COLOR, data.telem and YELLOW or RED)

	-- Calculate orientation
	if data.pitchRoll then
		pitch = (abs(data.roll) > 900 and -1 or 1) * (270 - data.pitch * 0.1) % 180
		roll = (270 - data.roll * 0.1) % 180
		upsideDown = abs(data.roll) > 900
	else
		pitch = 90 - deg(math.atan2(data.accx * (data.accz >= 0 and -1 or 1), math.sqrt(data.accy * data.accy + data.accz * data.accz)))
		roll = 90 - deg(math.atan2(data.accy * (data.accz >= 0 and 1 or -1), math.sqrt(data.accx * data.accx + data.accz * data.accz)))
		upsideDown = data.accz < 0
	end
	roll1 = rad(roll)
	top2 = config[33].v == 0 and TOP or TOP + 20
	bot2 = BOTTOM - 15
	local i = { {}, {} }
	local tl = { x = 1, y = TOP }
	local tr = { x = RIGHT_POS - 2, y = TOP }
	local bl = { x = 1, y = BOTTOM - 1 }
	local br = { x = RIGHT_POS - 2, y = BOTTOM - 1 }
	local skip = false

	-- Calculate horizon (uses simple "caged" mode for less math)
	local x = sin(roll1) * 200
	local y = cos(roll1) * 200
	local p = cos(rad(pitch)) * DEGV
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
	color(CUSTOM_COLOR, GROUND)
	if skip then
		-- Must be going down hard!
		if (pitch - 90) * (upsideDown and -1 or 1) < 0 then
			fill(tl.x, tl.y, br.x - tl.x + 1, br.y - tl.y + 1, CUSTOM_COLOR)
		end
	else
		local trix, triy

		-- Find right angle coordinates of triangle
		if upsideDown then
			trix = roll > 90 and max(i[1].x, i[2].x) or min(i[1].x, i[2].x)
			triy = min(i[1].y, i[2].y)
		else
			trix = roll > 90 and min(i[1].x, i[2].x) or max(i[1].x, i[2].x)
			triy = max(i[1].y, i[2].y)
		end
		
		-- Find rectangle(s) and fill
		if upsideDown then
			if triy > tl.y then
				fill(tl.x, tl.y, br.x - tl.x + 1, triy - tl.y, CUSTOM_COLOR)
			end
			if roll > 90 and trix < br.x then
				fill(trix, triy, br.x - trix + 1, br.y - triy + 1, CUSTOM_COLOR)
			elseif roll <= 90 and trix > tl.x then
				fill(tl.x, triy, trix - tl.x, br.y - triy + 1, CUSTOM_COLOR)
			end
		else
			if triy < br.y then
				fill(tl.x, triy + 1, br.x - tl.x + 1, br.y - triy, CUSTOM_COLOR)
			end
			if roll > 90 and trix > tl.x then
				fill(tl.x, tl.y, trix - tl.x, triy - tl.y + 1, CUSTOM_COLOR)
			elseif roll <= 90 and trix < br.x then
				fill(trix, tl.y, br.x - trix + 1, triy - tl.y + 1, CUSTOM_COLOR)
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
			local width = abs(i[1].x - trix)
			local tx1 = i[1].x
			local tx2 = trix
			if width == 0 then
				width = abs(i[2].x - trix)
				tx1 = i[2].x
				tx2 = trix
			end
			inc = abs(height) < 10 and 1 or (abs(height) < 20 and 2 or ((abs(height) < width and abs(roll - 90) < 55) and 3 or 5))
			local steps = height > 0 and inc or -inc
			local slope = width / height * inc
			local s = slope > 0 and 0 or inc - 1
			slope = abs(slope) * (tx1 < tx2 and 1 or -1)
			for y = triy, top, steps do
				if abs(steps) == 1 then
					line(tx1, y, tx2, y, SOLID, CUSTOM_COLOR)
				else
					if tx1 < tx2 then
					--if tx1 < tx2 and tx2 - tx1 + 1 > 0 then
						fill(tx1, y - s, tx2 - tx1 + 1, inc, CUSTOM_COLOR)
					else
					--elseif tx1 > tx2 and tx1 - tx2 + 1 > 0 then
						fill(tx2, y - s, tx1 - tx2 + 1, inc, CUSTOM_COLOR)
					end
				end
				tx1 = tx1 + slope
			end
		end

		-- Smooth horizon
		if not upsideDown and inc <= 3 then
			if inc > 1 then
				if inc > 2 then
					line(i[1].x, i[1].y + 2, i[2].x, i[2].y + 2, SOLID, CUSTOM_COLOR)
				end
				line(i[1].x, i[1].y + 1, i[2].x, i[2].y + 1, SOLID, CUSTOM_COLOR)
				color(CUSTOM_COLOR, SKY)
				line(i[1].x, i[1].y - 1, i[2].x, i[2].y - 1, SOLID, CUSTOM_COLOR)
				if inc > 2 then
					line(i[1].x, i[1].y - 2, i[2].x, i[2].y - 2, SOLID, CUSTOM_COLOR)
				end
				if 90 - roll > 25 then
					line(i[1].x, i[1].y - 3, i[2].x, i[2].y - 3, SOLID, CUSTOM_COLOR)
				end
			end
			color(CUSTOM_COLOR, LIGHTGREY)
			line(i[1].x, i[1].y, i[2].x, i[2].y, SOLID, CUSTOM_COLOR)
		end
	end

	-- Pitch ladder
	if data.telem then
		tmp = pitch - 90
		local tmp2 = max(min((tmp >= 0 and floor(tmp * 0.2) or math.ceil(tmp * 0.2)) * 5, 30), -30)
		for x = tmp2 - 20, tmp2 + 20, 5 do
			if x ~= 0 and (x % 10 == 0 or (x > -30 and x < 30)) then
				pitchLadder(x % 10 == 0 and 20 or 15, x)
			end
		end
		if not data.showMax then
			text(X_CNTR - 65, Y_CNTR - 9, fmt("%.0f", upsideDown and -tmp or tmp) .. "\64", SMLSIZE + RIGHT)
		end
	end

	-- Speed & altitude tics
	tics(data.speed, 1)
	tics(data.altitude, RIGHT_POS - 4)
	if config[28].v == 0 and config[33].v == 0 then
		text(42, TOP - 1, units[data.speed_unit], SMLSIZE)
		text(RIGHT_POS - 45, TOP - 1, "Alt " .. units[data.alt_unit], SMLSIZE + RIGHT)
	elseif config[28].v > 0 then
		text(39, Y_CNTR - 25, units[data.speed_unit], SMLSIZE + RIGHT)
		text(RIGHT_POS - 6, Y_CNTR - 25, "Alt " .. units[data.alt_unit], SMLSIZE + RIGHT)
	end

	-- Compass
	if data.showHead then
		for i = 0, 348.75, 11.25 do
			tmp = floor(((i - data.heading + (361 + HEADING_DEG * 0.5)) % 360) * PIXEL_DEG - 2.5)
			if tmp >= 9 and tmp <= RIGHT_POS - 12 then
				if i % 90 == 0 then
					text(tmp - (i < 270 and 3 or 5), bot2, i == 0 and "N" or (i == 90 and "E" or (i == 180 and "S" or "W")), SMLSIZE)
				elseif i % 45 == 0 then
					text(tmp - (i < 225 and 7 or 9), bot2, i == 45 and "NE" or (i == 135 and "SE" or (i == 225 and "SW" or "NW")), SMLSIZE)
				else
					line(tmp, BOTTOM - 4, tmp, BOTTOM - 1, SOLID, 0)
				end
			end
		end
	end

	-- Calculate the maximum distance for scaling home location and map
	local maxDist = max(min(data.distanceMax, data.distanceLast * 6), data.distRef * 10)

	-- Home direction
	if data.showHead and data.armed and data.telem and data.gpsHome ~= false then
		if data.distanceLast >= data.distRef then
			local bearing = calcBearing(data.gpsHome, data.gpsLatLon) + 540 % 360
			if config[15].v == 1 then
				-- HUD method
				local d = 1 - data.distanceLast / maxDist
				local w = HEADING_DEG / (d + 1)
				local h = floor((((upsideDown and data.heading - bearing or bearing - data.heading) + (361 + w * 0.5)) % 360) * (RIGHT_POS / w) - 0.5)
				--local p = sin(math.atan(data.altitude / data.distanceLast) - math.atan(data.altitude / max(maxDist, data.altitude * 0.25))) * (upsideDown and DEGV or -DEGV)
				--local p = sin(rad(d * max(15 + (pitch - 90) * 0.5, 0))) * (upsideDown and DEGV or -DEGV)
				local p = sin(math.atan(data.altitude / data.distanceLast * 0.5)) * (upsideDown and DEGV or -DEGV)
				local x = (X_CNTR - cos(roll1) * p) + (sin(roll1) * (h - X_CNTR)) - 9
				local y = ((Y_CNTR - cos(rad(pitch)) * DEGV) - sin(roll1) * p) - (cos(roll1) * (h - X_CNTR)) - 9
				if x >= 0 and x < RIGHT_POS - 17 then
					local s = floor(d * 2 + 0.5)
					bmap(icons.home[s], x, min(max(y, s == 2 and TOP or 15), BOTTOM - (s == 2 and 35 or 30)))
				end
				--[[
				if x >= 0 and y >= TOP and x < RIGHT_POS - 17 and y < BOTTOM - 17 then
					bmap(icons.home[floor(d * 2 + 0.5)], x, y)
				end
				]]
			else
				-- Bottom-fixed method
				local home = floor(((bearing - data.heading + (361 + HEADING_DEG * 0.5)) % 360) * PIXEL_DEG - 2.5)
				if home >= 3 and home <= RIGHT_POS - 6 then
					bmap(icons.home[1], home - 7, BOTTOM - 31)
				end
			end
		end
		-- Flight path vector
		if data.fpv_id > -1 and data.speed >= 8 then
			tmp = (data.fpv - data.heading + 360) % 360
			if tmp >= 302 or tmp <= 57 then
				local fpv = floor(((data.fpv - data.heading + (361 + HEADING_DEG * 0.5)) % 360) * PIXEL_DEG - 0.5)
				--local p = sin(rad(data.vspeed_id == -1 and pitch - 90 or math.log(1 + min(abs(0.6 * (data.vspeed_unit == 6 and data.vspeed * 0.3048 or data.vspeed)), 10)) * (data.vspeed < 0 and -5 or 5))) * DEGV
				local p = sin(data.vspeed_id == -1 and rad(pitch - 90) or (math.tan(data.vspeed / (data.speed * (data.speed_unit == 8 and 1.4667 or 0.2778))))) * DEGV
				local x = (X_CNTR - cos(roll1) * p) + (sin(roll1) * (fpv - X_CNTR)) - 9
				local y = ((Y_CNTR - cos(rad(pitch)) * DEGV) - sin(roll1) * p) - (cos(roll1) * (fpv - X_CNTR)) - 6
				if y > TOP and y < bot2 and x >= 0 then
					bmap(icons.fpv, x, y)
				end
			end
		end
	end

	-- View overlay
	bmap(icons.fg, 1, 20)

	-- Speed & altitude
	tmp = data.showMax and data.speedMax or data.speed
	text(39, Y_CNTR - 9, tmp >= 99.5 and floor(tmp + 0.5) or fmt("%.1f", tmp), SMLSIZE + RIGHT + data.telemFlags)
	tmp = data.showMax and data.altitudeMax or data.altitude
	text(RIGHT_POS - 2, Y_CNTR - 9, floor(tmp + 0.5), SMLSIZE + RIGHT + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
	if data.altHold then
		bmap(icons.lock, RIGHT_POS - 55, Y_CNTR - 5)
	end

	-- Heading
	if data.showHead then
		text(X_CNTR + 18, bot2, floor(data.heading + 0.5) % 360 .. "\64", SMLSIZE + RIGHT + data.telemFlags)
	end

	-- Roll scale
	if config[33].v == 1 then
		bmap(icons.roll, 43, 20)
		if roll > 30 and roll < 150 and not upsideDown then
			local x1, y1, x2, y2, x3, y3 = calcDir(rad(roll - 90), rad(roll + 55), rad(roll - 235), X_CNTR - (cos(roll1) * 75), 79 - (sin(roll1) * 40), 7)
			color(CUSTOM_COLOR, YELLOW)
			line(x1, y1, x2, y2, SOLID, CUSTOM_COLOR)
			line(x1, y1, x3, y3, SOLID, CUSTOM_COLOR)
			line(x2, y2, x3, y3, SOLID, CUSTOM_COLOR)
		end
	end

	-- Variometer
	if config[7].v % 2 == 1 then
		color(CUSTOM_COLOR, DKGREY)
		fill(RIGHT_POS, TOP, 10, BOTTOM - 20, CUSTOM_COLOR)
		color(CUSTOM_COLOR, LIGHTGREY)
		line(RIGHT_POS + 10, TOP, RIGHT_POS + 10, BOTTOM - 1, SOLID, CUSTOM_COLOR)
		color(CUSTOM_COLOR, GREY)
		line(RIGHT_POS, Y_CNTR - 1, RIGHT_POS + 9, Y_CNTR - 1, SOLID, CUSTOM_COLOR)
		if data.telem then
			color(CUSTOM_COLOR, YELLOW)
			tmp = math.log(1 + min(abs(0.6 * (data.vspeed_unit == 6 and data.vspeed * 0.3048 or data.vspeed)), 10)) * (data.vspeed < 0 and -1 or 1)
			local y1 = Y_CNTR - (tmp * 0.416667 * (Y_CNTR - 21))
			local y2 = Y_CNTR - (tmp * 0.384615 * (Y_CNTR - 21))
			line(RIGHT_POS, y1 - 1, RIGHT_POS + 9, y2 - 1, SOLID, CUSTOM_COLOR)
			line(RIGHT_POS, y1, RIGHT_POS + 9, y2, SOLID, CUSTOM_COLOR)
		end
		if data.startup == 0 then
			text(RIGHT_POS + 13, TOP - 1, fmt(abs(data.vspeed) >= 9.95 and "%.0f" or "%.1f", data.vspeed) .. units[data.vspeed_unit], SMLSIZE + data.telemFlags)
		end
	end

	-- Calc orientation
	tmp = data.headingRef
	if data.showDir or data.headingRef == -1 then
		tmp = 0
	end
	local r1 = rad(data.heading - tmp)
	local r2 = rad(data.heading - tmp + 145)
	local r3 = rad(data.heading - tmp - 145)

	-- Radar
	local LEFT_POS = RIGHT_POS + (config[7].v % 2 == 1 and 11 or 0)
	RIGHT_POS = 479
	X_CNTR = (RIGHT_POS + LEFT_POS) * 0.5 - 1
	if data.startup == 0 then
		-- Launch/north-based orientation
		if data.showDir or data.headingRef == -1 then
			text(LEFT_POS + 2, Y_CNTR - 9, "W", SMLSIZE)
			text(RIGHT_POS, Y_CNTR - 9, "E", SMLSIZE + RIGHT)
		end
		local cx, cy, d

		-- Altitude graph
		if config[28].v > 0 then
			local factor = 30 / (data.altMax - data.altMin)
			color(CUSTOM_COLOR, LIGHTMAP)
			for i = 1, 60 do
				cx = RIGHT_POS - 60 + i
				cy = floor(BOTTOM - (data.alt[((data.altCur - 2 + i) % 60) + 1] - data.altMin) * factor + 0.5)
				if cy < BOTTOM then
					line(cx, cy, cx, BOTTOM - 1, SOLID, CUSTOM_COLOR)
				end
				if (i - 1) % (60 / config[28].v) == 0 then
					color(CUSTOM_COLOR, DKGREY)
					line(cx, BOTTOM - 30, cx, BOTTOM - 1, DOTTED, CUSTOM_COLOR)
					color(CUSTOM_COLOR, LIGHTMAP)
				end
			end
			if data.altMin < -1 then
				cy = BOTTOM - (-data.altMin * factor)
				color(CUSTOM_COLOR, LIGHTGREY)
				line(RIGHT_POS - 58, cy, RIGHT_POS - 1, cy, DOTTED, CUSTOM_COLOR)
				if cy < 142 then
					text(RIGHT_POS - 59, cy - 8, "0", SMLSIZE + RIGHT)
				end
			end
			text(RIGHT_POS + 2, BOTTOM - 46, floor(data.altMax + 0.5) .. units[data.alt_unit], SMLSIZE + RIGHT)
		end

		if data.gpsHome ~= false then
			-- Craft location
			tmp2 = config[31].v == 1 and 50 or 100
			d = data.distanceLast >= data.distRef and min(max(data.distanceLast / maxDist * tmp2, 7), tmp2) or 1
			local bearing = calcBearing(data.gpsHome, data.gpsLatLon) - tmp
			local rad1 = rad(bearing)
			cx = floor(sin(rad1) * d + 0.5)
			cy = floor(cos(rad1) * d + 0.5)
			-- Home position
			local hx = X_CNTR + 2
			local hy = Y_CNTR
			if config[31].v ~= 1 then
				hx = hx - (d > 9 and cx * 0.5 or 0)
				hy = hy + (d > 9 and cy * 0.5 or 0)
			end
			if d >= 12 then
				--bmap(icons.home, hx - 4, hy - 5)
				bmap(icons.home[1], hx - 8, hy - 10)
			elseif d > 1 then
				fill(hx - 1, hy - 1, 3, 3, SOLID)
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
		color(CUSTOM_COLOR, LIGHTGREY)
		line(x2, y2, x3, y3, SOLID, CUSTOM_COLOR)
		line(x1, y1, x2, y2, SOLID, TEXT_COLOR)
		line(x1, y1, x3, y3, SOLID, TEXT_COLOR)
		tmp = data.distanceLast < 1000 and floor(data.distanceLast + 0.5) .. units[data.dist_unit] or (fmt("%.1f", data.distanceLast / (data.dist_unit == 9 and 1000 or 5280)) .. (data.dist_unit == 9 and "km" or "mi"))
		text(LEFT_POS + 2, BOTTOM - 16, tmp, SMLSIZE + data.telemFlags)
	end

	-- Startup message
	if data.startup == 2 then
		color(CUSTOM_COLOR, BLACK)
		text(X_CNTR - 78, 55, "Lua Telemetry", MIDSIZE + CUSTOM_COLOR)
		text(X_CNTR - 38, 85, "v" .. VERSION, MIDSIZE + CUSTOM_COLOR)
		text(X_CNTR - 79, 54, "Lua Telemetry", MIDSIZE)
		text(X_CNTR - 39, 84, "v" .. VERSION, MIDSIZE)
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
		if config[23].v > 0 or (data.crsf and data.showMax) then
			text(X1, TOP + 1, (data.crsf and data.fuelRaw or data.fuel) .. data.fUnit[data.crsf and 1 or config[23].v], MIDSIZE + RIGHT + tmp)
		else
			text(X1 - 3, TOP, data.fuel .. "%", MIDSIZE + RIGHT + tmp)
			if data.fl ~= data.fuel then
				local red = data.fuel >= config[18].v and max(floor((100 - data.fuel) / (100 - config[18].v) * 255), 0) or 255
				local green = data.fuel < config[18].v and max(floor((data.fuel - config[17].v) / (config[18].v - config[17].v) * 255), 0) or 255
				data.fc = rgb(red, green, 60)
				data.fl = data.fuel
			end
			color(CUSTOM_COLOR, data.fc)
			lcd.drawGauge(0, TOP + 26, X1 - 3, 15, min(data.fuel, 99), 100, CUSTOM_COLOR)
		end
		text(0, TOP + ((config[23].v > 0 or (data.crsf and data.showMax)) and 23 or 9), labels[1], SMLSIZE)
	end

	local val = math.floor((data.showMax and data.cellMin or data.cell) * 100 + 0.5) * 0.01
	text(X1 - 3, TOP + 42, fmt(config[1].v == 0 and "%.2fV" or "%.1fV", config[1].v == 0 and val or (data.showMax and data.battMin or data.batt)), MIDSIZE + RIGHT + tmp)
	text(0, TOP + 51, labels[2], SMLSIZE)
	if data.bl ~= val then
		local red = val >= config[2].v and max(floor((4.2 - val) / (4.2 - config[2].v) * 255), 0) or 255
		local green = val < config[2].v and max(floor((val - config[3].v) / (config[2].v - config[3].v) * 255), 0) or 255
		data.bc = rgb(red, green, 60)
		data.bl = val
	end
	color(CUSTOM_COLOR, data.bc)
	lcd.drawGauge(0, TOP + 68, X1 - 3, 15, min(max(val - config[3].v + 0.1, 0) * (100 / (4.2 - config[3].v + 0.1)), 99), 100, CUSTOM_COLOR)

	tmp = (not data.telem or data.rssi < data.rssiLow) and FLASH or 0
	val = data.showMax and data.rssiMin or data.rssiLast
	text(X1 - 3, TOP + 84, val .. (data.crsf and "%" or "dB"), MIDSIZE + RIGHT + tmp)
	text(0, TOP + 93, data.crsf and "LQ" or "RSSI", SMLSIZE)
	if data.rl ~= val then
		local red = val >= data.rssiLow and max(floor((100 - val) / (100 - data.rssiLow) * 255), 0) or 255
		local green = val < data.rssiLow and max(floor((val - data.rssiCrit) / (data.rssiLow - data.rssiCrit) * 255), 0) or 255
		data.rc = rgb(red, green, 60)
		data.rl = val
	end
	color(CUSTOM_COLOR, data.rc)
	lcd.drawGauge(0, TOP + 110, X1 - 3, 15, min(val, 99), 100, CUSTOM_COLOR)

	-- Box 2 (altitude, distance, current)
	tmp = data.showMax and data.altitudeMax or data.altitude
	text(X1 + 9, TOP + 1, labels[4], SMLSIZE)
	text(X2, TOP + 12, floor(tmp + 0.5) .. units[data.alt_unit], MIDSIZE + RIGHT + ((not data.telem or tmp + 0.5 >= config[6].v) and FLASH or 0))
	tmp2 = data.showMax and data.distanceMax or data.distanceLast
	tmp = tmp2 < 1000 and floor(tmp2 + 0.5) .. units[data.dist_unit] or (fmt("%.1f", tmp2 / (data.dist_unit == 9 and 1000 or 5280)) .. (data.dist_unit == 9 and "km" or "mi"))
	text(X1 + 9, TOP + 44, labels[5], SMLSIZE)
	text(X2, TOP + 55, tmp, MIDSIZE + RIGHT + data.telemFlags)
	if data.showCurr then
		tmp = data.showMax and data.currentMax or data.current
		text(X1 + 9, TOP + 87, labels[3], SMLSIZE)
		text(X2, TOP + 98, (tmp >= 99.5 and floor(tmp + 0.5) or fmt("%.1fA", tmp)), MIDSIZE + RIGHT + data.telemFlags)
	end

	-- Box 3 (flight modes, orientation)
	text(X2 + 20, TOP, modes[data.modeId].t, modes[data.modeId].f == 3 and WARNING_COLOR or 0)
	if data.altHold then
		bmap(icons.lock, X1 + 63, TOP + 4)
	end
	if data.headFree then
		text(X2 + 7, TOP + 19, "HF", FLASH)
	end

	if data.showHead then
		if data.showDir or data.headingRef == -1 then
			text((X2 + X3) * 0.5, TOP + 18, "N", SMLSIZE)
			text(X3 - 4, 211, "E", SMLSIZE + RIGHT)
			text(X2 + 10, 211, "W", SMLSIZE)
			text(X2 + 78, BOTTOM - 15, floor(data.heading + 0.5) % 360 .. "\64", SMLSIZE + RIGHT + data.telemFlags)
		end
		local x1, y1, x2, y2, x3, y3 = calcDir(r1, r2, r3, (X2 + X3) * 0.5 + 4, 219, 25)
		if data.headingHold then
			fill((x2 + x3) * 0.5 - 2, (y2 + y3) * 0.5 - 2, 5, 5, SOLID)
		else
			color(CUSTOM_COLOR, GREY)
			line(x2, y2, x3, y3, SOLID, CUSTOM_COLOR)
		end
		line(x1, y1, x2, y2, SOLID, TEXT_COLOR)
		line(x1, y1, x3, y3, SOLID, TEXT_COLOR)
	end

	-- Box 4 (GPS info, speed)
	if data.crsf then
		if data.tpwr then
			text(RIGHT_POS, TOP, data.tpwr .. "mW", RIGHT + MIDSIZE + data.telemFlags)
		end
		text(RIGHT_POS + 1, TOP + 28, data.satellites % 100, MIDSIZE + RIGHT + data.telemFlags)
	else
		tmp = ((data.armed or data.modeId == 6) and data.hdop < 11 - config[21].v * 2) or not data.telem
		text(X3 + 48, TOP, (data.hdop == 0 and not data.gpsFix) and "-- --" or (9 - data.hdop) * 0.5 + 0.8, MIDSIZE + RIGHT + (tmp and FLASH or 0))
		text(X3 + 11, TOP + 24, "HDOP", SMLSIZE)
		text(RIGHT_POS + 1, TOP, data.satellites % 100, MIDSIZE + RIGHT + data.telemFlags)
	end
	hdopGraph(X3 + 65, TOP + (data.crsf and 51 or 23))
	tmp = RIGHT + ((not data.telem or not data.gpsFix) and FLASH or 0)
	if not data.crsf then
		text(RIGHT_POS, TOP + 28, floor(data.gpsAlt + 0.5) .. (data.gpsAlt_unit == 10 and "'" or units[data.gpsAlt_unit]), MIDSIZE + tmp)
	end
	text(RIGHT_POS, TOP + 54, config[16].v == 0 and fmt("%.6f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), tmp)
	text(RIGHT_POS, TOP + 74, config[16].v == 0 and fmt("%.6f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), tmp)
	tmp = data.showMax and data.speedMax or data.speed
	text(RIGHT_POS + 1, TOP + 98, tmp >= 99.5 and floor(tmp + 0.5) .. units[data.speed_unit] or fmt("%.1f", tmp) .. units[data.speed_unit], MIDSIZE + RIGHT + data.telemFlags)

	-- Dividers
	color(CUSTOM_COLOR, DKGREY)
	line(X1 + 3, TOP, X1 + 3, BOTTOM, SOLID, CUSTOM_COLOR)
	line(X2 + 3, TOP, X2 + 3, BOTTOM, SOLID, CUSTOM_COLOR)
	line(X3 + 3, TOP, X3 + 3, BOTTOM, SOLID, CUSTOM_COLOR)
	line(X3 + 3, TOP + 95, RIGHT_POS, TOP + 95, SOLID, CUSTOM_COLOR)
	if data.crsf then
		line(X3 + 3, TOP + 28, RIGHT_POS, TOP + 28, SOLID, CUSTOM_COLOR)
	end
	color(CUSTOM_COLOR, LIGHTGREY)
	line(0, TOP - 1, LCD_W - 1, TOP - 1, SOLID, CUSTOM_COLOR)

	if data.showMax then
		color(CUSTOM_COLOR, YELLOW)
		fill(190, TOP - 20, 80, 20, CUSTOM_COLOR)
		color(CUSTOM_COLOR, BLACK)
		text(265, TOP - 20, "Min/Max", CUSTOM_COLOR + RIGHT)
	end
end

return view