local function title(data, config, SMLCD)
	lcd.setColor(TEXT_COLOR, BLACK)
	lcd.drawFilledRectangle(0, 0, LCD_W, 20)
	lcd.setColor(TEXT_COLOR, WHITE)
	lcd.drawText(0, 0, model.getInfo().name)
	if config[13].v > 0 then
		lcd.drawTimer(340, 0, data.timer)
	end
	if config[19].v > 0 then
		lcd.drawFilledRectangle(196, 3, 44, 14)
		lcd.drawFilledRectangle(240, 6, 2, 8)
		tmp = math.max(math.min((data.txBatt - data.txBattMin) / (data.txBattMax - data.txBattMin) * 42, 42), 0) + 195
		lcd.setColor(TEXT_COLOR, BLACK)
		for i = 198, tmp, 3 do
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
	lcd.drawText(180, 1, string.format("%.1f", data.frames / (getTime() - data.fpsStart) * 100), RIGHT)
	
end

return title