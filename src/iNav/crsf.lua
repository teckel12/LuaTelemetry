local config, data, getTelemetryId = ...

data.crsf = true
data.rfmd_id = getTelemetryId("RFMD")
data.sat_id = getTelemetryId("Sats")
data.fuel_id = getTelemetryId("Capa")
data.batt_id = getTelemetryId("RxBt")
data.battMin_id = getTelemetryId("RxBt-")
data.tpwr_id = getTelemetryId("TPWR")
data.hdg_id = getTelemetryId("Yaw")
data.fpv_id = getTelemetryId("Hdg")
data.tpwr = 0
data.fpv = 0
data.fuelRaw = 0
config[7].v = 0
config[9].v = 0
config[14].v = 0
config[21].v = 2.5
config[22].v = 0
config[23].x = 1

-- Testing Crossfire
--[[
if data.simu then
	data.sat_id = getTelemetryId("Tmp2")
	data.fuel_id = getTelemetryId("Fuel")
	data.batt_id = getTelemetryId("VFAS")
	data.battMin_id = getTelemetryId("VFAS-")
	data.hdg_id = getTelemetryId("Hdg")
	data.fuel_id = getTelemetryId("Fuel")
	--data.showFuel = true
	data.pitch_id = -1
	data.roll_id = -1
end
]]

local function crsf(data)
	if data.rssi == 99 then
		data.rssi = data.rssi + 1
	end
	data.tpwr = getValue(data.tpwr_id)
	data.pitch = math.deg(getValue(data.pitch_id)) * 10
	data.roll = math.deg(getValue(data.roll_id)) * 10
	-- The following shenanigans are requred due to int rollover bugs in the Crossfire protocol for yaw and hdg
	local tmp = getValue(data.hdg_id)
	if tmp < -0.27 then
		tmp = tmp + 0.27
	end
	data.heading = (math.deg(tmp) + 360) % 360
	-- Flight path vector
	if data.fpv_id > -1 then
		data.fpv = ((getValue(data.fpv_id) < 0 and getValue(data.fpv_id) + 65.54 or getValue(data.fpv_id)) * 10 + 360) % 360
	end
	data.fuelRaw = data.fuel
	if data.showFuel and config[23].v == 0 then
		if data.fuelEst == -1 and data.cell > 0 then
			if data.fuel < 25 and config[29].v - data.cell >= 0.2 then
				data.fuelEst = math.max(math.min(1 - (data.cell - config[2].v + 0.1) / (config[29].v - config[2].v), 1), 0) * config[27].v
			else
				data.fuelEst = 0
			end
		end
		data.fuel = math.max(math.min(math.floor((1 - (data.fuel + data.fuelEst) / config[27].v) * 100 + 0.5), 100), 0)
	end
	data.fm = getValue(data.fm_id)
	data.modePrev = data.mode
	--Fake HDOP based on satellite lock count and assume GPS fix when there's at least 6 satellites
	data.satellites = data.satellites + (math.floor(math.min(data.satellites + 10, 25) * 0.36 + 0.5) * 100) + (data.satellites >= 6 and 1000 or 0)

	-- In Betaflight 4.0+, flight mode ends with '*' when not armed
	local bfArmed = true
	if string.sub(data.fm, -1) == "*" then
		bfArmed = false
		data.fm = string.sub(data.fm, 1, 4)
	end

	-- Testing Crossfire
	--[[
	if data.simu then
		data.mode = getValue(data.mode_id)
		local modeA = data.mode / 10000
		local modeB = data.mode / 1000 % 10
		local modeC = data.mode / 100 % 10
		local modeD = data.mode / 10 % 10
		local modeE = data.mode % 10
		if bit32.band(modeE, 2) == 2 then
			data.fm = "WAIT"
		elseif bit32.band(modeE, 4) == 4 then
			if bit32.band(modeA, 4) == 4 then
				data.fm = "!FS!"
			elseif bit32.band(modeB, 1) == 1 then
				data.fm = "RTH"
			elseif bit32.band(modeC, 4) == 4 then
				data.fm = "HOLD"
			elseif bit32.band(modeC, 2) == 2 then
				data.fm = "AH"
			elseif bit32.band(modeD, 2) == 2 then
				data.fm = "HOR"
			elseif bit32.band(modeD, 1) == 1 then
				data.fm = "ANGL"
			else
				data.fm = "ACRO"
			end
		elseif bit32.band(modeE, 1) == 1 then
			data.fm = "OK"
		end
	end
	]]

	--if data.fm == 0 or data.fm == "!ERR" or data.fm == "WAIT" then
	if data.fm == "!ERR" or data.fm == "WAIT" then
		-- Arming disabled
		data.mode = 2
	else
		-- Not in a waiting or error state so it must have a GPS home fix
		data.satellites = data.satellites + 2000
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
			data.mode = 1615
		elseif data.fm == "!FS!" then
			data.mode = 40004
		end
	end

	-- Testing Crossfire
	--[[
	if data.simu then
		data.fuel = getValue(data.fuel_id)
		data.heading = getValue(data.hdg_id)
		data.accx = getValue(data.accx_id)
		data.accy = getValue(data.accy_id)
		data.accz = getValue(data.accz_id)
		data.rxBatt = getValue(data.rxBatt_id)
		data.gpsAlt = data.satellites > 1000 and getValue(data.gpsAlt_id) or 0
		data.distance = getValue(data.dist_id)
		data.distanceMax = getValue(data.distMax_id)
		data.vspeed = getValue(data.vspeed_id)
	end
	]]

	return 0
end

return crsf