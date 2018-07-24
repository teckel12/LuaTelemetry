local data, config, modes, units, gpsDegMin, gpsIcon, lockIcon, hdopGraph, VERSION, SMLCD, FLASH = ...

local LEFT_POS = SMLCD and 0 or 52
local RIGHT_POS = SMLCD and LCD_W - 40 or LCD_W - 52
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
			lcd.drawLine(x, math.min(math.max(y, miny), 55), x, 55, SOLID, SMLCD and 0 or GREY_DEFAULT)
			y = y + a1
		end
	else
		lcd.drawLine(x1, y1, x2, y2, SMLCD and DOTTED or (pitchAdj % 10 == 0 and SOLID or DOTTED), SMLCD and 0 or (pitchAdj > 0 and GREY_DEFAULT or 0))
	end
	if pitchAdj % 10 == 0 and pitchAdj ~= 0 and y2 > 15 and y2 < 58 then
		lcd.drawText(x2 - 1, y2 - 3, math.abs(pitchAdj), SMLSIZE + RIGHT + (pitchAdj < 0 and INVERS or 0))
	end
end

-- Startup message
if data.startup == 2 then
	lcd.drawText(X_CNTR - 12, 32, "v" .. VERSION)
end

-- Orientation
if data.telemetry and data.headingRef >= 0 then
	local width = 145
	local radius = SMLCD and 7 or 8
	local x = LEFT_POS + (SMLCD and 12 or 13)
	local y = SMLCD and 22 or 20

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
		lcd.drawFilledRectangle((x2 + x3) / 2 - 1, (y2 + y3) / 2 - 1, 3, 3, SOLID)
	end
end

-- Attitude
if data.startup == 0 then
	if data.telemetry then
		local pitch = 90 - math.deg(math.atan2(-data.accx, (math.sqrt((data.accy * data.accy) + (data.accz * data.accz)))))
		local roll = 90 - math.deg(math.atan2(data.accy, (math.sqrt((data.accx * data.accx) + (data.accz * data.accz)))))
		attitude(pitch, roll, 200, 0)
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
	lcd.drawLine(X_CNTR - 17, 35, X_CNTR - 6, 35, SOLID, SMLCD and 0 or FORCE)
	lcd.drawLine(X_CNTR + 17, 35, X_CNTR + 6, 35, SOLID, SMLCD and 0 or FORCE)
	lcd.drawLine(X_CNTR - 1, 35, X_CNTR + 1, 35, SOLID, SMLCD and 0 or FORCE)
	lcd.drawPoint(X_CNTR, 34, SMLCD and 0 or FORCE)
	lcd.drawPoint(X_CNTR, 36, SMLCD and 0 or FORCE)
end

-- Flight modes
tmp = X_CNTR - (SMLCD and 16 or 19)
--lcd.drawLine(LEFT_POS, 8, RIGHT_POS, 8, SOLID, ERASE)
lcd.drawLine(tmp, 9, tmp, 15, SOLID, ERASE)
lcd.drawText(tmp + 1, 9, modes[data.modeId].t, SMLSIZE + modes[data.modeId].f)
if data.headFree then
	lcd.drawText(tmp, 9, "HF", SMLSIZE + FLASH + RIGHT)
end
if data.altHold and (not SMLCD or not data.showDir) then
	lockIcon(RIGHT_POS - 8, 24)
end

-- Speed
for i = data.speed % 10 + 8, 56, 10 do
	if i < 31 or i > 41 then
		lcd.drawLine(LEFT_POS + 1, i, LEFT_POS + 2, i, SOLID, 0)
	end
end
lcd.drawLine(LEFT_POS, 32, LEFT_POS + 18, 32, SOLID, ERASE)
lcd.drawText(LEFT_POS + 1, 33, "      ", SMLSIZE + data.telemFlags)
lcd.drawRectangle(LEFT_POS, 31, 20, 10, FORCE)
lcd.drawText(LEFT_POS + 19, 33, data.speed >= 99.5 and math.floor(data.speed + 0.5) or string.format("%.1f", data.speed), SMLSIZE + RIGHT + data.telemFlags)
--lcd.drawText(LEFT_POS + 4, 42, units[data.speed_unit], SMLSIZE)

-- Altitude
if not SMLCD or not data.showDir then
	for i = data.altitude % 10 + 8, 56, 10 do
		if i < 31 or i > 41 then
			lcd.drawLine(RIGHT_POS - 2, i, RIGHT_POS - 1, i, SOLID, 0)
		end
	end
end
lcd.drawLine( RIGHT_POS - 21, 32, RIGHT_POS, 32, SOLID, ERASE)
lcd.drawText(RIGHT_POS - 21, 33, "       ", SMLSIZE + data.telemFlags)
lcd.drawRectangle(RIGHT_POS - 22, 31, 23, 10, FORCE)
lcd.drawText(RIGHT_POS, 33, math.floor(data.altitude + 0.5), SMLSIZE + RIGHT + data.telemFlags)
--lcd.drawText(RIGHT_POS - 2, 24, "Alt", SMLSIZE + RIGHT)

