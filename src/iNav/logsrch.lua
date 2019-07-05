local log = getDateTime()
local logCnt = 0
local days = 0
local results = {}
while logCnt < 5 and days < 16 do
	local logDate = string.format("%04d-%02d-%02d", log.year, log.mon, log.day)
	local fh = io.open("/LOGS/" .. model.getInfo().name .. "-" .. logDate .. ".csv")
	if fh ~= nil then
		io.close(fh)
		results[logCnt] = logDate
		logCnt = logCnt + 1
	end
	log.day = log.day - 1
	if log.day == 0 then
		log.day = 31
		log.mon = log.mon - 1
		if log.mon == 0 then
			log.mon = 12
			log.year = log.year - 1
		end
	end
	days = days + 1
end

return results