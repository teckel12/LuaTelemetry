local FLASH = ...

-- Modes: t=text / f=flags for text / w=wave file
local modes = {
	{ t = "! TELEM !", f = FLASH },
	{ t = "HORIZON",   f = 0, w = "hrznmd" },
	{ t = "  ANGLE",   f = 0, w = "anglmd" },
	{ t = "   ACRO",   f = 0, w = "acromd" },
	{ t = " NOT OK ",  f = FLASH },
	{ t = "  READY",   f = 0, w = "ready" },
	{ t = "POS HOLD",  f = 0, w = "poshld" },
	{ t = "WAYPONT",   f = 0, w = "waypt" },
	{ t = " MANUAL",   f = 0, w = "manmd" },
	{ t = "   RTH   ", f = FLASH, w = "rtl" },
	{ t = "! FAIL !",  f = FLASH, w = "fson" },
	{ t = "! THROT !", f = FLASH },
	{ t = " CRUISE",   f = 0, w = "cruzmd" }
}

local units = { [0] = "", "V", "A", "mA", "kts", "m/s", "f/s", "km/h", "MPH", "m", LCD_W >= 480 and "ft" or "'" }

return modes, units