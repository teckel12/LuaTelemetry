WIDGET = true

local iNav

-- Run when first started
local function create()
	iNav = loadfile("/SCRIPTS/TELEMETRY/iNav.luac")()
	return 0
end

-- Called upon registration and at change of settings in the telemetry setup menu
local function update()
	return 0
end

local function refresh()
	iNav.run()
	return 0
end

local function bg()
	iNav.background()
	return 0
end

return { name = "iNAV", options = {}, create = create, update = update, refresh = refresh, background = bg }