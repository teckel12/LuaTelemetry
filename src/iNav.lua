-- Lua Telemetry Flight Status for INAV/Taranis
-- Author: https://github.com/teckel12
-- Docs: https://github.com/iNavFlight/LuaTelemetry

local VERSION = "1.4.0"
local FILE_PATH = "/SCRIPTS/TELEMETRY/iNav/"
local FLASH = 3
local SMLCD = LCD_W < 212
local tmp

local config, units, modes, configCnt = loadScript(FILE_PATH .. "config.luac", "T")(SMLCD, FLASH, FILE_PATH)
collectgarbage()

local data, PREV, INCR, NEXT, DECR, MENU = loadScript(FILE_PATH .. "data.luac", "T")(config, units)
collectgarbage()

local function reset()
	data.startup = 1
	data.timerStart = 0
	data.timer = 0
	data.distanceLast = 0
	data.gpsHome = false
	data.gpsLatLon = data.emptyGPS
	data.gpsFix = false
	data.headingRef = -1
	data.battLow = false
	data.showMax = false
	data.showDir = true
	data.cells = 1
	data.gpsAltBase = false
	data.configStatus = 0
	data.startupTime = 0
end
reset()

local function gpsDegMin(coord, lat)
	local gpsD = math.floor(math.abs(coord))
	return gpsD .. string.format("\64%05.2f", (math.abs(coord) - gpsD) * 60) .. (lat and (coord >= 0 and "N" or "S") or (coord >= 0 and "E" or "W"))
end

local function gpsIcon(x, y)
	lcd.drawLine(x + 1, y, x + 5, y + 4, SOLID, 0)
	lcd.drawLine(x + 1, y + 1, x + 4, y + 4, SOLID, 0)
	lcd.drawLine(x + 1, y + 2, x + 3, y + 4, SOLID, 0)
	lcd.drawLine(x, y + 5, x + 2, y + 5, SOLID, 0)
	lcd.drawPoint(x + 4, y + 1)
	lcd.drawPoint(x + 1, y + 4)
end

local function lockIcon(x, y)
	lcd.drawFilledRectangle(x, y + 2, 5, 4, 0)
	lcd.drawLine(x + 1, y, x + 3, y, SOLID, 0)
	lcd.drawPoint(x + 1, y + 1)
	lcd.drawPoint(x + 3, y + 1)
	lcd.drawPoint(x + 2, y + 3, ERASE)
end

local function homeIcon(x, y)
	lcd.drawPoint(x + 3, y - 1)
	lcd.drawLine(x + 2, y, x + 4, y, SOLID, 0)
	lcd.drawLine(x + 1, y + 1, x + 5, y + 1, SOLID, 0)
	lcd.drawLine(x, y + 2, x + 6, y + 2, SOLID, 0)
	lcd.drawLine(x + 1, y + 3, x + 1, y + 5, SOLID, 0)
	lcd.drawLine(x + 5, y + 3, x + 5, y + 5, SOLID, 0)
	lcd.drawLine(x + 2, y + 5, x + 4, y + 5, SOLID, 0)
	lcd.drawPoint(x + 3, y + 4)
end

local function hdopGraph(x, y, size)
	local tmp = ((data.armed or data.modeId == 6) and data.hdop < 11 - config[21].v * 2) or not data.telemetry
	if config[22].v == 0 then
		if tmp then
			lcd.drawText(x, y, "    ", SMLSIZE + FLASH)
		end
		for i = 4, 9 do
			lcd.drawLine(x - 8 + (i * 2), (data.hdop >= i or not SMLCD) and y + 8 - i or y + 5, x - 8 + (i * 2), y + 5, SOLID, (data.hdop >= i or SMLCD) and 0 or GREY_DEFAULT)
		end
	else
		lcd.drawText(x + 12, size == SMLSIZE and y or y - 2, (data.hdop == 0 and not data.gpsFix) and "--" or (9 - data.hdop) / 2 + 0.8, size + RIGHT + (tmp and FLASH or 0))
	end
end

local function background()
	loadScript(FILE_PATH .. "bkgnd.luac", "T")(data, reset, config, FLASH)
	collectgarbage()

	loadScript(FILE_PATH .. "flight.luac", "T")(data, config, modes, FILE_PATH)
	collectgarbage()

	if data.armed and data.gpsFix and data.gpsHome == false then
		data.gpsHome = data.gpsLatLon
	end
end

local function run(event)
	lcd.clear()

	-- Display system error
	if data.systemError then
		lcd.drawText((LCD_W - string.len(data.systemError) * 5.2) / 2, 27, data.systemError)
		return 0
	end

	-- Startup message
	if data.startup == 1 then
		data.startupTime = getTime()
		data.startup = 2
	elseif data.startup == 2 and getTime() - data.startupTime >= 200 then
		data.startup = 0
	end

	-- Config menu or views
	if data.configStatus == 0 and event == MENU then
		data.configStatus = data.configLast
	end
	if data.configStatus > 0 then
		loadScript(FILE_PATH .. "menu.luac", "T")(data, config, event, gpsDegMin, configCnt, FILE_PATH, SMLCD, PREV, INCR, NEXT, DECR)
	else
		-- User input
		if not data.armed and data.configStatus == 0 then
			-- Toggle showing max/min values
			if event == PREV or event == NEXT then
				data.showMax = not data.showMax
			end
			-- Initalize variables on long <Enter>
			if event == EVT_ENTER_LONG then
				reset()
			end
		end
		if event == NEXT or event == PREV then
			data.showDir = not data.showDir
		end
		-- Views
		if config[25].v == 1 then
			loadScript(FILE_PATH .. "pilot.luac", "T")(data, config, modes, units, gpsDegMin, gpsIcon, lockIcon, homeIcon, hdopGraph, VERSION, SMLCD, FLASH)
		else
			loadScript(FILE_PATH .. "view.luac", "T")(data, config, modes, units, gpsDegMin, gpsIcon, lockIcon, hdopGraph, VERSION, SMLCD, FLASH)
		end
	end
	collectgarbage()

	-- Title
	lcd.drawFilledRectangle(0, 0, LCD_W, 8, FORCE)
	lcd.drawText(0, 0, data.modelName, INVERS)
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
	if data.rxBatt > 0 and data.telemetry and config[14].v == 1 then
		lcd.drawText(LCD_W, 1, string.format("%.1f", data.rxBatt) .. "V", SMLSIZE + RIGHT + INVERS)
	end

	return 0
end

return { run = run, background = background }