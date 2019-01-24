local config, data, getTelemetryId = ...

local function getCrsfUnit(n)
	local field = getFieldInfo(n)
	return field and field.unit or 0
end

data.crsf = true
data.rssi_id = getTelemetryId("RSNR")
data.rssiMin_id = getTelemetryId("RSNR-")
data.rfmd_id = getTelemetryId("RFMD")
data.sat_id = getTelemetryId("Sats")
data.fuel_id = getTelemetryId("Capa")
data.batt_id = getTelemetryId("RxBt")
data.battMin_id = getTelemetryId("RxBt-")
data.tpwr_id = getTelemetryId("TPWR")
data.hdg_id = getTelemetryId("Yaw")
data.rssiMin = 99
data.rssiLow = 20
data.rssiCrit = 9
data.tpwr = 0
config[23].v = 1
config[7].v = 0
config[9].v = 0
config[14].v = 0
config[21].v = 2.5
config[22].v = 0

local function crsf(data)
	if data.rssi > 0 then
		data.rssiMin = math.min(data.rssiMin, data.rssi)
	end
	data.tpwr = getValue(data.tpwr_id)
	data.pitch = math.deg(getValue(data.pitch_id)) * 10
	data.roll = math.deg(getValue(data.roll_id)) * 10
	--data.heading = math.deg(getValue(data.hdg_id))
	-- The following is done due to a int rollover bug with Crossfire
	local tmp = getValue(data.hdg_id)
	if tmp < -0.27 then
		tmp = tmp + 0.27
	end
	data.heading = math.deg(tmp)
	data.fm = getValue(data.fm_id)
	data.modePrev = data.mode
	data.satellites = data.satellites + (math.floor(math.min(data.satellites + 10, 25) * 0.36 + 0.5) * 100)
	if data.fm == 0 or data.fm == "!ERR" or data.fm == "WAIT" then
		-- Arming disabled
		data.mode = 2
	else
		data.satellites = data.satellites + 3000
		if data.fm == "HRST" then
			data.satellites = data.satellites + 4000
			data.mode = data.modePrev
		else
			if data.fm == "OK" then
				-- Ready to arm
				data.mode = 1
			else
				-- Armed
				data.mode = 5
				if data.fm == "3CRS" then
					data.mode = data.mode + 8200
				elseif data.fm == "CRS" then
					data.mode = data.mode + 8000
				elseif data.fm == "HOLD" then
					data.mode = data.mode + 410
				elseif data.fm == "AH" then
					data.mode = data.mode + 210
				elseif data.fm == "ANGL" then
					data.mode = data.mode + 10
				elseif data.fm == "HOR" then
					data.mode = data.mode + 20
				elseif data.fm == "MANU" then
					data.mode = data.mode + 40
				end
				if data.fm == "RTH" then
					data.mode = data.mode + 1000
				end
				if data.fm == "WP" then
					data.mode = data.mode + 2000
				end
				if data.fm == "!FS!" then
					data.mode = data.mode + 40000
				end
			end
		end
	end
	return 0
end

return crsf