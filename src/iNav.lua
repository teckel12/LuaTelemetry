-- Lua Telemetry Flight Status for INAV/Taranis
-- Author: https://github.com/teckel12
-- Docs: https://github.com/iNavFlight/LuaTelemetry

local VERSION = "1.4.0"
local FILE_PATH = "/SCRIPTS/TELEMETRY/iNav/"
local FLASH = 3
local SMLCD = LCD_W < 212
local tmp

local config = loadScript(FILE_PATH .. "config.luac", "T")(SMLCD)
collectgarbage()

local modes, units = loadScript(FILE_PATH .. "modes.luac", "T")(FLASH)
local configCnt = loadScript(FILE_PATH .. "load.luac", "T")(config, FILE_PATH)
collectgarbage()

local data, PREV, INCR, NEXT, DECR, MENU = loadScript(FILE_PATH .. "data.luac", "T")()
collectgarbage()

loadScript(FILE_PATH .. "reset.luac", "T")(data)
loadScript(FILE_PATH .. "other.luac", "T")(config, data, units, FILE_PATH)
collectgarbage()

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
	--if getTime() < data.refresh then return 0 end
	--data.refresh = getTime() + 20
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
		loadScript(FILE_PATH .. "menu.luac", "T")(data, config, event, configCnt, FILE_PATH, SMLCD, FLASH, PREV, INCR, NEXT, DECR)
	else
		-- User input
		if not data.armed and data.configStatus == 0 then
			-- Toggle showing max/min values
			if event == PREV or event == NEXT then
				data.showMax = not data.showMax
			end
			-- Initalize variables on long <Enter>
			if event == EVT_ENTER_LONG then
				loadScript(FILE_PATH .. "reset.luac", "T")(data)
			end
		end
		if event == NEXT or event == PREV then
			data.showDir = not data.showDir
		end
		-- Views
		if config[25].v == 1 then
			loadScript(FILE_PATH .. "pilot.luac", "T")(data, config, modes, units, VERSION, SMLCD, FLASH, FILE_PATH)
		else
			loadScript(FILE_PATH .. "view.luac", "T")(data, config, modes, units, VERSION, SMLCD, FLASH, FILE_PATH)
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

	-- Show FPS
	data.frames = data.frames + 1
	lcd.drawText(SMLCD and 57 or 80, 1, string.format("%.1f", data.frames / (getTime() - data.fpsStart) * 100), SMLSIZE + RIGHT + INVERS)

	return 0
end

return { run = run, background = background }