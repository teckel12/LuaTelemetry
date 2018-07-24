local data, config, modes, units, gpsDegMin, gpsIcon, lockIcon, homeIcon, hdopGraph, VERSION, SMLCD, FLASH = ...

local LEFT_POS = SMLCD and 0 or 0
local RIGHT_POS = SMLCD and LCD_W - 31 or LCD_W - 53
local X_CNTR = (RIGHT_POS + LEFT_POS) / 2 - 2
local PIXEL_DEG = (RIGHT_POS - LEFT_POS) / 180
local tmp

local function attitude(pitch, roll, radius, pitchAdj)
	local pitch1 = math.rad(pitch - pitchAdj)
	local roll1 = math.rad(roll)
	local roll2 = math.rad(roll + 180)
	local py = 35 - math.cos(pitch1) * 85
	local x1 = math.floor(math.sin(roll1) * radius + X_CNTR + 0.5)
	local y1 = math.floor(py - (math.cos(roll1) * radius) + 0.5)
	local x2 = math.floor(math.sin(roll2) * radius + X_CNTR + 0.5)
	local y2 = math.floor(py - (math.cos(roll2) * radius) + 0.5)
	if pitchAdj == 0 then
		local a1 = (y1 - y2) / (x1 - x2 + .001)
		local x3 = RIGHT_POS - 1
		local x4 = LEFT_POS + 1
		local y3 = y1 - ((x1 - RIGHT_POS - 1) * a1)
		local y4 = y2 - ((x2 - LEFT_POS + 1) * a1)
		local a2 = (y4 - y3) / (RIGHT_POS - 1 - LEFT_POS)
		local miny =7
		local maxy = 55
		local y = y4
		for x = LEFT_POS + 1, RIGHT_POS - 1 do
			lcd.drawLine(x, math.min(math.max(y, miny), 62), x, 62, SOLID, SMLCD and 0 or GREY_DEFAULT)
			y = y + a1
		end
	elseif (y1 > 15 or y2 > 15) and (y1 < 56 or y2 < 56) then
		lcd.drawLine(x1, y1, x2, y2, SMLCD and DOTTED or (pitchAdj % 10 == 0 and SOLID or DOTTED), SMLCD and 0 or (pitchAdj > 0 and GREY_DEFAULT or 0))
	end
	if pitchAdj % 10 == 0 and pitchAdj ~= 0 and y2 > 15 and y2 < 56 then
		lcd.drawText(x2 - 1, y2 - 3, math.abs(pitchAdj), SMLSIZE + RIGHT)
	end
end

-- Startup message
if data.startup == 2 then
	lcd.drawText(X_CNTR - 12, 32, "v" .. VERSION)
end

-- Inside attitude info
lcd.drawText(LEFT_POS + 4, 42, units[data.speed_unit], SMLSIZE)
if not SMLCD or not data.showDir then
	lcd.drawText(RIGHT_POS - 2, 42, "Alt", SMLSIZE + RIGHT)
	lcd.drawText(RIGHT_POS - 11, 50, data.distanceLast .. units[data.distance_unit], (data.showCurr and SMLSIZE or 0) + RIGHT + data.telemFlags)
	homeIcon(RIGHT_POS - 10, 50)
end
lcd.drawText(RIGHT_POS - 7, 8, data.fuel, MIDSIZE + RIGHT + data.telemFlags)
lcd.drawText(RIGHT_POS - 2, 13, "%", SMLSIZE + RIGHT + data.telemFlags)
lcd.drawText(RIGHT_POS - 7, 19, string.format("%.1f", config[1].v == 0 and data.cell or data.batt), MIDSIZE + RIGHT + data.telemFlags)
lcd.drawText(RIGHT_POS - 2, 24, "V", SMLSIZE + RIGHT + data.telemFlags)

