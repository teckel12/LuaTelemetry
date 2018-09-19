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
loadScript(FILE_PATH .. "lang_de", env)(modes, config)
loadScript(FILE_PATH .. "reset", env)(data)
loadScript(FILE_PATH .. "other", env)(config, data, units, FILE_PATH)
loadScript(FILE_PATH .. "setspeed", env)(data, config)
loadScript(FILE_PATH .. "view", env)()
loadScript(FILE_PATH .. "pilot", env)()
loadScript(FILE_PATH .. "menu", env)()
loadScript("/SCRIPTS/TELEMETRY/iNav", env)(false)

return 0