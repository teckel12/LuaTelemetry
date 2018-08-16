local data, config, modes, units, VERSION, SMLCD, FLASH, FILE_PATH = ...

local LEFT_POS = SMLCD and 0 or 36
local RIGHT_POS = SMLCD and LCD_W - 31 or LCD_W - 53
local X_CNTR = (RIGHT_POS + LEFT_POS) / 2 - 2
local HEADING_DEG = SMLCD and 170 or 190
local PIXEL_DEG = (RIGHT_POS - LEFT_POS) / HEADING_DEG
local gpsFlags = SMLSIZE + RIGHT + ((not data.telemetry or not data.gpsFix) and FLASH or 0)
local tmp, pitch, roll, roll1, roll2, upsideDown

local gpsDegMin, gpsIcon, lockIcon, homeIcon, hdopGraph = loadScript(FILE_PATH .. "widgets.luac", "T")(data, config, SMLCD, FLASH)

local function attitude(radius, pitchAdj)
	local py = 35 - math.cos(math.rad(pitch - pitchAdj)) * 85
	local x1 = math.sin(roll1) * radius + X_CNTR
	local y1 = py - (math.cos(roll1) * radius)
	local x2 = math.sin(roll2) * radius + X_CNTR
	local y2 = py - (math.cos(roll2) * radius)
	if pitchAdj == 0 then
		local a = (y1 - y2) / (x1 - x2 + .001)
		local y = y2 - ((x2 - LEFT_POS + 1) * a)
		for x = LEFT_POS + 1, RIGHT_POS - 1 do
			local yy = y + 0.5
			if (not upsideDown and yy < 64) or (upsideDown and yy > 7) then
				lcd.drawLine(x, math.min(math.max(yy, 8), 63), x, upsideDown and 8 or 63, SOLID, SMLCD and 0 or GREY_DEFAULT)
			end
			y = y + a
		end
	elseif (y1 > 15 or y2 > 15) and (y1 < 56 or y2 < 56) then
		lcd.drawLine(x1, y1, x2, y2, SMLCD and DOTTED or (pitchAdj % 10 == 0 and SOLID or DOTTED), SMLCD and 0 or (pitchAdj > 0 and GREY_DEFAULT or 0))
		if not SMLCD and pitchAdj % 10 == 0 and pitchAdj ~= 0 and y2 > 15 and y2 < 56 then
			lcd.drawText(x2 - 2, y2 - 3, math.abs(pitchAdj), SMLSIZE + RIGHT)
		end
	end
end

local function tics(value, pos)
	for i = value % 10 + 8, 56, 10 do
		if i < 31 or i > 41 then
			lcd.drawLine(pos, i, pos + 1, i, SOLID, 0)
		end
	end
end

-- Startup message
if data.startup == 2 then
	if not SMLCD then
		lcd.drawText(50, 20, "INAV Lua Telemetry")
	end
	lcd.drawText(X_CNTR - 12, SMLCD and 20 or 42, "v" .. VERSION)
end

-- Orientation
if data.telemetry and data.headingRef >= 0 and data.startup == 0 then
	local x = LEFT_POS + 13.5
	local rad1 = math.rad(data.heading - data.headingRef)
	local rad2 = math.rad(data.heading - data.headingRef + 145)
	local rad3 = math.rad(data.heading - data.headingRef - 145)
	local x1 = math.sin(rad1) * 7 + x
	local y1 = 21 - math.cos(rad1) * 7
	local x2 = math.sin(rad2) * 7 + x
	local y2 = 21 - math.cos(rad2) * 7
	local x3 = math.sin(rad3) * 7 + x
	local y3 = 21 - math.cos(rad3) * 7
	lcd.drawLine(x2, y2, x3, y3, SMLCD and DOTTED or SOLID, FORCE + (SMLCD and 0 or GREY_DEFAULT))
	lcd.drawLine(x1, y1, x2, y2, SOLID, FORCE)
	lcd.drawLine(x1, y1, x3, y3, SOLID, FORCE)
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
if data.startup == 0 and data.telemetry then
	tmp = pitch - 90
	local short = SMLCD and 4 or 6
	local tmp2 = tmp >= 0 and math.floor(tmp + 0.5) or math.ceil(tmp - 0.5)
	lcd.drawText(X_CNTR - (SMLCD and 14 or 24), 33, math.abs(tmp2) .. (SMLCD and "" or "\64"), SMLSIZE + RIGHT)
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

