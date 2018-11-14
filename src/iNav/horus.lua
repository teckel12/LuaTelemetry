local function view(data, config, modes, units, gpsDegMin, gpsIcon, lockIcon, homeIcon, hdopGraph, calcTrig, calcDir, VERSION, SMLCD, FLASH, FILE_PATH)

	-- 480 x 272
	--GREY_DEFAULT = 0
	--FORCE = 0
	--ERASE = 0

	local LEFT_DIV = 36
	local LEFT_POS = 73
	local RIGHT_POS = LCD_W - 53
	local X_CNTR = (RIGHT_POS + LEFT_POS) / 2 - 1
	local gpsFlags = SMLSIZE + RIGHT + ((not data.telem or not data.gpsFix) and FLASH or 0)
	local tmp, pitch

	lcd.setColor(TEXT_COLOR, BLACK)

	-- Display system error
	if data.msg then
		lcd.drawText((LCD_W - string.len(data.msg) * 13) / 2, 130, data.msg, MIDSIZE)
		return 0
	end

	-- Startup message
	if data.startup == 2 then
		lcd.drawText(X_CNTR - 90, 50, "Lua Telemetry", MIDSIZE)
		lcd.drawText(X_CNTR - 50, 80, "v" .. VERSION, MIDSIZE)
	end

	local rssiFlags = RIGHT + ((not data.telem or data.rssi < data.rssiLow) and FLASH or 0)
	lcd.drawText(LCD_W, 52, math.min(data.showMax and data.rssiMin or data.rssiLast, 99) .. "dB", MIDSIZE + rssiFlags)

end

return view