local TELE_PATH = "/SCRIPTS/TELEMETRY/"

local iNav = loadfile(TELE_PATH .. "iNav.luac")()
iNav.playAudio = nil
iNav.calcTrig = nil
iNav.calcDir = nil
iNav.background = nil
iNav.run = nil
collectgarbage()

local view = loadfile(TELE_PATH .. "iNav/menu.luac")()
--data.v = 9

-- Run when first started
local function create()
	lcd.setColor(CUSTOM_COLOR, 0)
	lcd.clear(CUSTOM_COLOR)
	lcd.drawText(40, 40, "iNav Menu", 0)
	view(data, config, "", configCnt, gpsDegMin, getTelemetryId, getTelemetryUnit, FILE_PATH, SMLCD, FLASH, PREV, INCR, NEXT, DECR)
	return 0
end

-- Called upon registration and at change of settings in the telemetry setup menu
local function update()
	return 0
end

local function refresh()
	--view(data, config, "", configCnt, gpsDegMin, getTelemetryId, getTelemetryUnit, FILE_PATH, SMLCD, FLASH, PREV, INCR, NEXT, DECR)
	return 0
end

local function bg()
	--iNav.background()
	return 0
end

return { name = "iNAV Menu", options = {}, create = create, update = update, refresh = refresh, background = bg }