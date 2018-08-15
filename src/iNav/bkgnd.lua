local data, reset, config, FLASH = ...

data.rssi = getValue(data.rssi_id)
if data.rssi > 0 then
	data.telemetry = true
	data.telemFlags = 0
	data.mode = getValue(data.mode_id)
	data.rxBatt = getValue(data.rxBatt_id)
	data.satellites = getValue(data.satellites_id)
	data.gpsAlt = data.satellites > 1000 and getValue(data.gpsAlt_id) or 0
	data.heading = getValue(data.heading_id)
	data.altitude = getValue(data.altitude_id)
	if data.altitude_id == -1 and data.gpsAltBase and data.gpsFix and data.satellites > 3000 then
		data.altitude = data.gpsAlt - data.gpsAltBase
	end
	data.distance = getValue(data.distance_id)
	data.speed = getValue(data.speed_id)
	if data.showCurr then
		data.current = getValue(data.current_id)
		data.currentMax = getValue(data.currentMax_id)
		data.fuel = getValue(data.fuel_id)
	end
	data.altitudeMax = getValue(data.altitudeMax_id)
	data.distanceMax = getValue(data.distanceMax_id)
	data.speedMax = getValue(data.speedMax_id)
	data.batt = getValue(data.batt_id)
	data.battMin = getValue(data.battMin_id)
	data.cells = (data.batt / data.cells > 4.3) and math.floor(data.batt / 4.3) + 1 or data.cells
	data.cell = data.batt / data.cells
	data.cellMin = data.battMin / data.cells
	data.rssiMin = getValue(data.rssiMin_id)
	data.vspeed = getValue(data.vspeed_id)
	if data.pitchRoll then
		data.pitch = getValue(data.pitch_id)
		data.roll = getValue(data.roll_id)
	else
		data.accx = getValue(data.accx_id)
		data.accy = getValue(data.accy_id)
		data.accz = getValue(data.accz_id)
	end
	data.rssiLast = data.rssi
	local gpsTemp = getValue(data.gpsLatLon_id)
	if type(gpsTemp) == "table" and gpsTemp.lat ~= nil and gpsTemp.lon ~= nil then
		data.gpsLatLon = gpsTemp
		if data.satellites > 1000 and gpsTemp.lat ~= 0 and gpsTemp.lon ~= 0 then
			data.gpsFix = true
			config[15].l[0] = gpsTemp
		end
	end
	-- Dist doesn't have a known unit so the transmitter doesn't auto-convert
	if data.distance_unit == 10 then
		data.distance = math.floor(data.distance * 3.28084 + 0.5)
		data.distanceMax = data.distanceMax * 3.28084
	end
	if data.distance > 0 then
		data.distanceLast = data.distance
	end
else
	data.telemetry = false
	data.telemFlags = FLASH
end
data.txBatt = getValue(data.txBatt_id)
data.throttle = getValue(data.throttle_id)

return 0