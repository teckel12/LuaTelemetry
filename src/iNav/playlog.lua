local data, config, date = ...
local logfh
local raw = ""
local label

local function playLog(data, config, date)

	local function parseLine(line)
		local record = {}
		local pos = 1
		local i = 0
		while true do
			local c = string.sub(line, pos, pos)
			local startp, endp = string.find(line, ",", pos)
			if startp then
				record[i] = string.sub(line, pos, startp-1)
				pos = endp + 1
			else
				record[i] = string.sub(line,pos)
				break
			end
			i = i + 1
		end
		return record
	end

	if logfh == nil then
		logfh = io.open("/LOGS/" .. model.getInfo().name .. "-" .. date .. ".csv")
		data.showMax = false
	end
	if logfh ~= nil then

		-- Load next record
		local pos = nil
		local read = nil
		while pos == nil and read ~= "" do
			read = io.read(logfh, 255)
			raw = raw .. read
			pos = string.find(raw, "\n")
		end
		if read == "" then
			-- End of file
			io.close(logfh)
			data.doLogs = false
		else
			-- Parse record
			if pos == nil then
				pos = string.len(raw)
			end
			local line = string.sub(raw, 0, pos)
			raw = string.sub(raw, pos + 1)
			local record = parseLine(line)

			if label == nil then
				-- Define column labels
				label = {}
				for i = 0, #record do
					local unit = string.find(record[i], "%(")
					if unit ~= nil then
						label[string.lower(string.sub(record[i], 0, unit - 1))] = i
					else
						label[string.lower(record[i])] = i
						if record[i] == "Rud" then break end
					end
				end
			else
				-- Assign log values
				data.time = string.sub(record[label.time], 0, string.find(record[label.time], "%.") - 1)
				if data.crsf then
					--Crossfire
					--Date,Time,FM,1RSS(dB),2RSS(dB),RQly(%),RSNR(dB),RFMD,TPWR(mW),TRSS(dB),TQly(%),TSNR(dB),RxBt(V),Curr(A),Capa(mAh),GPS,GSpd(mph),Hdg(@),Alt(ft),Sats,Ptch(rad),Roll(rad),Yaw(rad),Rud,Ele,Thr,Ail,S1,6P,S2,LS,RS,SA,SB,SC,SD,SE,SF,SG,SH,LSW,TxBat(V)
					data.rssi = tonumber(record[label.rqly])
					data.tpwr = tonumber(record[label.tpwr])
					data.rfmd = tonumber(record[label.rfmd])
					data.pitch = math.deg(tonumber(record[label.ptch])) * 10
					data.roll = math.deg(tonumber(record[label.roll])) * 10
					data.batt = tonumber(record[label.rxbt])
					-- The following shenanigans are requred due to int rollover bugs in the Crossfire protocol for yaw and hdg
					local tmp = tonumber(record[label.yaw])
					if tmp < -0.27 then
						tmp = tmp + 0.27
					end
					data.heading = (math.deg(tmp) + 360) % 360
					-- Flight path vector
					if data.fpv_id > -1 then
						tmp = tonumber(record[label.hdg])
						data.fpv = ((tmp < 0 and tmp + 65.54 or tmp) * 10 + 360) % 360
					end
					data.fuel = tonumber(record[label.capa])
					data.fuelRaw = data.fuel
					if data.showFuel and config[23].v == 0 then
						data.fuel = math.max(math.min(math.floor((1 - (data.fuel) / config[27].v) * 100 + 0.5), 100), 0)
					end
					-- Don't know the flight mode with Crossfire, so assume armed and ACRO
					data.mode = 5
					data.satellites = tonumber(record[label.sats])
					--Fake HDOP based on satellite lock count and assume GPS fix when there's at least 6 satellites
					data.satellites = data.satellites + (math.floor(math.min(data.satellites + 10, 25) * 0.36 + 0.5) * 100) + (data.satellites >= 6 and 3000 or 0)
				else
					-- S.Port
					--Date,Time,Tmp1(@C),Tmp2(@C),A4(V),VFAS(V),Curr(A),Alt(ft),A2(V),RSSI(dB),RxBt(V),Fuel(%),VSpd(f/s),Hdg(@),Ptch(@),Roll(@),Dist(ft),GAlt(ft),GSpd(mph),GPS,Rud,Ele,Thr,Ail,S1,6P,S2,LS,RS,SA,SB,SC,SD,SE,SF,SG,SH,LSW,TxBat(V)
					data.rssi = tonumber(record[label.rssi])
					data.satellites = tonumber(record[label.tmp2])
					data.fuel = tonumber(record[label.fuel])
					data.heading = tonumber(record[label.hdg])
					if data.pitchRoll then
						data.pitch = tonumber(record[label.ptch])
						data.roll = tonumber(record[label.roll])
					else
						data.accx = tonumber(record[label.accx])
						data.accy = tonumber(record[label.accy])
						data.accz = tonumber(record[label.accz])
					end
					data.mode = tonumber(record[label.tmp1])
					data.rxBatt = tonumber(record[label.rxbt])
					data.gpsAlt = data.satellites > 1000 and tonumber(record[label.galt]) or 0
					data.distance = tonumber(record[label.dist])
					data.vspeed = tonumber(record[label.vspd])
					data.batt = tonumber(record[label.vfas])
				end
				data.altitude = tonumber(record[label.alt])
				if data.alt_id == -1 and data.gpsAltBase and data.gpsFix and data.satellites > 3000 then
					data.altitude = data.gpsAlt - data.gpsAltBase
				end
				data.speed = tonumber(record[label.gspd])
				if data.showCurr then
					data.current = tonumber(record[label.curr])
				end
				if data.a4_id > -1 then
					data.cell = tonumber(record[label.a4])
				else
					if data.batt / data.cells > config[29].v or data.batt / data.cells < 2.2 then
						data.cells = math.floor(data.batt / config[29].v) + 1
						print(data.cells)
					end
					data.cell = data.batt / data.cells
				end
				-- Dist doesn't have a known unit so the transmitter doesn't auto-convert
				if data.dist_unit == 10 then
					data.distance = math.floor(data.distance * 3.28084 + 0.5)
				end
				data.rssiLast = data.rssi
				data.gpsFix = false
				pos = string.find(record[label.gps], " ")
				if pos ~= nil then
					data.gpsLatLon = {
						lat = tonumber(string.sub(record[label.gps], 0, pos - 1)),
						lon = tonumber(string.sub(record[label.gps], pos + 1))
					}
					if data.satellites > 1000 then
						data.gpsFix = true
						data.lastLock = data.gpsLatLon
						if data.gpsHome ~= false and distCalc ~= nil then
							distCalc(data)
						end
					end
				end
				if data.distance > 0 then
					data.distanceLast = data.distance
				end
				data.telem = true
				data.telemFlags = 0
			end
		end
	else
		data.doLogs = false
	end
end

return playLog