-- Home direction
if data.showHead and data.armed and data.telemetry and data.gpsHome ~= false and data.startup == 0 and ((SMLCD and not data.showDir) or not SMLCD) then
	local home = X_CNTR - 3
	if data.distanceLast >= data.distRef then
		local o1 = math.rad(data.gpsHome.lat)
		local a1 = math.rad(data.gpsHome.lon)
		local o2 = math.rad(data.gpsLatLon.lat)
		local a2 = math.rad(data.gpsLatLon.lon)
		local y = math.sin(a2 - a1) * math.cos(o2)
		local x = (math.cos(o1) * math.sin(o2)) - (math.sin(o1) * math.cos(o2) * math.cos(a2 - a1))
		local bearing = math.deg(math.atan2(y, x)) + 540 % 360
		home = math.floor(LEFT_POS + ((bearing - data.heading + (361 + HEADING_DEG / 2)) % 360) * PIXEL_DEG - 2.5)
	end
	if home >= LEFT_POS - (SMLCD and 0 or 7) and home <= RIGHT_POS - 1 then
		tmp = (home > X_CNTR - 15 and home < X_CNTR + 10) and 49 or 50
		lcd.drawFilledRectangle(home, tmp - 1, 7, 8, ERASE)
		if data.distanceLast < data.distRef then
			lcd.drawText(home + 1, tmp, "  ", SMLSIZE + FLASH)
		end
		homeIcon(home, tmp)
	end
end

-- Heading part 1
if data.showHead then
	for i = 0, 348.75, 11.25 do
		tmp = math.floor(LEFT_POS + ((i - data.heading + (361 + HEADING_DEG / 2)) % 360) * PIXEL_DEG - 2.5)
		if tmp >= LEFT_POS and tmp <= RIGHT_POS then
			if i % 90 == 0 then
				lcd.drawText(tmp - 2, 57, i == 0 and "N" or (i == 90 and "E" or (i == 180 and "S" or "W")), SMLSIZE)
			elseif i % 45 == 0 then
				lcd.drawText(tmp - 4, 57, i == 45 and "NE" or (i == 135 and "SE" or (i == 225 and "SW" or "NW")), SMLSIZE)
			elseif tmp < X_CNTR - 10 or tmp > X_CNTR + 9 then
				lcd.drawLine(tmp, 62, tmp, 63, SOLID, FORCE)
			end
		end
	end
	lcd.drawFilledRectangle(RIGHT_POS, 49, 6, 14, ERASE)
end