-- Orientation
if data.telemetry and data.headingRef >= 0 then
	local width = 145
	local radius = 8
	local x = LEFT_POS + 13
	local y = 20
	local rad1 = math.rad(data.heading - data.headingRef)
	local rad2 = math.rad(data.heading - data.headingRef + width)
	local rad3 = math.rad(data.heading - data.headingRef - width)
	local x1 = math.floor(math.sin(rad1) * radius + 0.5) + x
	local y1 = y - math.floor(math.cos(rad1) * radius + 0.5)
	local x2 = math.floor(math.sin(rad2) * radius + 0.5) + x
	local y2 = y - math.floor(math.cos(rad2) * radius + 0.5)
	local x3 = math.floor(math.sin(rad3) * radius + 0.5) + x
	local y3 = y - math.floor(math.cos(rad3) * radius + 0.5)
	lcd.drawLine(x1, y1, x2, y2, SOLID, FORCE)
	lcd.drawLine(x1, y1, x3, y3, SOLID, FORCE)
	if data.headingHold then
		lcd.drawFilledRectangle((x2 + x3) / 2 - 1.5, (y2 + y3) / 2 - 1.5, 4, 4, SOLID)
	else
		lcd.drawLine(x2, y2, x3, y3, SMLCD and DOTTED or SOLID, FORCE + (SMLCD and 0 or GREY_DEFAULT))
	end
end

-- Attitude part 1
local pitch = 90 - math.deg(math.atan2(-data.accx, (math.sqrt((data.accy * data.accy) + (data.accz * data.accz)))))
local roll = 90 - math.deg(math.atan2(data.accy, (math.sqrt((data.accx * data.accx) + (data.accz * data.accz)))))
if data.startup == 0 then
	tmp = pitch - 90
	--lcd.drawText(LEFT_POS + 4, 45, math.floor(tmp) .. "\64", SMLSIZE + INVERS)
	if tmp <= 25 and tmp >= -10 then
		attitude(pitch, roll, 5, 5)
		attitude(pitch, roll, 10, 10)
	end
	if tmp <= 10 and tmp >= -25 then	
		attitude(pitch, roll, 5, -5)
		attitude(pitch, roll, 10, -10)
	end
	if tmp >= 0 then
		attitude(pitch, roll, 5, 15)
		attitude(pitch, roll, 10, 20)
	else
		attitude(pitch, roll, 5, -15)
		attitude(pitch, roll, 10, -20)
	end
	if tmp >= 10 then
		attitude(pitch, roll, 5, 25)
		attitude(pitch, roll, 10, 30)
	elseif tmp <= -10 then
		attitude(pitch, roll, 5, -25)
		attitude(pitch, roll, 10, -30)
	end
end

-- Heading part 1
if data.showHead then
	for i = 0, 348.75, 11.25 do
		tmp = LEFT_POS + ((i - data.heading + 451) % 360) * PIXEL_DEG - 3
		if tmp >= LEFT_POS and tmp <= RIGHT_POS then
			if i % 90 == 0 then
				lcd.drawText(tmp - 2, 57, i == 0 and "N" or (i == 90 and "E" or (i == 180 and "S" or "W")), SMLSIZE)
			elseif i % 45 == 0 then
				lcd.drawText(tmp - 4, 57, i == 45 and "NE" or (i == 135 and "SE" or (i == 225 and "SW" or "NW")), SMLSIZE)
			elseif tmp < X_CNTR - 11 or tmp > X_CNTR + 10 then
				lcd.drawLine(tmp, 61, tmp, 62, SOLID, FORCE)
			end
		end
	end
	lcd.drawLine(LEFT_POS + 1, 63, RIGHT_POS - 1, 63, SOLID, FORCE)
	lcd.drawFilledRectangle(RIGHT_POS, 57, 6, 6, ERASE)
end

