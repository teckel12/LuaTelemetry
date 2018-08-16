local config, data, units = ...

local function getTelemetryId(name)
	local field = getFieldInfo(name)
	return field and field.id or -1
end

local function getTelemetryUnit(name)
	local field = getFieldInfo(name)
	return (field and field.unit <= 10) and field.unit or 0
end

data.showCurr = data.current_id > -1 and true or false
data.showHead = data.heading_id > -1 and true or false
data.pitot = getTelemetryId("ASpd") > -1 and true or false
data.distPos = data.showCurr and 17 or 21
data.speedPos = data.showCurr and 25 or 33
data.battPos1 = data.showCurr and 49 or 45
data.battPos2 = data.showCurr and 49 or 41
data.distRef = data.distance_unit == 10 and 20 or 6
data.altitude_unit = data.altitude_id == -1 and data.gpsAlt_unit or data.altitude_unit
data.distance_unit = data.distance_unit == 0 and 9 or data.distance_unit
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
config[6].v = data.altitude_unit == 10 and 400 or 120
config[6].i = data.altitude_unit == 10 and 10 or 1
config[6].a = units[data.altitude_unit]
config[24].a = units[data.altitude_unit]
config[20].v = data.pitot and config[20].v or 0
tmp = config[20].v == 0 and "GSpd" or "ASpd"
data.speed_id = getTelemetryId(tmp)
data.speedMax_id = getTelemetryId(tmp .. "+")
data.speed_unit = getTelemetryUnit(tmp)

return 0