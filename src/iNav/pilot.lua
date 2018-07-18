local data, config, modes, units, gpsDegMin, VERSION, SMLCD, FLASH = ...

local RIGHT_POS = LCD_W - 20
local X_CNTR = RIGHT_POS / 2
local PIXEL_DEG = (RIGHT_POS - 14) / 180
local tmp

-- Startup message
if data.startup == 2 then
	if not SMLCD then
		lcd.drawText(53, 23, "INAV Lua Telemetry")
	end
	lcd.drawText(SMLCD and 42 or 84, SMLCD and 27 or 33, "v" .. VERSION)
end

lcd.drawRectangle(0, 7, RIGHT_POS + 1, 57, SOLID)

-- Artificial horizon
if data.startup == 0 then
	local pitch = math.atan2(-data.accx, (math.sqrt((data.accy * data.accy) + (data.accz * data.accz)))) * 16
	local roll = math.atan2(data.accy, (math.sqrt((data.accx * data.accx) + (data.accz * data.accz)))) * 16
	lcd.drawLine(21, 35 + roll - pitch, RIGHT_POS - 24, 35 - roll - pitch, SMLCD and DOTTED or SOLID, SMLCD and 0 or GREY_DEFAULT)
	lcd.drawLine(X_CNTR - 12, 35, X_CNTR - 3, 35, SOLID, FORCE)
	lcd.drawLine(X_CNTR + 12, 35, X_CNTR + 3, 35, SOLID, FORCE)
	lcd.drawLine(X_CNTR - 3, 35, X_CNTR - 3, 38, SOLID, FORCE)
	lcd.drawLine(X_CNTR + 3, 35, X_CNTR + 3, 38, SOLID, FORCE)
	lcd.drawLine(X_CNTR - 3, 38, X_CNTR + 3, 38, SOLID, FORCE)
end

-- Flight mode
lcd.drawText(SMLCD and 39 or 79, 9, modes[data.modeId].t, SMLSIZE + modes[data.modeId].f)
if data.headFree then
	lcd.drawText(SMLCD and 37 or 77, 9, " HF ", SMLSIZE + FLASH + RIGHT)
end
if data.altHold then
	lcd.drawRectangle(RIGHT_POS - 21, 24, 3, 3, FORCE)
	lcd.drawFilledRectangle(RIGHT_POS - 22, 26, 5, 4, FORCE)
	lcd.drawPoint(RIGHT_POS - 20, 27)
end

-- Speed
for i = data.speed % 10 + 8, 63, 10 do
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
for i = data.altitude % 10 + 8, 63, 10 do
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

-- Orientation
if data.showHead then
	for i = 0, 359, SMLCD and 22.5 or 11.25 do
		tmp = ((i - data.heading + 450) % 360) * PIXEL_DEG + 7
		if tmp >= 5 and  tmp <= RIGHT_POS - 7 then
			if i % 90 == 0 then
				lcd.drawText(tmp - 2, 56, i == 0 and "N" or (i == 90 and "E" or (i == 180 and "S" or "W")), SMLSIZE)
			elseif not SMLCD and i % 45 == 0 then
				lcd.drawText(tmp - 5, 56, i == 45 and "NE" or (i == 135 and "SE" or (i == 225 and "SW" or "NW")), SMLSIZE)
			else
				lcd.drawLine(tmp, 61, tmp, 62, SOLID, FORCE)
			end
		end
	end
	lcd.drawRectangle(X_CNTR - 11, 54, 22, 9, SOLID)
	lcd.drawText(X_CNTR - 10, 56, "      ", SMLSIZE + data.telemFlags)
	lcd.drawText(X_CNTR + 10, 56, math.floor(data.heading + 0.5) .. "\64", SMLSIZE + RIGHT + data.telemFlags)
end

-- Variometer
if config[7].v == 1 then
	lcd.drawLine(RIGHT_POS + 3, 8, RIGHT_POS + 3, 63, SOLID, FORCE)
	lcd.drawLine(RIGHT_POS + 1, 63, RIGHT_POS + 2, 63, SOLID, FORCE)
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

-- GPS
local gpsFlags = SMLSIZE + RIGHT + ((data.telemFlags > 0 or not data.gpsFix) and FLASH or 0)
tmp = ((data.armed or data.modeId == 6) and data.hdop < 11 - config[21].v * 2) or not data.telemetry
lcd.drawText(RIGHT_POS - 2, 9, data.satellites % 100, SMLSIZE + RIGHT + data.telemFlags)
if config[22].v == 0 then
	if tmp then
		lcd.drawText(RIGHT_POS - 16, 17, "    ", SMLSIZE + FLASH)
	end
	for i = 4, 9 do
		lcd.drawLine(RIGHT_POS - (24 - (i * 2)), (data.hdop >= i or not SMLCD) and 25 - i or 22, RIGHT_POS - (24 - (i * 2)), 22, SOLID, (data.hdop >= i or SMLCD) and 0 or GREY_DEFAULT)
	end
else
	lcd.drawText(RIGHT_POS - 18, 9, (data.hdop == 0 and not data.gpsFix) and "--" or (9 - data.hdop) / 2 + 0.8, SMLSIZE + RIGHT + (tmp and FLASH or 0))
end
lcd.drawLine(RIGHT_POS - 18, 9, RIGHT_POS - 14, 13, SOLID, FORCE)
lcd.drawLine(RIGHT_POS - 18, 10, RIGHT_POS - 15, 13, SOLID, FORCE)
lcd.drawLine(RIGHT_POS - 18, 11, RIGHT_POS - 16, 13, SOLID, FORCE)
lcd.drawLine(RIGHT_POS - 19, 14, RIGHT_POS - 15, 10, SOLID, FORCE)
lcd.drawPoint(RIGHT_POS - 18, 14)
lcd.drawPoint(RIGHT_POS - 17, 14)

if data.showDir then
	lcd.drawText(SMLCD and X_CNTR - 2 or 48, 47, config[16].v == 0 and string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), gpsFlags)
	lcd.drawText(RIGHT_POS - 5, 47, config[16].v == 0 and string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), gpsFlags)
end

return 0