local build = ...
local iNav
local options = {
	{ "Restore", BOOL, 0},
	{ "Text", COLOR, 0},
	{ "Warning", COLOR, 65504}
}
WIDGET = true
iNavZone = {
	options = options
}

-- This function is runned once at the creation of the widget
local function create(zone, options)
	iNavZone = { zone = zone, options = options }
	if zone.w > 450 and zone.h > 250 then
		iNavZone.zone.fullscreen = true
	else
		iNavZone.zone.fullscreen = false
	end
	iNav = loadfile("/SCRIPTS/TELEMETRY/iNav.luac")()
	return iNavZone
end

-- This function allow updates when you change widgets settings
local function update(iNavZone, options)
	iNavZone.options = options
end

-- Called periodically when custom telemetry screen containing widget is visible.
local function refresh(iNavZone)
	iNav.run()
	return
end

-- Called periodically when custom telemetry screen containing widget is not visible
local function bg(iNavZone)
	iNav.background()
	return
end

return { name = "iNAV", options = options, create = create, update = update, refresh = refresh, background = bg }