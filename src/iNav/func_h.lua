local config, data, FILE_PATH = ...

if type(iNavZone) == "table" and type(iNavZone.zone) ~= "nil" then
	data.widget = true
	if iNavZone.zone.w < 450 or iNavZone.zone.h < 250 then
		data.msg = "Full screen required"
	end
end

local function title(data, config, SMLCD)
	local text = lcd.drawText
	local fill = lcd.drawFilledRectangle
	local color = lcd.setColor
	local fmt = string.format

	color(CUSTOM_COLOR, BLACK)
	fill(0, 0, LCD_W, 20, CUSTOM_COLOR)
	text(0, 0, model.getInfo().name)
	if config[13].v > 0 then
		lcd.drawTimer(340, 0, data.timer)
	end
	if config[19].v > 0 then
		fill(197, 3, 43, 14, TEXT_COLOR)
		fill(240, 6, 2, 8, TEXT_COLOR)
		local tmp = math.max(math.min((data.txBatt - data.txBattMin) / (data.txBattMax - data.txBattMin) * 42, 42), 0) + 197
		for i = 200, tmp, 4 do
			fill(i, 5, 2, 10, CUSTOM_COLOR)
		end
	end
	if config[19].v ~= 1 then
		text(290, 0, fmt("%.1fV", data.txBatt), RIGHT)
	end
	if data.rxBatt > 0 and data.telem and config[14].v == 1 then
		text(LCD_W, 0, fmt("%.1fV", data.rxBatt), RIGHT)
	elseif data.crsf then
		text(LCD_W, 0, (getValue(data.rfmd_id) == 2 and 150 or (data.telem and 50 or "--")) .. "Hz", RIGHT + (data.telem == false and WARNING_COLOR or 0))
	end

	--[[ Show FPS
	data.frames = data.frames + 1
	text(180, 0, fmt("%.1f", data.frames / (getTime() - data.fpsStart) * 100), RIGHT)
	--text(130, 0, fmt("%.1f", math.min(100 / (getTime() - data.start), 20)), RIGHT)
	]]

	-- Reset colors
	color(WARNING_COLOR, YELLOW)
	if data.widget then
		if iNavZone.options.Restore % 2 == 1 then
			color(TEXT_COLOR, iNavZone.options.Text)
			color(WARNING_COLOR, iNavZone.options.Warning)
		end
	end
end

local function gpsDegMin(c, lat)
	local gpsD = math.floor(math.abs(c))
	local gpsM = math.floor((math.abs(c) - gpsD) * 60)
	return string.format("%d\64%d'%05.2f\"", gpsD, gpsM, ((math.abs(c) - gpsD) * 60 - gpsM) * 60) .. (lat and (c >= 0 and "N" or "S") or (c >= 0 and "E" or "W"))
end

local function hdopGraph(x, y)
	local fill = lcd.drawFilledRectangle
	lcd.setColor(CUSTOM_COLOR, data.hdop < 11 - config[21].v * 2 and YELLOW or WHITE)
	for i = 4, 9 do
		if i > data.hdop then
			lcd.setColor(CUSTOM_COLOR, GREY)
		end
		fill(i * 4 + x - 16, y - (i * 3 - 10), 2, i * 3 - 10, CUSTOM_COLOR)
	end
end

local icons = {}
icons.lock = Bitmap.open(FILE_PATH .. "pics/lock.png")
icons.home = Bitmap.open(FILE_PATH .. "pics/home.png")
icons.fpv = Bitmap.open(FILE_PATH .. "pics/fpv.png")
icons.bg = Bitmap.open(FILE_PATH .. "pics/bg.png")
icons.roll = Bitmap.open(FILE_PATH .. "pics/roll.png")
icons.fg = Bitmap.open(FILE_PATH .. "pics/fg" .. config[30].v .. ".png")

-- Aircraft symbol preview
function icons.sym(fg)
	lcd.setColor(CUSTOM_COLOR, 982) -- Sky
	lcd.drawFilledRectangle(356, 111, 123, 31, CUSTOM_COLOR)
	lcd.setColor(CUSTOM_COLOR, 25121) -- Ground
	lcd.drawFilledRectangle(356, 142, 123, 31, CUSTOM_COLOR)
	lcd.drawBitmap(fg, 355, 110, 50)
	lcd.drawRectangle(355, 110, 125, 64, TEXT_COLOR)
end

data.hcurx_id = getFieldInfo("ail").id
data.hcury_id = getFieldInfo("ele").id
data.hctrl_id = getFieldInfo("rud").id
data.t6_id = getFieldInfo("trim-t6").id
data.lastevt = 0
data.lastt6 = nil
function icons.alert()
	lcd.setColor(CUSTOM_COLOR, BLACK)
	lcd.drawFilledRectangle(20, 128, 439, 30, CUSTOM_COLOR)
	lcd.setColor(CUSTOM_COLOR, YELLOW)
	lcd.drawRectangle(19, 127, 441, 32, CUSTOM_COLOR)
	lcd.drawText(28, 128, data.stickMsg, MIDSIZE + CUSTOM_COLOR)
end

function widgetEvt(data)
	local evt = 0
	if not data.armed then
		data.stickMsg = (data.throttle >= -940 or math.abs(getValue(data.hctrl_id)) >= 50) and "Return throttle stick to bottom center" or nil
		if data.throttle > 940 and getValue(data.hctrl_id) > 940 and math.abs(getValue(data.hcurx_id)) < 50 and math.abs(getValue(data.hcury_id)) < 50 then
			evt = EVT_SYS_FIRST -- Enter config menu
		elseif data.stickMsg == nil then
			if getValue(data.hcurx_id) < -940 then
				evt = EVT_EXIT_BREAK -- Left (exit)
			elseif getValue(data.hcurx_id) > 940 then
				evt = EVT_ENTER_BREAK -- Right (enter)
			elseif getValue(data.hcury_id) > 200 then
				evt = EVT_ROT_LEFT -- Up
			elseif getValue(data.hcury_id) < -200 then
				evt = EVT_ROT_RIGHT -- Down
			end
		end
		if data.lastevt == evt and (data.configStatus == 0 or math.abs(getValue(data.hcury_id)) < 940) then
			evt = 0
		else
			data.lastevt = evt
		end
	end
	if evt == 0 and data.lastt6 ~= nil and getValue(data.t6_id) ~= data.lastt6 then
		evt = EVT_ROT_RIGHT -- Down
	end
	data.lastt6 = getValue(data.t6_id)
	if data.lastt6 == 0 then
		data.lastt6 = nil
	end

	return evt
end

return title, gpsDegMin, hdopGraph, icons, widgetEvt