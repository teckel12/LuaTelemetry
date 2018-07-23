local data, config, modes, units, gpsDegMin, gpsIcon, lockIcon, hdopGraph, VERSION, SMLCD, FLASH = ...

local LEFT_POS = SMLCD and 0 or 52
local RIGHT_POS = SMLCD and LCD_W - 40 or LCD_W - 52
local X_CNTR = (RIGHT_POS + LEFT_POS) / 2 - 2
local PIXEL_DEG = (RIGHT_POS - LEFT_POS - 20) / 90
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
		lcd.drawLine(x1, y1, x2, y2, SMLCD and DOTTED or (pitchAdj % 10 == 0 and SOLID or DOTTED), SMLCD and 0 or GREY_DEFAULT)
	end
	--[[ Helpful?
	if pitchAdj % 10 == 0 and pitchAdj ~= 0 and y2 > 15 and y2 < 58 then
		lcd.drawText(x2 - 1, y2 - 3, pitchAdj, SMLSIZE + RIGHT + (pitchAdj < 0 and INVERS or 0))
	end
	]]
end

-- Startup message
if data.startup == 2 then
	lcd.drawText(X_CNTR - 12, 32, "v" .. VERSION)
end

-- Attitude
if data.startup == 0 then
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
	--[[ Pitch greater than 20 degrees?
	if tmp >= 10 then
		attitude(pitch, roll, 5, 25, true)
		attitude(pitch, roll, 10, 30, true)
	elseif tmp <= -10 then
		attitude(pitch, roll, 5, -25, false)
		attitude(pitch, roll, 10, -30, false)
	end
	]]
	lcd.drawLine(X_CNTR - 20, 35, X_CNTR - 6, 35, SOLID, 0)
	lcd.drawLine(X_CNTR + 20, 35, X_CNTR + 6, 35, SOLID, 0)
	lcd.drawLine(X_CNTR - 1, 35, X_CNTR + 1, 35, SOLID, 0)
	lcd.drawPoint(X_CNTR, 34)
	lcd.drawPoint(X_CNTR, 36)
end

-- Flight modes
tmp = X_CNTR - (SMLCD and 16 or 19)
--lcd.drawLine(LEFT_POS, 8, RIGHT_POS, 8, SOLID, ERASE)
lcd.drawLine(tmp, 9, tmp, 15, SOLID, ERASE)
lcd.drawText(tmp + 1, 9, modes[data.modeId].t, SMLSIZE + modes[data.modeId].f)
if data.headFree then
	lcd.drawText(tmp, 9, " HF ", SMLSIZE + FLASH + RIGHT)
end
if data.altHold then lockIcon(RIGHT_POS - 22, 24) end

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
for i = data.altitude % 10 + 8, 56, 10 do
	if i < 31 or i > 41 then
		lcd.drawLine(RIGHT_POS - 2, i, RIGHT_POS - 1, i, SOLID, 0)
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
		tmp = ((i - data.heading + 414) % 360) * PIXEL_DEG + 5
		if tmp >= LEFT_POS and  tmp <= RIGHT_POS then
			if i % 90 == 0 then
				lcd.drawText(tmp - 2, 57, i == 0 and "N" or (i == 90 and "E" or (i == 180 and "S" or "W")), SMLSIZE)
			elseif i % 45 == 0 then
				lcd.drawText(tmp - 5, 57, i == 45 and "NE" or (i == 135 and "SE" or (i == 225 and "SW" or "NW")), SMLSIZE)
			elseif tmp < X_CNTR - 11 or tmp > X_CNTR + 10 then
				lcd.drawLine(tmp, 56, tmp, 57, SOLID, FORCE)
			end
		end
	end
	lcd.drawLine(X_CNTR - 11, 56, X_CNTR - 11, 63, SOLID, FORCE)
	lcd.drawLine(X_CNTR + 10, 56, X_CNTR + 10, 63, SOLID, FORCE)
	lcd.drawText(X_CNTR - 10, 57, "      ", SMLSIZE + data.telemFlags)
	lcd.drawText(X_CNTR + 10, 57, math.floor(data.heading + 0.5) .. "\64", SMLSIZE + RIGHT + data.telemFlags)
	lcd.drawFilledRectangle(RIGHT_POS, 55, 5, 9, ERASE)
	if not SMLCD then
		lcd.drawFilledRectangle(LEFT_POS - 5, 55, 5, 9, ERASE)
	end
end

-- Variometer
lcd.drawLine(LEFT_POS, 8, LEFT_POS, 63, SOLID, FORCE)
if config[7].v == 1 then
	lcd.drawRectangle(RIGHT_POS, 7, 4, 57, SOLID, FORCE)
	if config[7].v == 1 then
		local varioSpeed = math.log(1 + math.min(math.abs(0.9 * (data.vspeed_unit == 6 and data.vspeed / 3.28084 or data.vspeed)), 10)) / 2.4 * (data.vspeed < 0 and -1 or 1)
		if data.armed then
			tmp = 35 - math.floor(varioSpeed * 27 - 0.5)
			if tmp > 35 then
				lcd.drawFilledRectangle(RIGHT_POS + 1, 35, 2, tmp - 35, INVERS)
			else
				lcd.drawFilledRectangle(RIGHT_POS + 1, tmp - 1, 2, 35 - tmp + 2, INVERS)
			end
		end
	end
else
	lcd.drawLine(RIGHT_POS, 8, RIGHT_POS, 63, SOLID, FORCE)
end

-- GPS
local gpsFlags = SMLSIZE + RIGHT + ((data.telemFlags > 0 or not data.gpsFix) and FLASH or 0)
tmp = LCD_W + (data.telemFlags == 0 and 1 or 0)
hdopGraph(SMLCD and RIGHT_POS - 15 or LCD_W - 33, SMLCD and 17 or 9)
gpsIcon(SMLCD and RIGHT_POS - 21 or LCD_W - 18, 9)
lcd.drawText(SMLCD and RIGHT_POS - 3 or LCD_W + (data.telemFlags == 0 and 1 or 0), 9, data.satellites % 100, SMLSIZE + RIGHT + data.telemFlags)
if not SMLCD or data.showDir then
	lcd.drawText(SMLCD and RIGHT_POS - 16 or tmp, SMLCD and 17 or 17, math.floor(data.gpsAlt + 0.5) .. units[data.gpsAlt_unit], gpsFlags)
	lcd.drawText(SMLCD and RIGHT_POS - 3 or tmp, SMLCD and 41 or 25, config[16].v == 0 and string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), gpsFlags)
	lcd.drawText(SMLCD and RIGHT_POS - 3 or tmp, SMLCD and 48 or 33, config[16].v == 0 and string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), gpsFlags)
end

return 0