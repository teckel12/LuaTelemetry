local config, data, FILE_PATH = ...

if type(iNavZone) == "table" and type(iNavZone.zone) ~= "nil" then
	data.widget = true
	if iNavZone.zone.w < 450 or iNavZone.zone.h < 250 then
		data.msg = "Full screen required"
	end
end

local function title(data, config, SMLCD)
	lcd.setColor(CUSTOM_COLOR, BLACK)
	lcd.drawFilledRectangle(0, 0, LCD_W, 20, CUSTOM_COLOR)
	lcd.drawText(0, 0, model.getInfo().name)
	if config[13].v > 0 then
		lcd.drawTimer(340, 0, data.timer)
	end
	if config[19].v > 0 then
		lcd.setColor(CUSTOM_COLOR, WHITE)
		lcd.drawFilledRectangle(197, 3, 43, 14, CUSTOM_COLOR)
		lcd.drawFilledRectangle(240, 6, 2, 8, CUSTOM_COLOR)
		local tmp = math.max(math.min((data.txBatt - data.txBattMin) / (data.txBattMax - data.txBattMin) * 42, 42), 0) + 197
		lcd.setColor(CUSTOM_COLOR, BLACK)
		for i = 200, tmp, 4 do
			lcd.drawFilledRectangle(i, 5, 2, 10, CUSTOM_COLOR)
		end
	end
	if config[19].v ~= 1 then
		lcd.drawText(290, 0, string.format("%.1fV", data.txBatt), RIGHT)
	end
	if data.rxBatt > 0 and data.telem and config[14].v == 1 then
		lcd.drawText(LCD_W, 0, string.format("%.1fV", data.rxBatt), RIGHT)
	elseif data.crsf then
		lcd.drawText(LCD_W, 0, (getValue(data.rfmd_id) == 2 and 150 or (data.telem and 50 or "--")) .. "Hz", RIGHT + (data.telem == false and WARNING_COLOR or 0))
	end

	--[[ Show FPS
	data.frames = data.frames + 1
	lcd.drawText(180, 0, string.format("%.1f", data.frames / (getTime() - data.fpsStart) * 100), RIGHT)
	--lcd.drawText(130, 0, string.format("%.1f", math.min(100 / (getTime() - data.start), 20)), RIGHT)
	]]

	-- Reset color
	lcd.setColor(WARNING_COLOR, YELLOW)
	if data.widget then
		if iNavZone.options.Restore % 2 == 1 then
			lcd.setColor(TEXT_COLOR, iNavZone.options.Text)
			lcd.setColor(WARNING_COLOR, iNavZone.options.Warning)
		end
	end
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
icons.roll = Bitmap.open(FILE_PATH .. "pics/roll.png")
icons.fg = Bitmap.open(FILE_PATH .. "pics/fg" .. config[30].v .. ".png")

--[[ Aircraft symbol preview
function icons.sym(fg)
	lcd.setColor(CUSTOM_COLOR, 982) -- Sky
	lcd.drawFilledRectangle(106, 248, 269, 9, CUSTOM_COLOR)
	lcd.setColor(CUSTOM_COLOR, 25121) -- Ground
	lcd.drawFilledRectangle(106, 257, 269, 15, CUSTOM_COLOR)
	lcd.drawBitmap(fg, 106, 248)
	lcd.setColor(CUSTOM_COLOR, 12678) -- Dk Grey
	lcd.drawFilledRectangle(106, 248, 40, 24, CUSTOM_COLOR)
	lcd.drawFilledRectangle(330, 248, 45, 24, CUSTOM_COLOR)
	lcd.setColor(CUSTOM_COLOR, WHITE)
	lcd.drawRectangle(105, 247, 271, 26, CUSTOM_COLOR)
end
]]

if data.widget then
	data.hcurx_id = getFieldInfo("ail").id
	data.hcury_id = getFieldInfo("ele").id
	data.hctrl_id = getFieldInfo("rud").id
	model.setTimer(2, { mode = 0, start = 0, value = 3600, countdownBeep = 0, minuteBeep = false, persistent = 0} )
end

function widgetEvt(data)
	local evt = 0
	if not data.armed then
		if data.throttle > 940 and getValue(data.hctrl_id) > 940 then
			evt = EVT_SYS_FIRST
		elseif getValue(data.hcurx_id) < -940 then
			evt = EVT_EXIT_BREAK
		elseif getValue(data.hcurx_id) > 940 then
			evt = EVT_ENTER_BREAK
		elseif getValue(data.hcury_id) > 200 then
			evt = EVT_ROT_LEFT
		elseif getValue(data.hcury_id) < -200 then
			evt = EVT_ROT_RIGHT
		end
	end
	if data.lastevt == evt and math.abs(getValue(data.hcury_id)) < 940 then
		evt = 0
	else
		data.lastevt = evt
	end
	return evt
end

return title, gpsDegMin, hdopGraph, icons, widgetEvt