local config, data, FILE_PATH = ...

-- Sort config menus
local i, ii
for i, value in ipairs(config) do
	for ii, value2 in ipairs(config) do
		if i == value2.o then
			value.z = ii
			value2.o = nil
		end
	end
end

-- Copy config file (remove after several revisions)
local fh = io.open(FILE_PATH .. "config.dat", "r")
if fh ~= nil then
	local tmp = io.read(fh, 1024)
	io.close(fh)
	fh = io.open(FILE_PATH .. "cfg/" .. model.getInfo().name .. ".dat", "w")
	if fh == nil then
		data.msg = "Folder iNav/cfg missing"
		data.startup = 1
	else
		io.write(fh, tmp)
		io.close(fh)
	end
end

-- Load config data
fh = io.open(FILE_PATH .. "cfg/" .. model.getInfo().name .. ".dat", "r")
if fh ~= nil then
	for line = 1, #config do
		local tmp = io.read(fh, config[line].c)
		if tmp ~= "" then
			config[line].v = config[line].d == nil and math.min(tonumber(tmp), config[line].x == nil and 1 or config[line].x) or tmp / 10
		end
	end
	io.close(fh)
end

return 0
