local config, data, FILE_PATH = ...
local tmp

-- Load config for model
fh = io.open(FILE_PATH .. "cfg/" .. model.getInfo().name .. ".dat")
if fh ~= nil then
	for i = 1, #config do
		tmp = io.read(fh, config[i].c)
		if tmp ~= "" then
			config[i].v = config[i].d == nil and math.min(tonumber(tmp), config[i].x == nil and 1 or config[i].x) or tmp / 10
		end
	end
	io.close(fh)
end

return