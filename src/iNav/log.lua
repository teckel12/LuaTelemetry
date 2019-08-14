local env, FILE_PATH = ...

local logfh, label, record, fake, start, starti, time, timel, seek
local pause = false
local raw = ""
local ele_id = getFieldInfo("ele").id
local ail_id = getFieldInfo("ail").id

local function toNum(x)
	if x == nil then return 0 else return tonumber(x) end
end

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

local function playLog(data, config, distCalc, date, NEXT, PREV)

	local gpsTemp = nil

	if logfh == nil then
		logfh = io.open("/LOGS/" .. string.gsub(model.getInfo().name, " ", "_") .. "-20" .. date .. ".csv")
		fake = loadScript(FILE_PATH .. "log_" .. (data.crsf and "c" or "s") .. ".luac", env)()
		data.showMax = false
		seek = 0
	end
	if logfh ~= nil then
		local pos = string.find(raw, "\n")
		local read = nil
		local ele = getValue(ele_id) * 0.005
		local ail = getValue(ail_id)
		local speed = 0
		if ail > 940 and seek > 2 then
			-- Pause
			pause = true
			start = nil
		elseif math.abs(ele) > 1 or (start ~= nil and time ~= start and (getTime() - starti) - (time - start) * 100 > 10) then
			-- Seek forward/back
			if not pause or ele < 0 then
				speed = ele > 0 and math.floor(ele) or math.ceil(ele) - 2
				seek = math.max(seek + speed, 0)
				io.seek(logfh, seek * 400)
				raw = ""
				pos = nil
				start = nil
				pause = false
				while pos == nil and read ~= "" do
					read = io.read(logfh, 400)
					raw = raw .. read
					pos = string.find(raw, "\n")
					seek = seek + 1
				end
				if pos ~= nil then
					raw = string.sub(raw, pos + 1)
					pos = string.find(raw, "\n")
				end
			end
		elseif ail < -940 then
			-- Exit playback
			io.close(logfh)
			data.doLogs = false
			return 0
		elseif pause and ail <= 940 then
			-- Resume
			pause = false
		elseif timel ~= nil and time - timel > 2 then
			-- Jump to next log segment
			start = nil
		end

		-- Load next record
		if not pause and (start == nil or speed ~= 0 or (time - start) * 100 < getTime() - starti) then
			while pos == nil and read ~= "" do
				read = io.read(logfh, 400)
				raw = raw .. read
				pos = string.find(raw, "\n")
			end
			if read == "" then
				-- End of file
				pause = true
			else
				-- Parse record
				seek = seek + 1
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
			fake(data, config, record, label, toNum)

			-- Sync playback to clock
			timel = time
			time = toNum(string.sub(record[label.time], 1, 2)) * 3600 + toNum(string.sub(record[label.time], 4, 5)) * 60 + toNum(string.sub(record[label.time], 7))
			if start == nil then
				start = time
				starti = getTime()
			end

			-- Fake telemetry that's similar on Crossfire and S.Port
			data.time = string.sub(record[label.time], 0, 8)
			data.altitude = toNum(record[label.alt])
			if data.alt_id == -1 and data.gpsAltBase and data.gpsFix and data.satellites > 3000 then
				data.altitude = data.gpsAlt - data.gpsAltBase
			end
			data.speed = toNum(record[label.gspd])
			data.vspeed = toNum(record[label.vspd])
			if data.showCurr then
				data.current = toNum(record[label.curr])
			end
			if data.a4_id > -1 then
				data.cell = toNum(record[label.a4])
			end
			pos = string.find(record[label.gps], " ")
			if pos ~= nil then
				gpsTemp = {
					lat = toNum(string.sub(record[label.gps], 0, pos - 1)),
					lon = toNum(string.sub(record[label.gps], pos + 1))
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