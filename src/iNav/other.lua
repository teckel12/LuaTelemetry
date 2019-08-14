local config, data, units, getTelemetryId, getTelemetryUnit, FILE_PATH, env, SMLCD, FLASH = ...
local crsf = nil

-- Detect Crossfire
data.fm_id = getTelemetryId("FM") > -1 and getTelemetryId("FM") or getTelemetryId("PV")

-- Testing Crossfire
--if data.simu then data.fm_id = 1 end

if data.fm_id > -1 then
	crsf = loadScript(FILE_PATH .. "crsf.luac", env)(config, data, getTelemetryId, FLASH)
	collectgarbage()
end

data.showCurr = data.curr_id > -1
data.showFuel = data.fuel_id > -1
data.showHead = data.hdg_id > -1
data.pitot = getTelemetryId("ASpd") > -1
data.distRef = data.dist_unit == 10 and 20 or 6
data.alt_unit = data.alt_id == -1 and data.gpsAlt_unit or data.alt_unit
data.dist_unit = data.dist_unit == 0 and 9 or data.dist_unit
data.pitchRoll = ((getTelemetryId("0430") > -1 or getTelemetryId("0008") > -1 or getTelemetryId("Ptch") > -1) and (getTelemetryId("0440") > -1 or getTelemetryId("0020") > -1 or getTelemetryId("Roll") > -1))
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

-- Config adjustments and special cases
-- Config options: v=default Value / x=maX
-- 6=Max Altitude / 15=GPS (last fix) / 20=Speed Sensor / 25=View Mode / 28=Altitude Graph
if config[6].v == -1 then
	config[6].v = data.alt_unit == 10 and 400 or 120
end
config[19].x = SMLCD and ((config[14].v == 1 or data.crsf) and 1 or 2) or 2
config[19].v = math.min(config[19].x, config[19].v)
config[20].v = data.pitot and config[20].v or 0
if config[28].v == 0 then
	config[25].x = 2
	config[25].v = math.min(config[25].v, 2)
end
config[34].v = 0

local tmp = config[20].v == 0 and "GSpd" or "ASpd"
data.speed_id = getTelemetryId(tmp)
data.speedMax_id = getTelemetryId(tmp .. "+")
data.speed_unit = getTelemetryUnit(tmp)
if data.speed_unit == 0 then data.speed_unit = 7 end
if data.dist_id == -1 then
	data.dist_unit = data.alt_unit
end

-- Use timer3 for flight reset detection
model.setTimer(2, { mode = 0, start = 0, value = 3600, countdownBeep = 0, minuteBeep = false, persistent = 0} )

-- Calculate distance to home if sensor is missing or in simlulator
local distCalc = nil
if data.dist_id == -1 or data.simu then
	function distCalc(data)
		--[[ Spherical-Earth math: More accurate if the Earth was a sphere, but it's not so who cares?
		local rad = math.rad
		local o1 = rad(data.gpsHome.lat)
		local o2 = rad(data.gpsLatLon.lat)
		data.distance = math.acos(math.sin(o1) * math.sin(o2) + math.cos(o1) * math.cos(o2) * math.cos(rad(data.gpsLatLon.lon) - rad(data.gpsHome.lon))) * 6371009
		]]
		-- Flat-Earth math
		local x = math.abs(math.rad(data.gpsLatLon.lon - data.gpsHome.lon) * math.cos(math.rad(data.gpsHome.lat)))
		local y = math.abs(math.rad(data.gpsLatLon.lat - data.gpsHome.lat))
		data.distance = math.sqrt(x * x + y * y) * 6371009
		data.distanceMax = math.max(data.distMaxCalc, data.distance)
		data.distMaxCalc = data.distanceMax
		-- If distance is in feet, convert
		if data.dist_unit == 10 then
			data.distance = math.floor(data.distance * 3.28084 + 0.5)
			data.distanceMax = data.distanceMax * 3.28084
		end
		return 0
	end
end

return crsf, distCalc