-- Attitude part 2
if data.startup == 0 then
	if data.telemetry then
		attitude(pitch, roll, 200, 0)
	else
		lcd.drawFilledRectangle(LEFT_POS + 1, 35, RIGHT_POS - LEFT_POS - 1, 28, GREY_DEFAULT)
	end
	lcd.drawLine(X_CNTR - 17, 35, X_CNTR - 6, 35, SOLID, SMLCD and 0 or FORCE)
	lcd.drawLine(X_CNTR + 17, 35, X_CNTR + 6, 35, SOLID, SMLCD and 0 or FORCE)
	lcd.drawLine(X_CNTR - 1, 35, X_CNTR + 1, 35, SOLID, SMLCD and 0 or FORCE)
	lcd.drawPoint(X_CNTR, 34, SMLCD and 0 or FORCE)
	lcd.drawPoint(X_CNTR, 36, SMLCD and 0 or FORCE)
end

-- Heading part 2
if data.showHead then
	lcd.drawLine(X_CNTR - 10, 56, X_CNTR + 10, 56, SOLID, ERASE)
	lcd.drawText(X_CNTR - 10, 57, "      ", SMLSIZE + data.telemFlags)
	lcd.drawText(X_CNTR + 10, 57, math.floor(data.heading + 0.5) % 360 .. "\64", SMLSIZE + RIGHT + data.telemFlags)
	lcd.drawRectangle(X_CNTR - 11, 55, 22, 10, FORCE)
end

-- Flight modes
tmp = X_CNTR - (SMLCD and 16 or 19)
lcd.drawLine(tmp, 9, tmp, 15, SOLID, ERASE)
lcd.drawText(tmp + 1, 9, modes[data.modeId].t, SMLSIZE + modes[data.modeId].f)
if data.headFree then
	lcd.drawText(tmp, 9, "HF", SMLSIZE + FLASH + RIGHT)
end
if data.altHold and (not SMLCD or not data.showDir) then
	lockIcon(RIGHT_POS - 22, 42)
end

-- Speed
lcd.drawLine(LEFT_POS, 8, LEFT_POS, 63, SOLID, FORCE)
for i = data.speed % 10 + 8, 56, 10 do
	if i < 31 or i > 41 then
		lcd.drawLine(LEFT_POS + 1, i, LEFT_POS + 2, i, SOLID, 0)
	end
end
lcd.drawLine(LEFT_POS, 32, LEFT_POS + 18, 32, SOLID, ERASE)
lcd.drawText(LEFT_POS, 33, "      ", SMLSIZE + data.telemFlags)
lcd.drawRectangle(LEFT_POS - 1, 31, 21, 10, FORCE)
lcd.drawText(LEFT_POS + 19, 33, data.speed >= 99.5 and math.floor(data.speed + 0.5) or string.format("%.1f", data.speed), SMLSIZE + RIGHT + data.telemFlags)

-- Altitude
for i = data.altitude % 10 + 8, 56, 10 do
	if i < 31 or i > 41 then
		lcd.drawLine(RIGHT_POS - 2, i, RIGHT_POS - 1, i, SOLID, 0)
	end
end
lcd.drawLine(RIGHT_POS - 21, 32, RIGHT_POS, 32, SOLID, ERASE)
lcd.drawText(RIGHT_POS - 21, 33, "       ", SMLSIZE + data.telemFlags)
lcd.drawRectangle(RIGHT_POS - 22, 31, 23, 10, FORCE)
lcd.drawText(RIGHT_POS, 33, math.floor(data.altitude + 0.5), SMLSIZE + RIGHT + data.telemFlags)

