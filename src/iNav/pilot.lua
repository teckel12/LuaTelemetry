local data, config, modes, units, gpsDegMin, VERSION, SMLCD, FLASH = ...

local RIGHT_POS = LCD_W - 20
local X_CNTR = RIGHT_POS / 2 - 2
local PIXEL_DEG = (RIGHT_POS - 14) / 180
local tmp

-- Startup message
if data.startup == 2 then
	if not SMLCD then
		lcd.drawText(53, 23, "INAV Lua Telemetry")
	end
	lcd.drawText(SMLCD and 42 or 84, SMLCD and 27 or 33, "v" .. VERSION)
end

-- Attitude
if data.startup == 0 then
	local pitch = math.deg(math.atan2(-data.accx, (math.sqrt((data.accy * data.accy) + (data.accz * data.accz)))))
	local roll = math.deg(math.atan2(data.accy, (math.sqrt((data.accx * data.accx) + (data.accz * data.accz)))))

	lcd.drawText(5, 9, math.floor(-pitch) .. "\64", SMLSIZE)

	local radius = 27
	local pitchRadius = 45

	local pitch1 = math.rad(90 - pitch)
	local p1 = 35 - math.floor(math.cos(pitch1) * pitchRadius + 0.5)

	local roll1 = math.rad(270 - roll)
	local x1 = math.floor(math.sin(roll1) * radius + 0.5) + X_CNTR
	local y1 = p1 - math.floor(math.cos(roll1) * radius + 0.5)

	local roll2 = math.rad(90 - roll)
	local x2 = math.floor(math.sin(roll2) * radius + 0.5) + X_CNTR
	local y2 = p1 - math.floor(math.cos(roll2) * radius + 0.5)

	lcd.drawLine(x1, y1, x2, y2, SMLCD and DOTTED or SOLID, SMLCD and 0 or GREY_DEFAULT)

	local radius = 5

	local pitch1 = math.rad(80 - pitch)
	local p1 = 35 - math.floor(math.cos(pitch1) * pitchRadius + 0.5)

	local roll1 = math.rad(270 - roll)
	local x1 = math.floor(math.sin(roll1) * radius + 0.5) + X_CNTR
	local y1 = p1 - math.floor(math.cos(roll1) * radius + 0.5)

	local roll2 = math.rad(90 - roll)
	local x2 = math.floor(math.sin(roll2) * radius + 0.5) + X_CNTR
	local y2 = p1 - math.floor(math.cos(roll2) * radius + 0.5)

	lcd.drawLine(x1, y1, x2, y2, SMLCD and DOTTED or SOLID, SMLCD and 0 or GREY_DEFAULT)

	local radius = 10

	local pitch1 = math.rad(70 - pitch)
	local p1 = 35 - math.floor(math.cos(pitch1) * pitchRadius + 0.5)

	local roll1 = math.rad(270 - roll)
	local x1 = math.floor(math.sin(roll1) * radius + 0.5) + X_CNTR
	local y1 = p1 - math.floor(math.cos(roll1) * radius + 0.5)

	local roll2 = math.rad(90 - roll)
	local x2 = math.floor(math.sin(roll2) * radius + 0.5) + X_CNTR
	local y2 = p1 - math.floor(math.cos(roll2) * radius + 0.5)

	lcd.drawLine(x1, y1, x2, y2, SMLCD and DOTTED or SOLID, SMLCD and 0 or GREY_DEFAULT)

	local radius = 5

	local pitch1 = math.rad(100 - pitch)
	local p1 = 35 - math.floor(math.cos(pitch1) * pitchRadius + 0.5)

	local roll1 = math.rad(270 - roll)
	local x1 = math.floor(math.sin(roll1) * radius + 0.5) + X_CNTR
	local y1 = p1 - math.floor(math.cos(roll1) * radius + 0.5)

	local roll2 = math.rad(90 - roll)
	local x2 = math.floor(math.sin(roll2) * radius + 0.5) + X_CNTR
	local y2 = p1 - math.floor(math.cos(roll2) * radius + 0.5)

	lcd.drawLine(x1, y1, x2, y2, SMLCD and DOTTED or SOLID, SMLCD and 0 or GREY_DEFAULT)

	local radius = 10

	local pitch1 = math.rad(110 - pitch)
	local p1 = 35 - math.floor(math.cos(pitch1) * pitchRadius + 0.5)

	local roll1 = math.rad(270 - roll)
	local x1 = math.floor(math.sin(roll1) * radius + 0.5) + X_CNTR
	local y1 = p1 - math.floor(math.cos(roll1) * radius + 0.5)

	local roll2 = math.rad(90 - roll)
	local x2 = math.floor(math.sin(roll2) * radius + 0.5) + X_CNTR
	local y2 = p1 - math.floor(math.cos(roll2) * radius + 0.5)

	lcd.drawLine(x1, y1, x2, y2, SMLCD and DOTTED or SOLID, SMLCD and 0 or GREY_DEFAULT)

	--local pitch = math.atan2(-data.accx, (math.sqrt((data.accy * data.accy) + (data.accz * data.accz)))) * 15
	--local roll = math.atan2(data.accy, (math.sqrt((data.accx * data.accx) + (data.accz * data.accz)))) * 15
	--lcd.drawLine(21, 35 + roll - pitch, RIGHT_POS - 24, 35 - roll - pitch, SMLCD and DOTTED or SOLID, SMLCD and 0 or GREY_DEFAULT)
