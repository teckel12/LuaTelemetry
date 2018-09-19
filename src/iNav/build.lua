local debug = false

local FILE_PATH = "/SCRIPTS/TELEMETRY/iNav/"
local FLASH = 3
local SMLCD = LCD_W < 212
local v, r, m, i, e = getVersion()
local env = debug == true and "tcd" or "tc"

local config = loadScript(FILE_PATH .. "config", env)(SMLCD)
local modes, units = loadScript(FILE_PATH .. "modes", env)(FLASH)
local configCnt = loadScript(FILE_PATH .. "load", env)(config, FILE_PATH)
local data, PREV, INCR, NEXT, DECR, MENU = loadScript(FILE_PATH .. "data", env)(r, m, i)

data.lang = "en"
data.voice = "en"
loadScript(FILE_PATH .. "lang.luac", env)(modes, config, data, FILE_PATH)
local lang = { "nl", "fr", "it", "de", "cz", "sk", "es", "pl", "pt", "ru", "se", "hu" }
for abv = 1, 12 do
	local fh = io.open(FILE_PATH .. "lang_" .. lang[abv] .. ".lua")
	if fh ~= nil then
		io.close(fh)
		loadScript(FILE_PATH .. "lang_" .. lang[abv], env)(modes, config)
	end
end

loadScript(FILE_PATH .. "reset", env)(data)
loadScript(FILE_PATH .. "other", env)(config, data, units, FILE_PATH)
loadScript(FILE_PATH .. "setspeed", env)(data, config)
loadScript(FILE_PATH .. "view", env)()
loadScript(FILE_PATH .. "pilot", env)()
loadScript(FILE_PATH .. "menu", env)()
loadScript("/SCRIPTS/TELEMETRY/iNav", env)(false)

return 0