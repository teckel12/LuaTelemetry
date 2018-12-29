WIDGET = true
myZone = {}
--FULLSCREEN = false

local iNav
local options = {
	{ "Restore_Colors", BOOL, 0},
	{ "Text_Color", COLOR, BLACK},
	{ "Warning_Color", COLOR, YELLOW}
}

-- This function is runned once at the creation of the widget
local function create(zone, options)
	myZone = { zone = zone, options = options }
	--if zone.w > 450 and zone.h > 250 then FULLSCREEN = true end
	iNav = loadfile("/SCRIPTS/TELEMETRY/iNav.luac")()
	return myZone
end

-- This function allow updates when you change widgets settings
local function update(myZone, options)
	myZone.options = options
end

-- Called periodically when custom telemetry screen containing widget is visible.
local function refresh(myZone)
	iNav.run()
	return
end

-- Called periodically when custom telemetry screen containing widget is not visible
local function bg(myZone)
	iNav.background()
	return
end

return { name = "iNAV", options = options, create = create, update = update, refresh = refresh, background = bg }