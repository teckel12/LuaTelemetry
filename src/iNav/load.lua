local config, data, FILE_PATH = ...
local i, ii, tmp

-- Sort config menus
for i, value in ipairs(config) do
	for ii, value2 in ipairs(config) do
		if i == value2.o then
			value.z = ii
			value2.o = nil
		end
	end
end

--[[ Load global preferences
	1 = Aircraft symbol (Horus only):		0 = Boeing/Airbus, 1 = Classic, 2 = Garmin1, 3 = Garmin2, 4 = Dynon, 5 = Waterline
	2 = Radar home posiion (Horus only):	0 = Adjust to fit, 1 = Fixed in center
	3 = Default orientation:				0 = Launch/pilot-based, 1 = Compass-based
]]
local prefs = {0, 0, 0}
local fh = io.open(FILE_PATH .. "cfg/prefs.dat")
if fh ~= nil then
	for i = 1, #prefs do
		prefs[i] = tonumber(io.read(fh, 1))
	end
	io.close(fh)
end

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

return prefs