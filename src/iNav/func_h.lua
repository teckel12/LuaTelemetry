local config, data, FILE_PATH = ...

local function title(data, config, SMLCD)
	--lcd.setColor(CUSTOM_COLOR, BLACK)
	--lcd.drawFilledRectangle(0, 0, LCD_W, 20, CUSTOM_COLOR)
	lcd.drawText(0, 0, model.getInfo().name)
	if config[13].v > 0 then
		lcd.drawTimer(340, 0, data.timer)
	end
	if config[19].v > 0 then
		lcd.setColor(CUSTOM_COLOR, WHITE)
		lcd.drawFilledRectangle(197, 3, 43, 14, CUSTOM_COLOR)
		lcd.drawFilledRectangle(240, 6, 2, 8, CUSTOM_COLOR)
		tmp = math.max(math.min((data.txBatt - data.txBattMin) / (data.txBattMax - data.txBattMin) * 42, 42), 0) + 197
		lcd.setColor(CUSTOM_COLOR, BLACK)
		for i = 200, tmp, 4 do
			lcd.drawLine(i, 4, i, 15, SOLID, CUSTOM_COLOR)
		end
	end
	if config[19].v ~= 1 then
		lcd.drawText(290, 0, string.format("%.1fV", data.txBatt), RIGHT)
	end
	if data.rxBatt > 0 and data.telem and config[14].v == 1 then
		lcd.drawText(LCD_W, 0, string.format("%.1fV", data.rxBatt), RIGHT)
	end

	-- Show FPS
	data.frames = data.frames + 1
	lcd.drawText(180, 0, string.format("%.1f", data.frames / (getTime() - data.fpsStart) * 100), RIGHT)

end

local function gpsDegMin(c, lat)
	local gpsD = math.floor(math.abs(c))
	local gpsM = math.floor((math.abs(c) - gpsD) * 60)
	return string.format("%d\64%d'%05.2f\"", gpsD, gpsM, ((math.abs(c) - gpsD) * 60 - gpsM) * 60) .. (lat and (c >= 0 and "N" or "S") or (c >= 0 and "E" or "W"))
end

local function hdopGraph(x, y)
	lcd.setColor(CUSTOM_COLOR, data.hdop < 11 - config[21].v * 2 and YELLOW or WHITE)
	for i = 4, 9 do
		if i > data.hdop then
			lcd.setColor(CUSTOM_COLOR, GREY)
		end
		lcd.drawRectangle(i * 4 + x - 16, y, 2, -i * 3 + 10, CUSTOM_COLOR)
	end
end

local icons = {}

icons.lock = Bitmap.open(FILE_PATH .. "pics/lock.png")
icons.home = Bitmap.open(FILE_PATH .. "pics/home.png")
icons.bg = Bitmap.open(FILE_PATH .. "pics/bg.png")
icons.fg = Bitmap.open(FILE_PATH .. "pics/fg3.png")

return title, gpsDegMin, hdopGraph, icons