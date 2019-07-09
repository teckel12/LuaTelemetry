local env, FILE_PATH = ...

local logfh, label, record, fake, start, starti, time, timel, seek
local raw = ""

local function playLog(data, config, distCalc, date)

	local gpsTemp = nil

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
		fake = loadScript(FILE_PATH .. "log_" .. (data.crsf and "c" or "s") .. ".luac", env)()
		data.showMax = false
		seek = 0
	end
	if logfh ~= nil then
		-- Load next record
		local pos = string.find(raw, "\n")
		local read = nil
		-- Jump to next log segment
		if timel ~= nil and time - timel > 2 then
			start = nil
		end
		if start == nil or time - start < (getTime() - starti) / 100 then
			if data.event == EVT_ROT_RIGHT then
				io.seek(logfh, seek * 200 + 1980)
				read = io.read(logfh, 200)
				pos = string.find(read, "\n")
				if pos ~= nil then
					raw = string.sub(read, pos + 1)
					pos = nil
					seek = seek + 10
				end
			end
			while pos == nil and read ~= "" do
				read = io.read(logfh, 200)
				raw = raw .. read
				pos = string.find(raw, "\n")
				seek = seek + 1
			end
			-- End of file, or cancel playback
			if read == "" or data.event == EVT_EXIT_BREAK then
				io.close(logfh)
				data.doLogs = false
				return 0
			else
				-- Parse record
				if pos == nil then
					pos = string.len(raw)
				end
				local line = string.sub(raw, 0, pos)
				raw = string.sub(raw, pos + 1)
				record = parseLine(line)
			end
		end
		-- Define column labels
		if label == nil then
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
			-- Fake telemetry specific to Crossfire or S.Port
			fake(data, config, record, label)

			-- Sync playback to clock
			timel = time
			time = tonumber(string.sub(record[label.time], 1, 2)) * 3600 + tonumber(string.sub(record[label.time], 4, 5)) * 60 + tonumber(string.sub(record[label.time], 7))
			if start == nil then
				start = time
				starti = getTime()
			end

			-- Fake telemetry that's similar on Crossfire and S.Port
			data.time = string.sub(record[label.time], 0, 8)
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
			end
			pos = string.find(record[label.gps], " ")
			if pos ~= nil then
				gpsTemp = {
					lat = tonumber(string.sub(record[label.gps], 0, pos - 1)),
					lon = tonumber(string.sub(record[label.gps], pos + 1))
				}
			end
			data.telem = true
			data.telemFlags = 0
		end
	else
		data.doLogs = false
	end

	return gpsTemp
end

return playLog