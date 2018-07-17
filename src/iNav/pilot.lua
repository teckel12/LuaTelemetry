local data, config, modes, units, event, gpsDegMin, SMLCD, FLASH, PREV, INCR, NEXT, DECR = ...

local RIGHT_POS = LCD_W - 20
local X_CNTR = RIGHT_POS / 2
local PIXEL_DEG = (RIGHT_POS - 14) / 180

local function getTelemetryId(name)
	local field = getFieldInfo(name)
	return field and field.id or -1
end

data.accx_id = getTelemetryId("AccX")
data.accy_id = getTelemetryId("AccY")
data.accz_id = getTelemetryId("AccZ")
data.accx = getValue(data.accx_id)
data.accy = getValue(data.accy_id)
data.accz = getValue(data.accz_id)

local roll = math.atan2(-data.accx, (math.sqrt((data.accy * data.accy) + (data.accz * data.accz))))
local pitch = math.atan2(data.accy, (math.sqrt((data.accx * data.accx) + (data.accz * data.accz))))

lcd.drawLine(20, 35 - (roll * 14) + (pitch * 14), RIGHT_POS - 24, 35 + (roll * 14) + (pitch * 14), SOLID, FORCE)

--lcd.drawText(30, 20, roll, SMLSIZE)
--lcd.drawText(30, 28, pitch, SMLSIZE)

-- Flight mode
lcd.drawText(SMLCD and 36 or 83, 9, modes[data.modeId].t, SMLSIZE + modes[data.modeId].f)
if data.headFree then
	lcd.drawText(10, 9, " HF ", FLASH)
end
if data.altHold then
	lcd.drawRectangle(RIGHT_POS - 8, 9, 3, 3, FORCE)
	lcd.drawFilledRectangle(RIGHT_POS - 9, 11, 5, 4, FORCE)
	lcd.drawPoint(RIGHT_POS - 7, 12)
end

-- Speed
for i = data.speed % 10 + 8, 63, 10 do
	if i < 31 or i > 41 then
		lcd.drawLine(0, i, 2, i, SOLID, FORCE)
	end
end
lcd.drawRectangle(0, 31, 19, 10, SOLID)
lcd.drawLine(0, 32, 0, 39, SOLID, ERASE)
lcd.drawText(18, 33, data.speed >= 99.5 and math.floor(data.speed + 0.5) or string.format("%.1f", data.speed), SMLSIZE + RIGHT + data.telemFlags)
lcd.drawText(4, 24, units[data.speed_unit], SMLSIZE)

-- Altitude
for i = data.altitude % 10 + 8, 63, 10 do
	if i < 31 or i > 41 then
		lcd.drawLine(RIGHT_POS - 3, i, RIGHT_POS - 1, i, SOLID, FORCE)
	end
end
lcd.drawRectangle(RIGHT_POS - 22, 31, 23, 10, SOLID)
lcd.drawText(RIGHT_POS, 33, math.floor(data.altitude + 0.5), SMLSIZE + RIGHT + data.telemFlags)
lcd.drawText(RIGHT_POS - 3, 24, "Alt", SMLSIZE + RIGHT)

-- Orientation
for i = 0, 337.5, 22.5 do
	local tmp = ((i - data.heading + 450) % 360) * PIXEL_DEG + 7
	if tmp >= 5 and  tmp <= RIGHT_POS - 7 then
		if i % 90 == 0 then
			lcd.drawText(tmp - 2, 58, i == 0 and "N" or (i == 90 and "E" or (i == 180 and "S" or "W")), SMLSIZE)
		else
			lcd.drawLine(tmp, 61, tmp, 63, SOLID, FORCE)
		end
	end
end
lcd.drawRectangle(X_CNTR - 11, 56, 22, 9, SOLID)
lcd.drawFilledRectangle(X_CNTR - 10, 57, 20, 8, ERASE)
lcd.drawText(X_CNTR + 10, 58, math.floor(data.heading + 0.5) .. "\64", SMLSIZE + RIGHT + data.telemFlags)
lcd.drawLine(RIGHT_POS, 8, RIGHT_POS, 63, SOLID, FORCE)

-- Variometer
if config[7].v == 1 then
	lcd.drawLine(RIGHT_POS + 3, 8, RIGHT_POS + 3, 63, SOLID, FORCE)
	local varioSpeed = math.log(1 + math.min(math.abs(0.1 * (data.vspeed_unit == 6 and data.vspeed / 3.28084 or data.vspeed)), 10)) / 2.4 * (data.vspeed < 0 and -1 or 1)
	if data.armed then
		local tmp = 35 - math.floor(varioSpeed * 28 - 0.5)
		if tmp > 35 then
			lcd.drawFilledRectangle(RIGHT_POS + 1, 35, 2, tmp - 35, INVERS)
		else
			lcd.drawFilledRectangle(RIGHT_POS + 1, tmp - 1, 2, 35 - tmp + 2, INVERS)
		end
	end
end

-- GPS
local gpsFlags = SMLSIZE + RIGHT + ((data.telemFlags > 0 or not data.gpsFix) and FLASH or 0)
if config[22].v == 0 then
	if tmp then
		lcd.drawText(RIGHT_POS - 32, 9, "    ", SMLSIZE + FLASH)
	end
	for i = 4, 9 do
		lcd.drawLine(RIGHT_POS - (40 - (i * 2)), (data.hdop >= i or not SMLCD) and 17 - i or 14, RIGHT_POS - (40 - (i * 2)), 14, SOLID, (data.hdop >= i or SMLCD) and 0 or GREY_DEFAULT)
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
lcd.drawText(RIGHT_POS - (data.telemFlags == 0 and 3 or 2), 9, data.satellites % 100, SMLSIZE + RIGHT + data.telemFlags)
-- These will be part of rotation
lcd.drawText(X_CNTR - 1, 49, config[16].v == 0 and string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lat) or gpsDegMin(data.gpsLatLon.lat, true), gpsFlags)
lcd.drawText(RIGHT_POS - 5, 49, config[16].v == 0 and string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lon) or gpsDegMin(data.gpsLatLon.lon, false), gpsFlags)

return 0