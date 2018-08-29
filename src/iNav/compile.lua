local SMLCD, FLASH, FILE_PATH = ...

local config = loadScript(FILE_PATH .. "config", "tc")(SMLCD)
local modes, units = loadScript(FILE_PATH .. "modes", "tc")(FLASH)
local configCnt = loadScript(FILE_PATH .. "load", "tc")(config, FILE_PATH)
local data, PREV, INCR, NEXT, DECR, MENU = loadScript(FILE_PATH .. "data", "tc")()
loadScript(FILE_PATH .. "reset", "tc")(data)
loadScript(FILE_PATH .. "other", "tc")(config, data, units, FILE_PATH)
loadScript(FILE_PATH .. "setspeed", "tc")(data, config)
loadScript(FILE_PATH .. "view", "tc")()
loadScript(FILE_PATH .. "pilot", "tc")()
loadScript(FILE_PATH .. "menu", "tc")()

return 0