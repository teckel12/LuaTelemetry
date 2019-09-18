local HORUS = ...

-- Modes: t=text / f=flags for text / w=wave file
local modes = {
	{ t = "! TELEM !", f = 3 },
	{ t = "HORIZON",   f = 0, w = "hrznmd" },
	{ t = "  ANGLE",   f = 0, w = "anglmd" },
	{ t = "   ACRO",   f = 0, w = "acromd" },
	{ t = " NOT OK ",  f = 3 },
	{ t = "  READY",   f = 0, w = "ready" },
	{ t = "POS HOLD",  f = 0, w = "poshld" },
	{ t = "WAYPONT",   f = 0, w = "waypt" },
	{ t = " MANUAL",   f = 0, w = "manmd" },
	{ t = "   RTH   ", f = 3, w = "rtl" },
	{ t = "! FAIL !",  f = 3, w = "fson" },
	{ t = "! THROT !", f = 3 },
	{ t = " CRUISE",   f = 0, w = "cruzmd" }
}

local units = { [0] = "", "V", "A", "mA", "kts", "m/s", "f/s", "kmh", "MPH", "m", HORUS and "ft" or "'" }

local labels = { "Fuel", "Battery", "Current", "Altitude", "Distance" }

local dir = { [0] = "N", "NE", "E", "SE", "S", "SW", "W", "NW" }

return modes, units, labels, dir