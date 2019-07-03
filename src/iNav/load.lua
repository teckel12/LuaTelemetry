local config, data, FILE_PATH = ...

-- Load config for model
fh = io.open(FILE_PATH .. "cfg/" .. model.getInfo().name .. ".dat")
if fh ~= nil then
	for i = 1, #config do
		local tmp = io.read(fh, config[i].c)
		if tmp ~= "" then
			config[i].v = config[i].d == nil and math.min(tonumber(tmp), config[i].x == nil and 1 or config[i].x) or tmp / 10
		end
	end
	io.close(fh)
end

-- Populate log files
local log = getDateTime()
local logCnt = 0
local days = 0
while logCnt < 5 and days < 16 do
	local logDate = log.year .. string.format("-%02d-%02d", log.mon, log.day)
	local fh = io.open("/LOGS/" .. model.getInfo().name .. "-" .. logDate .. ".csv")
	if fh ~= nil then
		io.close(fh)
		config[34].l[logCnt] = logDate
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
config[34].x = logCnt - 1

return