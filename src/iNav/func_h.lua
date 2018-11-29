local config, data, FILE_PATH = ...

local function title(data, config, SMLCD)
	lcd.setColor(TEXT_COLOR, BLACK)
	lcd.drawFilledRectangle(0, 0, LCD_W, 20)
	lcd.setColor(TEXT_COLOR, WHITE)
	lcd.drawText(0, 0, model.getInfo().name)
	if config[13].v > 0 then
		lcd.drawTimer(340, 0, data.timer)
	end
	if config[19].v > 0 then
		lcd.drawFilledRectangle(197, 3, 43, 14)
		lcd.drawFilledRectangle(240, 6, 2, 8)
		tmp = math.max(math.min((data.txBatt - data.txBattMin) / (data.txBattMax - data.txBattMin) * 42, 42), 0) + 197
		lcd.setColor(TEXT_COLOR, BLACK)
		for i = 200, tmp, 4 do
			lcd.drawLine(i, 4, i, 15, SOLID, 0)
		end
		lcd.setColor(TEXT_COLOR, WHITE)
	end
	if config[19].v ~= 1 then
		lcd.drawText(290, 0, string.format("%.1f", data.txBatt) .. "V", RIGHT)
	end
	if data.rxBatt > 0 and data.telem and config[14].v == 1 then
		lcd.drawText(LCD_W, 0, string.format("%.1f", data.rxBatt) .. "V", RIGHT)
	end

	-- Show FPS
	data.frames = data.frames + 1
	lcd.drawText(180, 0, string.format("%.1f", data.frames / (getTime() - data.fpsStart) * 100), RIGHT)

end

local function gpsDegMin(c, lat)
	local gpsD = math.floor(math.abs(c))
	local gpsM = math.floor((math.abs(c) - gpsD) * 60)
	return string.format("%d\64%d'%05.2f", gpsD, gpsM, ((math.abs(c) - gpsD) * 60 - gpsM) * 60) .. "\"" .. (lat and (c >= 0 and "N" or "S") or (c >= 0 and "E" or "W"))
end

local function hdopGraph(x, y)
	for i = 4, 9 do
		if data.hdop < i then
			lcd.setColor(CUSTOM_COLOR, GREY)
		end
		lcd.drawRectangle(i * 4 + x - 16, y, 2, -i * 3 + 10, CUSTOM_COLOR)
	end
end

local gpsIcon = Bitmap.open(FILE_PATH .. "pics/bg.png")
local lockIcon = Bitmap.open(FILE_PATH .. "pics/lock.png")
local homeIcon = Bitmap.open(FILE_PATH .. "pics/home.png")
local attOverlay = Bitmap.open(FILE_PATH .. "pics/air2.png")

return title, gpsDegMin, gpsIcon, lockIcon, homeIcon, hdopGraph, attOverlay