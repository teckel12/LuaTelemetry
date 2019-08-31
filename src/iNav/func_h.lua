local config, data, FILE_PATH = ...

local function title(data, config, icons, SMLCD)
	local text = lcd.drawText
	local fill = lcd.drawFilledRectangle
	local color = lcd.setColor
	local fmt = string.format
	local tmp = 0

	if not data.telem then
		tmp = WARNING_COLOR
	end

	color(CUSTOM_COLOR, BLACK)
	fill(0, 0, LCD_W, 20, CUSTOM_COLOR)
	text(0, 0, model.getInfo().name)

	local bat = data.nv and 115 or 197
	if config[19].v > 0 then
		fill(bat, 3, 43, 14, TEXT_COLOR)
		fill(bat + 43, 6, 2, 8, TEXT_COLOR)
		local lev = math.max(math.min((data.txBatt - data.txBattMin) / (data.txBattMax - data.txBattMin) * 42, 42), 0) + bat
		for i = bat + 3, lev, 4 do
			fill(i, 5, 2, 10, CUSTOM_COLOR)
		end
	end
	if config[19].v ~= 1 and not data.nv then
		text(bat + 93, 0, fmt("%.1fV", data.txBatt), RIGHT)
	end

	if config[13].v > 0 then
		if data.doLogs and data.time ~= nil then
			text(data.nv and 195 or 340, 0, data.time, WARNING_COLOR)
		else
			lcd.drawTimer(data.nv and 195 or 340, 0, data.timer)
		end
	end

	if data.rxBatt > 0 and config[14].v == 1 then
		text(LCD_W, 0, fmt("%.1fV", data.rxBatt), RIGHT + tmp)
	elseif data.crsf then
		text(LCD_W, 0, (data.rfmd == 2 and 150 or (data.telem and 50 or "--")) .. "Hz", RIGHT + tmp)
	end

	if data.configStatus > 0 then
		color(CUSTOM_COLOR, 12678) -- Dark grey
		fill(0, 30, 75, (22 * (data.crsf and 1 or 2)) + 14, CUSTOM_COLOR)
		icons.rectangle(0, 30, 75, (22 * (data.crsf and 1 or 2)) + 14, TEXT_COLOR)
		text(4, 37, "Sats:", 0)
		text(72, 37, data.satellites % 100, RIGHT + tmp)
		if not data.crsf then
			text(4, 59, "DOP:", 0)
			text(72, 59, (data.hdop == 0 and not data.gpsFix) and "---" or (9 - data.hdop) * 0.5 + 0.8, RIGHT + tmp)
		end
	end

	--[[ Show FPS ]]
	data.frames = data.frames + 1
	text(data.nv and 115 or 180, 0, fmt("%.1f", data.frames / (getTime() - data.fpsStart) * 100), RIGHT)
	text(data.nv and 75 or 130, 0, fmt("%.1f", math.min(100 / (getTime() - data.start), 20)), RIGHT)
	

	-- Reset colors
	color(WARNING_COLOR, YELLOW)
	if data.widget then
		if iNavZone.options.Restore % 2 == 1 then
			color(TEXT_COLOR, iNavZone.options.Text)
			color(WARNING_COLOR, iNavZone.options.Warning)
		end
	end

	--text(40,20,lcd.RGB(255, 100, 100),0)
	--text(40,40,lcd.RGB(255, 255, 100),0)
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
icons.bg = Bitmap.open(FILE_PATH .. (data.nv and "pics/bgnv.png" or "pics/bg.png"))
icons.roll = Bitmap.open(FILE_PATH .. "pics/roll.png")
icons.fg = Bitmap.open(FILE_PATH .. "pics/fg" .. config[30].v .. ".png")

data.hcurx_id = getFieldInfo("ail").id
data.hcury_id = getFieldInfo("ele").id
data.hctrl_id = getFieldInfo("rud").id
data.t6_id = not data.nv and getFieldInfo("trim-t6").id or nil
data.lastevt = 0
data.lastt6 = nil