-- Variometer
if config[7].v == 1 then
	if SMLCD then
		lcd.drawLine(RIGHT_POS, 7, RIGHT_POS, 63, SOLID, FORCE)
	else
		lcd.drawRectangle(RIGHT_POS, 7, SMLCD and 4 or 6, 57, SOLID, FORCE)
	end
	if config[7].v == 1 then
		local varioSpeed = math.log(1 + math.min(math.abs(0.9 * (data.vspeed_unit == 6 and data.vspeed / 3.28084 or data.vspeed)), 10)) / 2.4 * (data.vspeed < 0 and -1 or 1)
		if data.armed then
			tmp = 35 - math.floor(varioSpeed * 27 - 0.5)
			if tmp > 35 then
				lcd.drawFilledRectangle(RIGHT_POS + 1, 35, SMLCD and 2 or 4, tmp - 35, FORCE)
			else
				lcd.drawFilledRectangle(RIGHT_POS + 1, tmp - 1, SMLCD and 2 or 4, 35 - tmp + 2, FORCE + (SMLCD and 0 or GREY_DEFAULT))
			end
		end
	end
else
	lcd.drawLine(RIGHT_POS, 8, RIGHT_POS, 63, SOLID, FORCE)
end

-- GPS
local gpsFlags = SMLSIZE + RIGHT + ((data.telemFlags > 0 or not data.gpsFix) and FLASH or 0)
tmp = LCD_W + (data.telemFlags == 0 and 1 or 0)
gpsIcon(LCD_W - 18, 9)
lcd.drawText(LCD_W + (data.telemFlags == 0 and 1 or 0), 9, data.satellites % 100, SMLSIZE + RIGHT + data.telemFlags)
hdopGraph(SMLCD and LCD_W - 12 or LCD_W - 33, SMLCD and 18 or 9)
lcd.drawText(tmp, SMLCD and 27 or 17, math.floor(data.gpsAlt + 0.5) .. units[data.gpsAlt_unit], gpsFlags)
if not SMLCD or data.showDir then
	lcd.drawText(SMLCD and RIGHT_POS + (bit32.band(gpsFlags, FLASH) ~= FLASH and 1 or 0) or tmp, SMLCD and 41 or 25, config[16].v == 0 and string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), gpsFlags + ((SMLCD and bit32.band(gpsFlags, FLASH) ~= FLASH) and INVERS or 0))
	lcd.drawText(SMLCD and RIGHT_POS + (bit32.band(gpsFlags, FLASH) ~= FLASH and 1 or 0) or tmp, SMLCD and 48 or 33, config[16].v == 0 and string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), gpsFlags + ((SMLCD and bit32.band(gpsFlags, FLASH) ~= FLASH) and INVERS or 0))
end

-- Other data
if SMLCD then
	lcd.drawLine(RIGHT_POS + 3, 35, LCD_W, 35, SOLID, FORCE)
	lcd.drawText(tmp, data.showCurr and 39 or 41, data.distanceLast .. units[data.distance_unit], (data.showCurr and SMLSIZE or 0) + RIGHT + data.telemFlags)
	if data.showCurr then
		lcd.drawText(tmp, 48, string.format("%.1f", data.current) .. "A", SMLSIZE + RIGHT + data.telemFlags)
	end
	lcd.drawText(tmp, data.showCurr and 57 or 54, data.rssiLast .. "dB", (data.showCurr and SMLSIZE or 0) + RIGHT + ((data.telemFlags > 0 or data.rssi < data.rssiLow) and FLASH or 0))
else
	lcd.drawText(RIGHT_POS + 8, 45, "C:", SMLSIZE)
	lcd.drawText(LCD_W - 10, 40, data.current >= 99.5 and math.floor(data.current + 0.5) or string.format("%.1f", data.current), MIDSIZE + RIGHT + data.telemFlags)
	lcd.drawText(LCD_W - 4, 45, "A", SMLSIZE + RIGHT + data.telemFlags)
	lcd.drawText(RIGHT_POS + 8, 57, "RSSI", SMLSIZE)
	lcd.drawText(LCD_W - 10, 52, math.min(data.rssiLast, 99), MIDSIZE + RIGHT + data.telemFlags)
	lcd.drawText(tmp, 57, "dB", SMLSIZE + RIGHT + data.telemFlags)
end

return 0