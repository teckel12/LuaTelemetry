local iNav = loadfile("/SCRIPTS/TELEMETRY/iNav.luac")()

-- Run when first started
local function create()
	iNav()
	return 0
end

-- Called upon registration and at change of settings in the telemetry setup menu
local function update()
	return 0
end

return { name = "iNAV", options = {}, create = create, update = update, refresh = iNav.run, background = iNav.background }