--[[
	for i = 0, 54, 1 do
		local y1 = math.min(35 + roll - pitch + i, 54)
		local y2 = math.min(35 - roll - pitch + i, 54)
		lcd.drawLine(1, y1, RIGHT_POS - 1, y2, SOLID, GREY_DEFAULT + FORCE)
		if y1 + y2 == 108 then break end
	end
]]
	lcd.drawLine(X_CNTR - 20, 35, X_CNTR - 5, 35, SOLID, FORCE)
	lcd.drawLine(X_CNTR + 20, 35, X_CNTR + 5, 35, SOLID, FORCE)
	--lcd.drawLine(X_CNTR, 35, X_CNTR, 35, SOLID, FORCE)
	--lcd.drawFilledRectangle(X_CNTR - 1, 34, 3, 3, FORCE)
	lcd.drawLine(X_CNTR - 1, 35, X_CNTR + 1, 35, SOLID, FORCE)
	lcd.drawLine(X_CNTR, 34, X_CNTR, 36, SOLID, FORCE)
end

-- Flight modes
lcd.drawText(SMLCD and 37 or 77, 9, modes[data.modeId].t, SMLSIZE + modes[data.modeId].f)
if data.headFree then
	lcd.drawText(SMLCD and 35 or 75, 9, " HF ", SMLSIZE + FLASH + RIGHT)
end
if data.altHold then
	lcd.drawRectangle(RIGHT_POS - 21, 24, 3, 3, FORCE)
	lcd.drawFilledRectangle(RIGHT_POS - 22, 26, 5, 4, FORCE)
	lcd.drawPoint(RIGHT_POS - 20, 27)
end

-- Speed
lcd.drawLine(0, 8, 0, 54, SOLID, 0)
for i = data.speed % 10 + 8, 56, 10 do
	if i < 31 or i > 41 then
		lcd.drawLine(1, i, 2, i, SOLID, FORCE)
	end
end
--if data.telemFlags > 0 then
	lcd.drawText(1, 33, "      ", SMLSIZE + data.telemFlags)
--end
lcd.drawRectangle(0, 31, 20, 10, SOLID)
lcd.drawText(19, 33, data.speed >= 99.5 and math.floor(data.speed + 0.5) or string.format("%.1f", data.speed), SMLSIZE + RIGHT + data.telemFlags)
lcd.drawText(4, 24, units[data.speed_unit], SMLSIZE)

