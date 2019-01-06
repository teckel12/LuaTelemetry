local config, data, units, getTelemetryId, getTelemetryUnit, FILE_PATH = ...
local crsf = nil

-- Detect Crossfire
data.fm_id = getTelemetryId("FM") > -1 and getTelemetryId("FM") or getTelemetryId("PV")
if data.fm_id > -1 then
	crsf = loadfile(FILE_PATH .. "crsf.luac")(config, data, getTelemetryId)
	collectgarbage()
end

data.showCurr = data.curr_id > -1 and true or false
data.showFuel = data.fuel_id > -1 and true or false
data.showHead = data.hdg_id > -1 and true or false
data.pitot = getTelemetryId("ASpd") > -1 and true or false
data.distRef = data.dist_unit == 10 and 20 or 6
data.alt_unit = data.alt_id == -1 and data.gpsAlt_unit or data.alt_unit
data.dist_unit = data.dist_unit == 0 and 9 or data.dist_unit
data.pitchRoll = ((getTelemetryId("0430") > -1 or getTelemetryId("0008") > -1 or getTelemetryId("Ptch") > -1) and (getTelemetryId("0440") > -1 or getTelemetryId("0020") > -1 or getTelemetryId("Roll") > -1)) and true or false
if data.pitchRoll then
	local pitchSensor = getTelemetryId("Ptch") > -1 and "Ptch" or (getTelemetryId("0430") > -1 and "0430" or "0008")
	local rollSensor = getTelemetryId("Roll") > -1 and "Roll" or (getTelemetryId("0440") > -1 and "0440" or "0020")
	data.pitch_id = getTelemetryId(pitchSensor)
	data.roll_id = getTelemetryId(rollSensor)
	data.pitch = 0
	data.roll = 0
else
	data.accx_id = getTelemetryId("AccX")
	data.accy_id = getTelemetryId("AccY")
	data.accz_id = getTelemetryId("AccZ")
	data.accx = 0
	data.accy = 0
	data.accz = 1
end

-- Saved config adjustments
config[15].v = 0
config[19].x = config[14].v == 0 and 2 or SMLCD and 1 or 2
config[19].v = math.min(config[19].x, config[19].v)

-- Config special cases
config[6].v = data.alt_unit == 10 and 400 or 120
config[6].i = data.alt_unit == 10 and 10 or 1
config[6].a = units[data.alt_unit]
config[24].a = units[data.alt_unit]
config[20].v = data.pitot and config[20].v or 0

local tmp = config[20].v == 0 and "GSpd" or "ASpd"
data.speed_id = getTelemetryId(tmp)
data.speedMax_id = getTelemetryId(tmp .. "+")
data.speed_unit = getTelemetryUnit(tmp)
if data.dist_id == -1 then
	data.dist_unit = data.alt_unit
end

return crsf