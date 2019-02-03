local config, data, getTelemetryId = ...

local function getCrsfUnit(n)
	local field = getFieldInfo(n)
	return field and field.unit or 0
end

data.crsf = true
data.rssi_id = getTelemetryId("RQly")
data.rssiMin_id = getTelemetryId("RQly-")
data.rfmd_id = getTelemetryId("RFMD")
data.sat_id = getTelemetryId("Sats")
data.fuel_id = getTelemetryId("Capa")
-- Testing Crossfire
--if data.simu then data.fuel_id = getTelemetryId("Fuel") end
data.batt_id = getTelemetryId("RxBt")
data.battMin_id = getTelemetryId("RxBt-")
data.tpwr_id = getTelemetryId("TPWR")
data.hdg_id = getTelemetryId("Yaw")
--data.rssiMin = 99
data.tpwr = 0
config[7].v = 0
config[9].v = 0
config[14].v = 0
config[21].v = 2.5
config[22].v = 0
config[23].x = 1

local function crsf(data)
	data.tpwr = getValue(data.tpwr_id)
	data.pitch = math.deg(getValue(data.pitch_id)) * 10
	data.roll = math.deg(getValue(data.roll_id)) * 10
	--data.heading = math.deg(getValue(data.hdg_id))
	-- The following is done due to an int rollover bug in the Crossfire protocol
	local tmp = getValue(data.hdg_id)
	if tmp < -0.27 then
		tmp = tmp + 0.27
	end
	data.heading = math.deg(tmp)
	if data.showFuel and config[23].v == 0 then
		data.fuel = math.min(math.floor((1 - data.fuel / config[27].v) * 100 + 0.5), 100)
	end
	data.fm = getValue(data.fm_id)
	data.modePrev = data.mode
	data.satellites = data.satellites + (math.floor(math.min(data.satellites + 10, 25) * 0.36 + 0.5) * 100)

	-- In Betaflight, flight mode ends with '*' when not armed
	local bfArmed = true
	if string.sub(data.fm, -1) == "*" then
		bfArmed = false
		data.fm = string.sub(data.fm, 1, 4)
	end

	if data.fm == 0 or data.fm == "!ERR" or data.fm == "WAIT" then
		-- Arming disabled
		data.mode = 2
	else
		-- Not in a waiting or error state so it must have a satellite lock and home position set
		data.satellites = data.satellites + 3000
		-- Home reset, use last mode
		if data.fm == "HRST" then
			data.satellites = data.satellites + 4000
			data.mode = data.modePrev
		-- Not armed but ready to arm
		elseif data.fm == "OK" or bfArmed == false then
			data.mode = 1
		-- Armed modes
		elseif data.fm == "ACRO" then
			data.mode = 5
		elseif data.fm == "ANGL" or data.fm == "STAB" then
			data.mode = 15
		elseif data.fm == "HOR" then
			data.mode = 25
		elseif data.fm == "MANU" then
			data.mode = 45
		elseif data.fm == "AH" then
			data.mode = 215
		elseif data.fm == "HOLD" then
			data.mode = 415
		elseif data.fm == "CRS" then
			data.mode = 8015
		elseif data.fm == "3CRS" then
			data.mode = 8215
		elseif data.fm == "WP" then
			data.mode = 2015
		elseif data.fm == "RTH" then
			data.mode = 1015
		elseif data.fm == "!FS!" then
			data.mode = 40004
		end
	end

	return 0
end

return crsf