-- Altitude
for i = data.altitude % 10 + 8, 56, 10 do
	if i < 31 or i > 41 then
		lcd.drawLine(RIGHT_POS - 2, i, RIGHT_POS - 1, i, SOLID, FORCE)
	end
end
--if data.telemFlags > 0 then
	lcd.drawText(RIGHT_POS - 21, 33, "       ", SMLSIZE + data.telemFlags)
--end
lcd.drawRectangle(RIGHT_POS - 22, 31, 23, 10, SOLID)
lcd.drawText(RIGHT_POS, 33, math.floor(data.altitude + 0.5), SMLSIZE + RIGHT + data.telemFlags)
lcd.drawText(RIGHT_POS - 2, 24, "Alt", SMLSIZE + RIGHT)

-- Heading
lcd.drawLine(0, 55, RIGHT_POS - 1, 55, SOLID, FORCE)
if data.showHead then
	for i = 0, 345, SMLCD and 30 or 11.25 do
		tmp = ((i - data.heading + 450) % 360) * PIXEL_DEG + 5
		if tmp >= 0 and  tmp <= RIGHT_POS then
			if i % 90 == 0 then
				lcd.drawText(tmp - 2, 57, i == 0 and "N" or (i == 90 and "E" or (i == 180 and "S" or "W")), SMLSIZE)
			elseif not SMLCD and i % 45 == 0 then
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
end

-- Variometer
if config[7].v == 1 then
	lcd.drawRectangle(RIGHT_POS, 7, 4, 57, SOLID, FORCE)
	if config[7].v == 1 then
		local varioSpeed = math.log(1 + math.min(math.abs(0.1 * (data.vspeed_unit == 6 and data.vspeed / 3.28084 or data.vspeed)), 10)) / 2.4 * (data.vspeed < 0 and -1 or 1)
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
tmp = ((data.armed or data.modeId == 6) and data.hdop < 11 - config[21].v * 2) or not data.telemetry
lcd.drawText(RIGHT_POS - 3, 9, data.satellites % 100, SMLSIZE + RIGHT + data.telemFlags)
if config[22].v == 0 then
	if tmp then
		lcd.drawText(RIGHT_POS - 15, 17, "    ", SMLSIZE + FLASH)
	end
	for i = 4, 9 do
		lcd.drawLine(RIGHT_POS - (23 - (i * 2)), (data.hdop >= i or not SMLCD) and 25 - i or 22, RIGHT_POS - (23 - (i * 2)), 22, SOLID, (data.hdop >= i or SMLCD) and 0 or GREY_DEFAULT)
	end
else
	lcd.drawText(RIGHT_POS - 18, 9, (data.hdop == 0 and not data.gpsFix) and "--" or (9 - data.hdop) / 2 + 0.8, SMLSIZE + RIGHT + (tmp and FLASH or 0))
end
lcd.drawLine(RIGHT_POS - 20, 9, RIGHT_POS - 16, 13, SOLID, FORCE)
lcd.drawLine(RIGHT_POS - 20, 10, RIGHT_POS - 17, 13, SOLID, FORCE)
lcd.drawLine(RIGHT_POS - 20, 11, RIGHT_POS - 18, 13, SOLID, FORCE)
lcd.drawLine(RIGHT_POS - 21, 14, RIGHT_POS - 17, 10, SOLID, FORCE)
lcd.drawPoint(RIGHT_POS - 20, 14)
lcd.drawPoint(RIGHT_POS - 19, 14)

if data.showDir then
	lcd.drawText(SMLCD and X_CNTR - 2 or 48, 48, config[16].v == 0 and string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), gpsFlags)
	lcd.drawText(RIGHT_POS - 5, 48, config[16].v == 0 and string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), gpsFlags)
end

return 0