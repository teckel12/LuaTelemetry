local config, data, frmt, FILE_PATH = ...

local fh = io.open(FILE_PATH .. "cfg/" .. model.getInfo().name .. ".dat", "w")
--[[
if fh == nil then
	data.msg = "Folder iNav/cfg missing"
	data.startup = 1
else
]]
if fh ~= nil then
	local floor, max = math.floor, math.max
	for i = 1, #config do
		if config[i].d == nil then
			io.write(fh, frmt("%0" .. config[i].c .. "d", max(config[i].v, 0)))
		else
			io.write(fh, floor(max(config[i].v, 0) * 10))
		end
	end
	io.close(fh)
end
data.configLast = data.configStatus
data.configStatus = 0

return 0
