local config, data, FILE_PATH = ...

local function title(data, config, SMLCD)
	local text = lcd.drawText
	local fill = lcd.drawFilledRectangle
	local color = lcd.setColor
	local fmt = string.format
	local tmp = 0

	if not data.telem then
		color(WARNING_COLOR, RED)
		tmp = WARNING_COLOR
	end

	color(CUSTOM_COLOR, BLACK)
	fill(0, 0, LCD_W, 20, CUSTOM_COLOR)
	text(0, 0, model.getInfo().name)
	if config[13].v > 0 then
		if data.doLogs and data.time ~= nil then
			text(340, 0, data.time, WARNING_COLOR)
		else
			lcd.drawTimer(340, 0, data.timer)
		end
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

	if data.rxBatt > 0 and config[14].v == 1 then
		text(LCD_W, 0, fmt("%.1fV", data.rxBatt), RIGHT + tmp)
	elseif data.crsf then
		text(LCD_W, 0, (data.rfmd == 2 and 150 or (data.telem and 50 or "--")) .. "Hz", RIGHT + tmp)
	end

	if data.configStatus > 0 then
		color(CUSTOM_COLOR, 12678) -- Dark grey
		fill(0, 30, 75, (22 * (data.crsf and 1 or 2)) + 14, CUSTOM_COLOR)
		lcd.drawRectangle(0, 30, 75, (22 * (data.crsf and 1 or 2)) + 14, TEXT_COLOR)
		text(4, 37, "Sats:", 0)
		text(72, 37, data.satellites % 100, RIGHT + tmp)
		if not data.crsf then
			text(4, 59, "DOP:", 0)
			text(72, 59, (data.hdop == 0 and not data.gpsFix) and "---" or (9 - data.hdop) * 0.5 + 0.8, RIGHT + tmp)
		end
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
icons.home = {
	[0] = Bitmap.open(FILE_PATH .. "pics/homes.png"),
	[1] = Bitmap.open(FILE_PATH .. "pics/homem.png"),
	[2] = Bitmap.open(FILE_PATH .. "pics/homel.png"),
}
icons.fpv = Bitmap.open(FILE_PATH .. "pics/fpv.png")
icons.bg = Bitmap.open(FILE_PATH .. "pics/bg.png")
icons.roll = Bitmap.open(FILE_PATH .. "pics/roll.png")
icons.fg = Bitmap.open(FILE_PATH .. "pics/fg" .. config[30].v .. ".png")

data.hcurx_id = getFieldInfo("ail").id
data.hcury_id = getFieldInfo("ele").id
data.hctrl_id = getFieldInfo("rud").id
data.t6_id = getFieldInfo("trim-t6").id
data.lastevt = 0
data.lastt6 = nil

if type(iNavZone) == "table" and type(iNavZone.zone) ~= "nil" then
	data.widget = true
	if iNavZone.zone.w < 450 or iNavZone.zone.h < 250 then
		data.startupTime = math.huge
		function icons.nfs()
			lcd.drawText(iNavZone.zone.x + 14, iNavZone.zone.y + 16, "Full screen required", SMLSIZE + WARNING_COLOR)
		end
	end
end

function icons.clear(event, data)
	lcd.setColor(CUSTOM_COLOR, 264) --lcd.RGB(0, 32, 65)
	lcd.clear(CUSTOM_COLOR)
	if event == 0 or event == nil then
		event = 0
		if not data.armed then
			data.stickMsg = (data.throttle >= -940 or math.abs(getValue(data.hctrl_id)) >= 50) and "Return throttle stick to bottom center" or nil
			if data.throttle > 940 and getValue(data.hctrl_id) > 940 and math.abs(getValue(data.hcurx_id)) < 50 and math.abs(getValue(data.hcury_id)) < 50 then
				event = EVT_SYS_FIRST -- Enter config menu
			elseif data.stickMsg == nil then
				if getValue(data.hcurx_id) < -940 then
					event = EVT_EXIT_BREAK -- Left (exit)
				elseif getValue(data.hcurx_id) > 940 then
					event = EVT_ENTER_BREAK -- Right (enter)
				elseif getValue(data.hcury_id) > 200 then
					event = EVT_ROT_LEFT -- Up
				elseif getValue(data.hcury_id) < -200 then
					event = EVT_ROT_RIGHT -- Down
				end
			end
			if data.lastevt == event and (data.configStatus == 0 or math.abs(getValue(data.hcury_id)) < 940) then
				event = 0
			else
				data.lastevt = event
			end
		end
		if event == 0 and data.lastt6 ~= nil then
			if getValue(data.t6_id) > data.lastt6 then
				event = EVT_ROT_LEFT -- Up
			elseif getValue(data.t6_id) < data.lastt6 then
				event = EVT_ROT_RIGHT -- Down
			end
		end
		if event == 0 and data.doLogs and getValue(data.hcurx_id) < -940 then
			event = EVT_EXIT_BREAK -- Left (exit)
		end
		data.lastt6 = getValue(data.t6_id)
		if data.lastt6 == 0 then
			data.lastt6 = nil
		end
	end
	return event
end

function icons.menu(config, data, icons, prev)
	if config[30].v ~= prev then
		icons.fg = Bitmap.open(FILE_PATH .. "pics/fg" .. config[30].v .. ".png")
	end
	-- Aircraft symbol preview
	if data.configStatus == 27 and data.configSelect ~= 0 then
		lcd.setColor(CUSTOM_COLOR, 982) -- Sky
		lcd.drawFilledRectangle(356, 111, 123, 31, CUSTOM_COLOR)
		lcd.setColor(CUSTOM_COLOR, 25121) -- Ground
		lcd.drawFilledRectangle(356, 142, 123, 31, CUSTOM_COLOR)
		lcd.drawBitmap(icons.fg, 355, 110, 50)
		lcd.drawRectangle(355, 110, 125, 64, TEXT_COLOR)	
	end
	-- Return throttle stick to bottom center
	if data.stickMsg ~= nil and not data.armed then
		lcd.setColor(CUSTOM_COLOR, BLACK)
		lcd.drawFilledRectangle(20, 128, 439, 30, CUSTOM_COLOR)
		lcd.setColor(CUSTOM_COLOR, YELLOW)
		lcd.drawRectangle(19, 127, 441, 32, CUSTOM_COLOR)
		lcd.drawText(28, 128, data.stickMsg, MIDSIZE + CUSTOM_COLOR)	
	end
end

return title, gpsDegMin, hdopGraph, icons