-- Battery and GPS overlay
if SMLCD then
	homeIcon(LEFT_POS + 4, 42)
	lcd.drawText(LEFT_POS + 12, 42, data.distanceLast < 1000 and data.distanceLast .. units[data.distance_unit] or (string.format("%.1f", data.distanceLast / (data.distance_unit == 9 and 1000 or 5280)) .. (data.distance_unit == 9 and "km" or "mi")), SMLSIZE + data.telemFlags)
	tmp = (not data.telemetry or data.cell < config[3].v or (config[23].v == 0 and data.fuel <= config[17].v)) and FLASH or 0
	if config[23].v == 0 then
		lcd.drawText(RIGHT_POS - 7, 8, data.fuel, MIDSIZE + RIGHT + tmp)
		lcd.drawText(RIGHT_POS - 2, 13, "%", SMLSIZE + RIGHT + tmp)
	else
		lcd.drawText(RIGHT_POS - 2, 9, data.fuel, SMLSIZE + RIGHT + tmp)
	end
	lcd.drawText(RIGHT_POS - 7, 19, string.format(config[1].v == 0 and "%.2f" or "%.1f", config[1].v == 0 and data.cell or data.batt), MIDSIZE + RIGHT + tmp)
	lcd.drawText(RIGHT_POS - 2, 24, "V", SMLSIZE + RIGHT + tmp)
	if data.showDir then
		lcd.drawText(RIGHT_POS - 2, 42, config[16].v == 0 and string.format("%.5f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), gpsFlags)
		lcd.drawText(RIGHT_POS - 2, 49, config[16].v == 0 and string.format("%.5f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), gpsFlags)
	elseif data.showCurr then
		lcd.drawText(RIGHT_POS - 2, 42, string.format("%.1fA", data.current), SMLSIZE + RIGHT + data.telemFlags)
	end
end

-- Flight modes
tmp = X_CNTR - (SMLCD and 16 or 19)
lcd.drawLine(tmp, 9, tmp, 15, SOLID, ERASE)
lcd.drawText(tmp + 1, 9, modes[data.modeId].t, SMLSIZE + modes[data.modeId].f)
if data.headFree then
	lcd.drawText(tmp, 9, "HF", SMLSIZE + FLASH + RIGHT)
end
if data.altHold then
	lockIcon(RIGHT_POS - 28, 33)
end
if data.headingHold then
	lockIcon(LEFT_POS + 4, 9)
end

-- Attitude part 2
lcd.drawFilledRectangle(X_CNTR - 1, 34, 3, 3, ERASE)
attitude(200, 0)
local inside = SMLCD and 6 or 13
local outside = SMLCD and 14 or 24
lcd.drawLine(X_CNTR - outside, 35, X_CNTR - inside, 35, SOLID, SMLCD and 0 or FORCE)
lcd.drawLine(X_CNTR + outside, 35, X_CNTR + inside, 35, SOLID, SMLCD and 0 or FORCE)
lcd.drawLine(X_CNTR - inside, 36, X_CNTR - inside, SMLCD and 37 or 38, SOLID, SMLCD and 0 or FORCE)
lcd.drawLine(X_CNTR + inside, 36, X_CNTR + inside, SMLCD and 37 or 38, SOLID, SMLCD and 0 or FORCE)
lcd.drawLine(X_CNTR - 1, 35, X_CNTR + 1, 35, SOLID, SMLCD and 0 or FORCE)
if SMLCD then
	lcd.drawPoint(X_CNTR, 34, 0)
	lcd.drawPoint(X_CNTR, 36, 0)
else
	lcd.drawLine(X_CNTR, 34, X_CNTR, 36, SOLID, FORCE)
end

-- Heading part 2
if data.showHead then
	lcd.drawLine(X_CNTR - 9, 56, X_CNTR + 10, 56, SOLID, ERASE)
	lcd.drawLine(X_CNTR - 10, 56, X_CNTR - 10, 63, SOLID, ERASE)
	lcd.drawText(X_CNTR - 9, 57, "      ", SMLSIZE + data.telemFlags)
	lcd.drawText(X_CNTR + 11, 57, math.floor(data.heading + 0.5) % 360 .. "\64", SMLSIZE + RIGHT + data.telemFlags)
	if not SMLCD then
		lcd.drawRectangle(X_CNTR - 11, 55, 23, 10, FORCE)
	end
end

-- Speed
lcd.drawLine(LEFT_POS, 8, LEFT_POS, 63, SOLID, FORCE)
tics(data.speed, LEFT_POS + 1)
lcd.drawLine(LEFT_POS + 1, 32, LEFT_POS + 18, 32, SOLID, ERASE)
lcd.drawText(LEFT_POS + 1, 33, "      ", SMLSIZE + data.telemFlags)
lcd.drawText(LEFT_POS + 19, 33, data.startup == 0 and (data.speed >= 99.5 and math.floor(data.speed + 0.5) or string.format("%.1f", data.speed)) or "Spd", SMLSIZE + RIGHT + data.telemFlags)
lcd.drawRectangle(LEFT_POS, 31, 20, 10, FORCE)

-- Altitude
tics(data.altitude, RIGHT_POS - 2)
lcd.drawLine(RIGHT_POS - 21, 32, RIGHT_POS, 32, SOLID, ERASE)
lcd.drawText(RIGHT_POS - 21, 33, "       ", SMLSIZE + ((not data.telemetry or data.altitude + 0.5 >= config[6].v) and FLASH or 0))
lcd.drawText(RIGHT_POS, 33, data.startup == 0 and (math.floor(data.altitude + 0.5)) or "Alt", SMLSIZE + RIGHT + ((not data.telemetry or data.altitude + 0.5 >= config[6].v) and FLASH or 0))
lcd.drawRectangle(RIGHT_POS - 22, 31, 23, 10, FORCE)

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
local rssiFlags = RIGHT + ((not data.telemetry or data.rssi < data.rssiLow) and FLASH or 0)
lcd.drawText(LCD_W - 10, 52, math.min(data.rssiLast, 99), MIDSIZE + rssiFlags)
lcd.drawText(LCD_W, 57, "dB", SMLSIZE + rssiFlags)

-- Left data - Battery
if not SMLCD then
	lcd.drawFilledRectangle(LEFT_POS - 7, 49, 7, 14, ERASE)
	tmp = (not data.telemetry or data.cell < config[3].v or (config[23].v == 0 and data.fuel <= config[17].v)) and FLASH or 0
	if config[23].v == 0 then
		lcd.drawText(LEFT_POS - 5, data.showCurr and 8 or 12, data.fuel, DBLSIZE + RIGHT + tmp)
		lcd.drawText(LEFT_POS, data.showCurr and 17 or 21, "%", SMLSIZE + RIGHT + tmp)
	else
		lcd.drawText(LEFT_POS, data.showCurr and 8 or 10, data.fuel, MIDSIZE + RIGHT + tmp)
		lcd.drawText(LEFT_POS, data.showCurr and 20 or 23, config[23].l[config[23].v], SMLSIZE + RIGHT + tmp)
	end
	lcd.drawText(LEFT_POS - 5, data.showCurr and 25 or 32, string.format(config[1].v == 0 and "%.2f" or "%.1f", config[1].v == 0 and data.cell or data.batt), DBLSIZE + RIGHT + tmp)
	lcd.drawText(LEFT_POS, data.showCurr and 34 or 41, "V", SMLSIZE + RIGHT + tmp)
	if data.showCurr then
		lcd.drawText(LEFT_POS - 5, 42, data.current >= 99.5 and math.floor(data.current + 0.5) or string.format("%.1f", data.current), MIDSIZE + RIGHT + data.telemFlags)
		lcd.drawText(LEFT_POS, 47, "A", SMLSIZE + RIGHT + data.telemFlags)
	end
	lcd.drawLine(0, data.showCurr and 54 or 53, LEFT_POS, data.showCurr and 54 or 53, SOLID, FORCE)
	homeIcon(0, 57)
	lcd.drawText(LEFT_POS, 57, data.distanceLast < 1000 and data.distanceLast .. units[data.distance_unit] or (string.format("%.1f", data.distanceLast / (data.distance_unit == 9 and 1000 or 5280)) .. (data.distance_unit == 9 and "km" or "mi")), SMLSIZE + RIGHT + data.telemFlags)
end

return 0