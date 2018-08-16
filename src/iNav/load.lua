local config, FILE_PATH = ...

-- Sort config menus
local configCnt = 0
for i, value in ipairs(config) do
	for ii, value2 in ipairs(config) do
		if i == value2.o then
			value.z = ii
			value2.o = nil
		end
	end
	configCnt = configCnt + 1
end

-- Load config data
local fh = io.open(FILE_PATH .. "config.dat", "r")
if fh ~= nil then
	for line = 1, configCnt do
		local tmp = io.read(fh, config[line].c)
		if tmp ~= "" then
			config[line].v = config[line].d == nil and math.min(tonumber(tmp), config[line].x == nil and 1 or config[line].x) or tmp / 10
		end
	end
	io.close(fh)
end

return configCnt