local r, m, i, HORUS = ...

local function getTelemetryId(n)
	local field = getFieldInfo(n)
	return field and field.id or -1
end

local function getTelemetryUnit(n)
	local field = getFieldInfo(n)
	return (field and field.unit <= 10) and field.unit or 0
end

local tx = string.sub(r, 0, 2)
if HORUS or string.sub(r, 0, 3) == "x9e" or string.sub(r, 0, 6) == "x9lite" then
	tx = "x7"
end
local tmp = tx == "x9" and EVT_PLUS_FIRST or (tx == "xl" and EVT_UP_FIRST)
local PREV = tx == "x7" and EVT_ROT_LEFT or tmp
tmp = tx == "x9" and EVT_MINUS_FIRST or (tx == "xl" and EVT_DOWN_FIRST)
local NEXT = tx == "x7" and EVT_ROT_RIGHT or tmp
local MENU = tx == "xl" and EVT_SHIFT_BREAK or (HORUS and EVT_SYS_FIRST or EVT_MENU_BREAK)
local general = getGeneralSettings()
local distSensor = getTelemetryId("Dist") > -1 and "Dist" or (getTelemetryId("0420") > -1 and "0420" or "0007")
local data = {
	txBattMin = general.battMin,
	txBattMax = general.battMax,
	lang = string.lower(general.language),
	voice = general.voice,
	mode_id = getTelemetryId("Tmp1"),
	rxBatt_id = getTelemetryId("RxBt") > -1 and getTelemetryId("RxBt") or getTelemetryId("BtRx"),
	sat_id = getTelemetryId("Tmp2"),
	gpsAlt_id = getTelemetryId("GAlt"),
	gpsLatLon_id = getTelemetryId("GPS"),
	hdg_id = getTelemetryId("Hdg"),
	fpv_id = getTelemetryId("FPV") > -1 and getTelemetryId("FPV") or getTelemetryId("0450"),
	alt_id = getTelemetryId("Alt"),
	dist_id = getTelemetryId(distSensor),
	curr_id = getTelemetryId("Curr"),
	altMax_id = getTelemetryId("Alt+"),
	distMax_id = getTelemetryId(distSensor .. "+"),
	currMax_id = getTelemetryId("Curr+"),
	batt_id = getTelemetryId("VFAS"),
	battMin_id = getTelemetryId("VFAS-"),
	a4_id = getTelemetryId("A4"),
	a4Min_id = getTelemetryId("A4-"),
	fuel_id = getTelemetryId("Fuel"),
	vspeed_id = getTelemetryId("VSpd"),
	txBatt_id = getTelemetryId("tx-voltage"),
	gpsAlt_unit = getTelemetryUnit("GAlt"),
	alt_unit = getTelemetryUnit("Alt"),
	vspeed_unit = getTelemetryUnit("VSpd"),
	dist_unit = getTelemetryUnit(distSensor),
	thr_id = getTelemetryId("thr"),
	mode = 0,
	modeId = 1,
	satellites = 0,
	gpsAlt = 0,
	heading = 0,
	fpv = 0,
	altitude = 0,
	distance = 0,
	speed = 0,
	current = 0,
	fuel = 0,
	batt = 0,
	cell = 0,
	rxBatt = 0,
	txBatt = 0,
	rssiLast = 0,
	vspeed = 0,
	hdop = 0,
	throttle = 0,
	homeResetPrev = false,
	gpsFixPrev = false,
	altNextPlay = 0,
	altLastAlt = 0,
	battNextPlay = 0,
	battPercentPlayed = 100,
	headFree = false,
	headingHold = false,
	altHold = false,
	telemFlags = 0,
	config = 0,
	configLast = 1,
	configTop = 1,
	configSelect = 0,
	crsf = false,
	alt = {},
	v = -1,
	simu = string.sub(r, -4) == "simu",
	--msg = m + i * 0.1 < 2.2 and "OpenTX v2.2+ Required" or false,
	lastLock = { lat = 0, lon = 0 },
	fUnit = {"mAh", "mWh"},
}

return data, getTelemetryId, getTelemetryUnit, PREV, NEXT, MENU