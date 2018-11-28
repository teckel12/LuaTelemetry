local FILE_PATH = "/SCRIPTS/TELEMETRY/iNav/"
local FLASH = 3
local SMLCD = LCD_W < 212
local v, r, m, i, e = getVersion()
local env = "tc" -- Default: "tc" | Debug mode: "tcb"

local config = loadScript(FILE_PATH .. "config", env)(SMLCD)
local modes, units = loadScript(FILE_PATH .. "modes", env)()
local data, getTelemetryId, getTelemetryUnit, PREV, INCR, NEXT, DECR, MENU = loadScript(FILE_PATH .. "data", env)(r, m, i, HORUS)
local configCnt = loadScript(FILE_PATH .. "load", env)(config, data, FILE_PATH)
local title, gpsDegMin, gpsIcon, lockIcon, homeIcon, hdopGraph, attOverlay = loadScript(FILE_PATH .. "func_h", env)(config, data, FILE_PATH)
local title, gpsDegMin, gpsIcon, lockIcon, homeIcon, hdopGraph, attOverlay = loadScript(FILE_PATH .. "func_t", env)(config, data, FILE_PATH)

data.lang = "en"
data.voice = "en"
loadScript(FILE_PATH .. "lang", env)(modes, config, data, FILE_PATH)
local lang = { "nl", "fr", "it", "de", "cz", "sk", "es", "pl", "pt", "ru", "se", "hu" }
for abv = 1, 12 do
	local fh = io.open(FILE_PATH .. "lang_" .. lang[abv] .. ".lua")
	if fh ~= nil then
		io.close(fh)
		loadScript(FILE_PATH .. "lang_" .. lang[abv], env)(modes, config)
	end
end

loadScript(FILE_PATH .. "reset", env)(data)
loadScript(FILE_PATH .. "other", env)(config, data, units, getTelemetryId, getTelemetryUnit, FILE_PATH)
loadScript(FILE_PATH .. "view", env)()
loadScript(FILE_PATH .. "pilot", env)()
loadScript(FILE_PATH .. "radar", env)()
loadScript(FILE_PATH .. "menu", env)()
loadScript(FILE_PATH .. "horus", env)()
--loadScript("/SCRIPTS/TELEMETRY/iNav", env)(true)

return 0