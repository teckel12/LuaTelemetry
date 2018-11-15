local function page(data, config, SMLCD)
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
		lcd.drawText(SMLCD and (config[14].v == 1 and 105 or LCD_W) or 128, 1, string.format("%.1f", data.txBatt) .. "V", SMLSIZE + RIGHT + INVERS)
	end
	if data.rxBatt > 0 and data.telem and config[14].v == 1 then
		lcd.drawText(LCD_W, 1, string.format("%.1f", data.rxBatt) .. "V", SMLSIZE + RIGHT + INVERS)
	end

	--[[ Show FPS
	data.frames = data.frames + 1
	lcd.drawText(SMLCD and 57 or 80, 1, string.format("%.1f", data.frames / (getTime() - data.fpsStart) * 100), SMLSIZE + RIGHT + INVERS)
	]]
end

return page