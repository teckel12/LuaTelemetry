local config, data, 
FILE_PATH = ...

local function title(data, config, SMLCD)
	lcd.drawFilledRectangle(0, 0, LCD_W, 8, FORCE)
	lcd.drawText(0, 0, model.getInfo().name, INVERS)
	if config[13].v > 0 then
		lcd.drawTimer(SMLCD and 60 or 150, 1, data.timer, SMLSIZE + INVERS)
	end
	if config[19].v > 0 then
		lcd.drawFilledRectangle(86, 1, 19, 6, ERASE)
		lcd.drawLine(105, 2, 105, 5, SOLID, ERASE)
		tmp = math.max(math.min((data.txBatt - data.txBattMin) / (data.txBattMax - data.txBattMin) * 17, 17), 0) + 86
		for i = 87, tmp, 2 do
			lcd.drawLine(i, 2, i, 5, SOLID, FORCE)
		end
	end
	if config[19].v ~= 1 then
		lcd.drawText(SMLCD and (config[14].v == 1 and 105 or LCD_W) or 128, 1, string.format("%.1fV", data.txBatt), SMLSIZE + RIGHT + INVERS)
	end
	if data.rxBatt > 0 and data.telem and config[14].v == 1 then
		lcd.drawText(LCD_W, 1, string.format("%.1fV", data.rxBatt), SMLSIZE + RIGHT + INVERS)
	elseif data.crsf then
		lcd.drawText(LCD_W, 1, (getValue(data.rfmd_id) == 2 and 150 or (data.telem and 50 or "--")) .. (SMLCD and "" or "Hz"), SMLSIZE + RIGHT + INVERS)
	end

	--[[ Show FPS
	data.frames = data.frames + 1
	lcd.drawText(SMLCD and 57 or 80, 1, string.format("%.1f", data.frames / (getTime() - data.fpsStart) * 100), SMLSIZE + RIGHT + INVERS)
	]]
end

local function gpsDegMin(c, lat)
	local gpsD = math.floor(math.abs(c))
	return gpsD .. string.format("\64%05.2f", (math.abs(c) - gpsD) * 60) .. (lat and (c >= 0 and "N" or "S") or (c >= 0 and "E" or "W"))
end

local function hdopGraph(x, y, s, SMLCD)
	local tmp = ((data.armed or data.modeId == 6) and data.hdop < 11 - config[21].v * 2) or not data.telem
	if config[22].v == 0 then
		if tmp then
			lcd.drawText(x, y, "    ", SMLSIZE + 3)
		end
		for i = 4, 9 do
			lcd.drawLine(x - 8 + (i * 2), (data.hdop >= i or not SMLCD) and y + 8 - i or y + 5, x - 8 + (i * 2), y + 5, SOLID, (data.hdop >= i or SMLCD) and 0 or GREY_DEFAULT)
		end
	else
		lcd.drawText(x + 12, s == SMLSIZE and y or y - 2, (data.hdop == 0 and not data.gpsFix) and "--" or (9 - data.hdop) / 2 + 0.8, s + RIGHT + (tmp and 3 or 0))
	end
end

local icons = {}

function icons.gps(x, y)
	lcd.drawLine(x + 1, y, x + 5, y + 4, SOLID, 0)
	lcd.drawLine(x + 1, y + 1, x + 4, y + 4, SOLID, 0)
	lcd.drawLine(x + 1, y + 2, x + 3, y + 4, SOLID, 0)
	lcd.drawLine(x, y + 5, x + 2, y + 5, SOLID, 0)
	lcd.drawPoint(x + 4, y + 1)
	lcd.drawPoint(x + 1, y + 4)
end

function icons.lock(x, y)
	lcd.drawRectangle(x, y + 2, 5, 4, 0)
	lcd.drawRectangle(x + 1, y, 3, 5, FORCE)
end

function icons.home(x, y)
	lcd.drawPoint(x + 3, y - 1)
	lcd.drawLine(x + 2, y, x + 4, y, SOLID, 0)
	lcd.drawLine(x + 1, y + 1, x + 5, y + 1, SOLID, 0)
	lcd.drawLine(x, y + 2, x + 6, y + 2, SOLID, 0)
	lcd.drawLine(x + 1, y + 3, x + 1, y + 5, SOLID, 0)
	lcd.drawLine(x + 5, y + 3, x + 5, y + 5, SOLID, 0)
	lcd.drawLine(x + 2, y + 5, x + 4, y + 5, SOLID, 0)
	lcd.drawPoint(x + 3, y + 4)
end

return title, gpsDegMin, hdopGraph, icons, nil