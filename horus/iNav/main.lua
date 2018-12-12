local iNav = loadfile("/SCRIPTS/TELEMETRY/iNav.luac")()
--local iNav = loadScript("/SCRIPTS/TELEMETRY/iNav.luac", "tc")()

-- Run when first started
local function create()
	return 0
end

-- Called upon registration and at change of settings in the telemetry setup menu
local function update()
	return 0
end

return { name = "iNAV", options = {}, create = create, update = update, refresh = iNav.run, background = iNav.background }