local data, date = ...
local logfh
local raw = ""
local label

--Date,Time,Tmp1(@C),Tmp2(@C),A4(V),VFAS(V),Curr(A),Alt(ft),A2(V),RSSI(dB),RxBt(V),Fuel(%),VSpd(f/s),Hdg(@),Ptch(@),Roll(@),Dist(ft),GAlt(ft),GSpd(mph),GPS,Rud,Ele,Thr,Ail,S1,6P,S2,LS,RS,SA,SB,SC,SD,SE,SF,SG,SH,LSW,TxBat(V)

local function playLog(data, date)

	local function parseLine(line)
		local res = {}
		local pos = 1
		local i = 0
		local sep = ','
		while true do
			local c = string.sub(line, pos, pos)
			local startp, endp = string.find(line, sep, pos)
			if startp then
				res[i] = string.sub(line, pos, startp-1)
				pos = endp + 1
			else
				res[i] = string.sub(line,pos)
				break
			end
			i = i + 1
		end
		return res
	end

	if logfh == nil then
		logfh = io.open("/LOGS/" .. model.getInfo().name .. "-" .. date .. ".csv")
	end
	if logfh ~= nil then
		local pos = nil
		local read = nil
		while pos == nil and read ~= "" do
			local read = io.read(logfh, 255)
			raw = raw .. read
			pos = string.find(raw, "\n")
		end
		if pos == nil then
			pos = string.len(raw)
		end
		local line = string.sub(raw, 0, pos)
		raw = string.sub(raw, pos + 1)
		local res = parseLine(line)
		if label == nil then
			label = res
			for i = 1, #label do
				--label[i]
			end
		end
		print(line)
		print(res[0])
		print(res[1])
		print(res[2])

		io.close(logfh)
		data.doLogs = false
		print(date)
		print(pos)

	else

	end
end

return playLog

--[[
data.rssi, data.rssiLow, data.rssiCrit = getRSSI()
if data.rssi > 0 then
	data.telem = true
	data.telemFlags = 0
	data.rssiMin = math.min(data.rssiMin, data.rssi)
	data.satellites = getValue(data.sat_id)
	if data.showFuel then
		data.fuel = getValue(data.fuel_id)
	end
	if data.crsf then
		crsf(data)
	else
		data.heading = getValue(data.hdg_id)
		if data.pitchRoll then
			data.pitch = getValue(data.pitch_id)
			data.roll = getValue(data.roll_id)
		else
			data.accx = getValue(data.accx_id)
			data.accy = getValue(data.accy_id)
			data.accz = getValue(data.accz_id)
		end
		data.mode = getValue(data.mode_id)
		data.rxBatt = getValue(data.rxBatt_id)
		data.gpsAlt = data.satellites > 1000 and getValue(data.gpsAlt_id) or 0
		data.distance = getValue(data.dist_id)
		data.distanceMax = getValue(data.distMax_id)
		-- Dist doesn't have a known unit so the transmitter doesn't auto-convert
		if data.dist_unit == 10 then
			data.distance = math.floor(data.distance * 3.28084 + 0.5)
			data.distanceMax = data.distanceMax * 3.28084
		end
		data.vspeed = getValue(data.vspeed_id)
	end
	data.altitude = getValue(data.alt_id)
	if data.alt_id == -1 and data.gpsAltBase and data.gpsFix and data.satellites > 3000 then
		data.altitude = data.gpsAlt - data.gpsAltBase
	end
	data.speed = getValue(data.speed_id)
	if data.showCurr then
		data.current = getValue(data.curr_id)
		data.currentMax = getValue(data.currMax_id)
	end
	data.altitudeMax = getValue(data.altMax_id)
	data.speedMax = getValue(data.speedMax_id)
	data.batt = getValue(data.batt_id)
	data.battMin = getValue(data.battMin_id)
	if data.a4_id > -1 then
		data.cell = getValue(data.a4_id)
		data.cellMin = getValue(data.a4Min_id)
	else
		if data.batt / data.cells > config[29].v or data.batt / data.cells < 2.2 then
			data.cells = math.floor(data.batt / config[29].v) + 1
		end
		data.cell = data.batt / data.cells
		data.cellMin = data.battMin / data.cells
	end
	data.rssiLast = data.rssi
	data.gpsFix = false
	local gpsTemp = getValue(data.gpsLatLon_id)
	if type(gpsTemp) == "table" and gpsTemp.lat ~= nil and gpsTemp.lon ~= nil then
		data.gpsLatLon = gpsTemp
		if data.satellites > 1000 and gpsTemp.lat ~= 0 and gpsTemp.lon ~= 0 then
			data.gpsFix = true
			data.lastLock = gpsTemp
			if data.gpsHome ~= false and distCalc ~= nil then
				distCalc(data)
			end
		end
	end
	if data.distance > 0 then
		data.distanceLast = data.distance
	end
else
	data.telem = false
	data.telemFlags = FLASH
end
data.txBatt = getValue(data.txBatt_id)
data.throttle = getValue(data.thr_id)
]]