-- Heading
lcd.drawFilledRectangle(LEFT_POS + 1, 55, RIGHT_POS - LEFT_POS, 9, ERASE)
lcd.drawLine(LEFT_POS + 1, 55, RIGHT_POS - 1, 55, SOLID, FORCE)
if data.showHead then
	for i = 0, 348.75, 11.25 do
		tmp = LEFT_POS + ((i - data.heading + 452) % 360) * PIXEL_DEG - 3
		if tmp >= LEFT_POS and tmp <= RIGHT_POS then
			if i % 90 == 0 then
				lcd.drawText(tmp - 2, 57, i == 0 and "N" or (i == 90 and "E" or (i == 180 and "S" or "W")), SMLSIZE)
			elseif i % 45 == 0 then
				lcd.drawText(tmp - 4, 57, i == 45 and "NE" or (i == 135 and "SE" or (i == 225 and "SW" or "NW")), SMLSIZE)
			elseif tmp < X_CNTR - 11 or tmp > X_CNTR + 10 then
				lcd.drawLine(tmp, 56, tmp, 57, SOLID, FORCE)
			end
		end
	end
	lcd.drawLine(X_CNTR - 11, 56, X_CNTR - 11, 63, SOLID, FORCE)
	lcd.drawLine(X_CNTR + 10, 56, X_CNTR + 10, 63, SOLID, FORCE)
	lcd.drawText(X_CNTR - 10, 57, "      ", SMLSIZE + data.telemFlags)
	lcd.drawText(X_CNTR + 10, 57, math.floor(data.heading + 0.5) % 360 .. "\64", SMLSIZE + RIGHT + data.telemFlags)
	lcd.drawFilledRectangle(RIGHT_POS, 55, 5, 9, ERASE)
	if not SMLCD then
		lcd.drawFilledRectangle(LEFT_POS - 5, 55, 5, 9, ERASE)
	end
end

-- Variometer
lcd.drawLine(LEFT_POS, 8, LEFT_POS, 63, SOLID, FORCE)
if config[7].v == 1 then
	lcd.drawRectangle(RIGHT_POS, 7, SMLCD and 4 or 6, 57, SOLID, FORCE)
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
if not SMLCD or data.showDir then
	local gpsFlags = SMLSIZE + RIGHT + ((data.telemFlags > 0 or not data.gpsFix) and FLASH or 0)
	tmp = LCD_W + (data.telemFlags == 0 and 1 or 0)
	hdopGraph(SMLCD and RIGHT_POS - 12 or LCD_W - 33, SMLCD and 17 or 9)
	gpsIcon(SMLCD and RIGHT_POS - 19 or LCD_W - 18, 9)
	lcd.drawText(SMLCD and RIGHT_POS or LCD_W + (data.telemFlags == 0 and 1 or 0), 9, data.satellites % 100, SMLSIZE + RIGHT + data.telemFlags)
	lcd.drawText(SMLCD and RIGHT_POS or tmp, SMLCD and 24 or 17, math.floor(data.gpsAlt + 0.5) .. units[data.gpsAlt_unit], gpsFlags)
	lcd.drawText(SMLCD and RIGHT_POS + (bit32.band(gpsFlags, FLASH) ~= FLASH and 1 or 0) or tmp, SMLCD and 41 or 25, config[16].v == 0 and string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), gpsFlags + ((SMLCD and bit32.band(gpsFlags, FLASH) ~= FLASH) and INVERS or 0))
	lcd.drawText(SMLCD and RIGHT_POS + (bit32.band(gpsFlags, FLASH) ~= FLASH and 1 or 0) or tmp, SMLCD and 48 or 33, config[16].v == 0 and string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), gpsFlags + ((SMLCD and bit32.band(gpsFlags, FLASH) ~= FLASH) and INVERS or 0))
end

--[[
drawData("Dist", data.distPos, 1, data.distanceLast, data.distanceMax, 10000, units[data.distance_unit], 0, data.telemFlags)
drawData(units[data.speed_unit], data.speedPos, 1, data.speed, data.speedMax, 1000, '', 0, data.telemFlags)
drawData("Batt", data.battPos1, 2, config[1].v == 0 and data.cell or data.batt, config[1].v == 0 and data.cellMin or data.battMin, 100, "V", config[1].v == 0 and "%.2f" or "%.1f", tmp, 1)
drawData("RSSI", 57, 2, data.rssiLast, data.rssiMin, 200, "dB", 0, (data.telemFlags > 0 or data.rssi < data.rssiLow) and FLASH or 0)
if data.showCurr then
	drawData("Curr", 33, 1, data.current, data.currentMax, 100, "A", "%.1f", data.telemFlags)
	drawData(config[23].v == 0 and "Fuel" or config[23].l[config[23].v], 41, 0, data.fuel, 0, 200, config[23].v == 0 and "%" or "", 0, tmp)
	if config[23].v == 0 then
		lcd.drawGauge(46, 41, GAUGE_WIDTH, 7, math.min(data.fuel, 98), 100)
		if data.fuel == 0 then
			lcd.drawLine(47, 42, 47, 46, SOLID, ERASE)
		end
	end
end
]]

return 0