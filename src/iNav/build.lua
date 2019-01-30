local buildMode = ...
local FILE_PATH = "/SCRIPTS/TELEMETRY/iNav/"
local FLASH = 3
local SMLCD = LCD_W < 212
local HORUS = LCD_W >= 480
local v, r, m, i, e = getVersion()
local env = "tc" -- Default: "tc" | Debug mode: "tcb"

local config = loadScript(FILE_PATH .. "config", env)(SMLCD)
local modes, units, labels = loadScript(FILE_PATH .. "modes", env)()
local data, getTelemetryId, getTelemetryUnit, PREV, INCR, NEXT, DECR, MENU = loadScript(FILE_PATH .. "data", env)(r, m, i, HORUS)
loadScript(FILE_PATH .. "load", env)(config, data, FILE_PATH)
if HORUS then
	local title, gpsDegMin, hdopGraph, icons, widgetEvt = loadScript(FILE_PATH .. "func_h", env)(config, data, FILE_PATH)
end
local title, gpsDegMin, hdopGraph, icons, widgetEvt = loadScript(FILE_PATH .. "func_t", env)(config, data, FILE_PATH)

data.lang = "en"
data.voice = "en"
loadScript(FILE_PATH .. "lang", env)(modes, config, labels, data, FILE_PATH)
local lang = { "nl", "fr", "it", "de", "cz", "sk", "es", "pl", "pt", "ru", "se", "hu" }
for abv = 1, 12 do
	local fh = io.open(FILE_PATH .. "lang_" .. lang[abv] .. ".lua")
	if fh ~= nil then
		io.close(fh)
		loadScript(FILE_PATH .. "lang_" .. lang[abv], env)(modes, config, labels)
	end
end

loadScript(FILE_PATH .. "reset", env)(data)
local crsf = loadScript(FILE_PATH .. "crsf", env)(config, data, getTelemetryId)
crsf = loadScript(FILE_PATH .. "other", env)(config, data, units, getTelemetryId, getTelemetryUnit, FILE_PATH)
loadScript(FILE_PATH .. "view", env)()
loadScript(FILE_PATH .. "pilot", env)()
loadScript(FILE_PATH .. "radar", env)()
loadScript(FILE_PATH .. "horus", env)()
loadScript(FILE_PATH .. "menu", env)()

if buildMode == nil then
	loadScript("/WIDGETS/iNav/main", env)()
end

return 0