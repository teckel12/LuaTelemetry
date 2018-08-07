local data, config, FLASH, SMLCD, FILE_PATH = ...

local function getTelemetryId(name)
	local field = getFieldInfo(name)
	return field and field.id or -1
end

local function getTelemetryUnit(name)
	local field = getFieldInfo(name)
	return (field and field.unit <= 10) and field.unit or 0
end

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

-- Load config data
local fh = io.open(FILE_PATH .. "config.dat", "r")
if fh ~= nil then
	for line = 1, data.configCnt do
		local tmp = io.read(fh, config[line].c)
		if tmp ~= "" then
			config[line].v = config[line].d == nil and math.min(tonumber(tmp), config[line].x == nil and 1 or config[line].x) or tmp / 10
		end
	end
	io.close(fh)
end
config[15].v = 0
config[19].x = config[14].v == 0 and 2 or SMLCD and 1 or 2
config[19].v = math.min(config[19].x, config[19].v)
config[20].v = data.pitot and config[20].v or 0
local tmp = config[20].v == 0 and "GSpd" or "ASpd"
data.speed_id = getTelemetryId(tmp)
data.speedMax_id = getTelemetryId(tmp .. "+")
data.speed_unit = getTelemetryUnit(tmp)

return modes