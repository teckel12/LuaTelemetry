local buildMode = ...
local iNav = nil
local options = {
	{ "Restore", BOOL, 1},
	{ "Text", COLOR, BLACK},
	{ "Warning", COLOR, YELLOW}
}
local TELE_PATH = "/SCRIPTS/TELEMETRY/"

-- Build with Companion
local v, r, m, i, e = getVersion()
if string.sub(r, -4) == "simu" and buildMode ~= true then
	loadScript(TELE_PATH .. "iNav", "tc")(true)
end

-- Nirvana NV14 doesn't have have these global constants, so we set them
if r == "NV14" then
	EVT_SYS_FIRST = 1 --1542
	EVT_ROT_LEFT = 2 --57088
	EVT_ROT_RIGHT = 3 --56832
	EVT_ENTER_BREAK = 4 --514
	EVT_EXIT_BREAK = 5 --516
end

-- Run once at the creation of the widget
local function create(zone, options)
	iNavZone = { zone = zone, options = options }
	iNav = loadfile(TELE_PATH .. "iNav.luac")(false)
	iNav.background()
	return iNavZone
end

-- This function allow updates when you change widgets settings
local function update(iNavZone, options)
	iNavZone.options = options
	return
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