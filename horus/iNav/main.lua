WIDGET = true

local function getTelemetryUnit(n)
	local field = getFieldInfo(n)
	return (field and field.unit <= 10) and field.unit or 0
end

local wait = true
while wait == true do
	--[[
	local general = getGeneralSettings()
	if general.battMax > 5 then
		wait = false
	end
	]]
	local alt_unit = getTelemetryUnit("Alt")
	if alt_unit == 10 then
		wait = false
	end
end

local iNav = loadfile("/SCRIPTS/TELEMETRY/iNav.luac")()

local refresh = iNav.run
local bg = iNav.background

-- Run when first started
local function create()
	return 0
end

-- Called upon registration and at change of settings in the telemetry setup menu
local function update()
	return 0
end

return { name = "iNAV", options = {}, create = create, update = update, refresh = refresh, background = bg }