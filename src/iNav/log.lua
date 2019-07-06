local env, FILE_PATH = ...

local logfh, label, seek, fake
local raw = ""

local function playLog(data, config, distCalc, date)

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
		logfh = io.open("/LOGS/" .. model.getInfo().name .. "-20" .. date .. ".csv")
		fake = loadScript(FILE_PATH .. (data.crsf and "log_c" or "log_s"), env)()
		data.showMax = false
		seek = 0
	end
	if logfh ~= nil then

		-- Load next record
		local pos = string.find(raw, "\n")
		local read = nil
		while pos == nil and read ~= "" do
			read = io.read(logfh, 255)
			raw = raw .. read
			pos = string.find(raw, "\n")
			seek = seek + 255
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
						if record[i] == "Rud" then break end
						label[string.lower(record[i])] = i
					end
				end
			else
				-- Assign log values
				data.time = string.sub(record[label.time], 0, string.find(record[label.time], "%.") - 1)

				fake(data, config, record, label)

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