local config, data, FILE_PATH = ...

-- Load config for model
fh = io.open(FILE_PATH .. "cfg/" .. model.getInfo().name .. ".dat")
if fh ~= nil then
	for i = 1, #config do
		local tmp = io.read(fh, config[i].c)
		if tmp ~= "" then
			config[i].v = config[i].d == nil and math.min(tonumber(tmp), config[i].x == nil and 1 or config[i].x) or tmp * 0.1
		end
	end
	io.close(fh)
end

local log = getDateTime()
local path = "/LOGS/" .. string.gsub(model.getInfo().name, " ", "_") .. "-20"
config[34].x = -1

for days = 1, 15 do
	local logDate = string.sub(log.year, 3) .. "-" .. string.sub("0" .. log.mon, -2) .. "-" .. string.sub("0" .. log.day, -2)
	local fh = io.open(path .. logDate .. ".csv")
	if fh ~= nil then
		io.close(fh)
		config[34].x = config[34].x + 1
		config[34].l[config[34].x] = logDate
		collectgarbage()
		if config[34].x == 5 then break end
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
end

return