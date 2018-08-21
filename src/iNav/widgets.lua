local data, config, SMLCD, FLASH = ...

local function gpsDegMin(coord, lat)
	local gpsD = math.floor(math.abs(coord))
	return gpsD .. string.format("\64%05.2f", (math.abs(coord) - gpsD) * 60) .. (lat and (coord >= 0 and "N" or "S") or (coord >= 0 and "E" or "W"))
end

local function gpsIcon(x, y)
	lcd.drawLine(x + 1, y, x + 5, y + 4, SOLID, 0)
	lcd.drawLine(x + 1, y + 1, x + 4, y + 4, SOLID, 0)
	lcd.drawLine(x + 1, y + 2, x + 3, y + 4, SOLID, 0)
	lcd.drawLine(x, y + 5, x + 2, y + 5, SOLID, 0)
	lcd.drawPoint(x + 4, y + 1)
	lcd.drawPoint(x + 1, y + 4)
end

local function lockIcon(x, y)
	lcd.drawFilledRectangle(x, y + 2, 5, 4, 0)
	lcd.drawLine(x + 1, y, x + 3, y, SOLID, 0)
	lcd.drawPoint(x + 1, y + 1)
	lcd.drawPoint(x + 3, y + 1)
	lcd.drawPoint(x + 2, y + 3, ERASE)
end

local function homeIcon(x, y)
	lcd.drawPoint(x + 3, y - 1)
	lcd.drawLine(x + 2, y, x + 4, y, SOLID, 0)
	lcd.drawLine(x + 1, y + 1, x + 5, y + 1, SOLID, 0)
	lcd.drawLine(x, y + 2, x + 6, y + 2, SOLID, 0)
	lcd.drawLine(x + 1, y + 3, x + 1, y + 5, SOLID, 0)
	lcd.drawLine(x + 5, y + 3, x + 5, y + 5, SOLID, 0)
	lcd.drawLine(x + 2, y + 5, x + 4, y + 5, SOLID, 0)
	lcd.drawPoint(x + 3, y + 4)
end

local function hdopGraph(x, y, size)
	local tmp = ((data.armed or data.modeId == 6) and data.hdop < 11 - config[21].v * 2) or not data.telemetry
	if config[22].v == 0 then
		if tmp then
			lcd.drawText(x, y, "    ", SMLSIZE + FLASH)
		end
		for i = 4, 9 do
			lcd.drawLine(x - 8 + (i * 2), (data.hdop >= i or not SMLCD) and y + 8 - i or y + 5, x - 8 + (i * 2), y + 5, SOLID, (data.hdop >= i or SMLCD) and 0 or GREY_DEFAULT)
		end
	else
		lcd.drawText(x + 12, size == SMLSIZE and y or y - 2, (data.hdop == 0 and not data.gpsFix) and "--" or (9 - data.hdop) / 2 + 0.8, size + RIGHT + (tmp and FLASH or 0))
	end
end

return gpsDegMin, gpsIcon, lockIcon, homeIcon, hdopGraph