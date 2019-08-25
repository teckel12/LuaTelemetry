local config, data, FILE_PATH = ...

local fh = io.open(FILE_PATH .. "cfg/" .. model.getInfo().name .. ".dat", "w")
--[[
if fh == nil then
	data.msg = "Folder iNav/cfg missing"
	data.startup = 1
else
]]
if fh ~= nil then
	local floor = math.floor
	local format = string.format
	for line = 1, #config do
		if config[line].d == nil then
			io.write(fh, string.format("%0" .. config[line].c .. "d", config[line].v))
		else 
			io.write(fh, floor(config[line].v * 10))
		end
	end
	io.close(fh)
end
data.configLast = data.configStatus
data.configStatus = 0

return 0