if type(iNavZone) == "table" and type(iNavZone.zone) ~= "nil" then
	data.widget = true
	if iNavZone.zone.w < (data.nv and 280 or 450) or iNavZone.zone.h < (data.nv and 450 or 250) then
		data.startupTime = math.huge
		function icons.nfs()
			lcd.drawText(iNavZone.zone.x + 14, iNavZone.zone.y + 16, "Full screen required", SMLSIZE + WARNING_COLOR)
		end
	end
end

function icons.clear(event, data)
	lcd.setColor(CUSTOM_COLOR, data.nv and (data.configStatus > 0 and lcd.RGB(98, 106, 115) or 12942) or 264) --lcd.RGB(50, 82, 115) & lcd.RGB(0, 32, 65)
	lcd.clear(CUSTOM_COLOR)
	lcd.setColor(TEXT_COLOR, WHITE)
	lcd.setColor(WARNING_COLOR, data.telem and (data.nv and 65516 or YELLOW) or (data.nv and 64300 or RED)) --lcd.RGB(255, 255, 100) & lcd.RGB(255, 100, 100)

	if event == 0 or event == nil then
		event = 0
		if data.nv then
			EVT_SYS_FIRST = 1542
			EVT_ROT_LEFT = 57088
			EVT_ROT_RIGHT = 56832
			EVT_ENTER_BREAK = 514
			EVT_EXIT_BREAK = 516
		end
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
		data.lastt6 = not data.nv and getValue(data.t6_id) or nil
		if data.lastt6 == 0 then
			data.lastt6 = nil
		end
		--[[
		lcd.setColor(CUSTOM_COLOR, WHITE)
		lcd.drawText(0,400,"t " .. data.throttle,CUSTOM_COLOR)
		lcd.drawText(0,420,"l " .. getValue(data.hctrl_id),CUSTOM_COLOR)
		lcd.drawText(0,440,"x " .. getValue(data.hcurx_id),CUSTOM_COLOR)
		lcd.drawText(0,460,"y " .. getValue(data.hcury_id),CUSTOM_COLOR)
		]]
	end
	return event
end

function icons.menu(config, data, icons, prev)
	if config[30].v ~= prev then
		icons.fg = Bitmap.open(FILE_PATH .. "pics/fg" .. config[30].v .. ".png")
	end

	-- Aircraft symbol preview
	if data.configStatus == 27 and data.configSelect ~= 0 then
		lcd.setColor(CUSTOM_COLOR, data.nv and 13660 or 982) -- Sky
		lcd.drawFilledRectangle(LCD_W - 124, (data.nv and 28 or 111), 123, 31, CUSTOM_COLOR)
		lcd.setColor(CUSTOM_COLOR, data.nv and 37799 or 25121) -- Ground
		lcd.drawFilledRectangle(LCD_W - 124, (data.nv and 59 or 142), 123, 31, CUSTOM_COLOR)
		lcd.drawBitmap(icons.fg, LCD_W - 125, (data.nv and 27 or 110), 50)
		icons.rectangle(LCD_W - 125, (data.nv and 27 or 110), 125, 64, TEXT_COLOR)
	end
	-- Return throttle stick to bottom center
	if data.stickMsg ~= nil and not data.armed then
		lcd.setColor(CUSTOM_COLOR, BLACK)
		lcd.drawFilledRectangle(data.nv and 6 or 20, data.nv and 270 or 128, data.nv and 308 or 439, 30, CUSTOM_COLOR)
		lcd.setColor(CUSTOM_COLOR, YELLOW)
		icons.rectangle(data.nv and 5 or 19, data.nv and 269 or 127, data.nv and 310 or 441, 32, CUSTOM_COLOR)
		lcd.drawText(data.nv and 14 or 28, data.nv and 275 or 128, data.stickMsg, (data.nv and SMLSIZE or MIDSIZE) + CUSTOM_COLOR)
	end
end

function icons.rectangle(x, y, w, h, color)
	if data.nv then
		w = w - 1
		h = h - 1
		lcd.drawLine(x, y, x + w, y, SOLID, color)
		lcd.drawLine(x + w, y, x + w, y + h, SOLID, color)
		lcd.drawLine(x + w, y + h, x, y + h, SOLID, color)
		lcd.drawLine(x, y + h, x, y, SOLID, color)
	else
		lcd.drawRectangle(x, y, w, h, color)
	end
end

return title, gpsDegMin, hdopGraph, icons