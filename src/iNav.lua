-- Lua Telemetry Flight Status for INAV/Taranis
-- Author: https://github.com/teckel12
-- Docs: https://github.com/iNavFlight/LuaTelemetry

local VERSION = "1.3.2"
local FILE_PATH = "/SCRIPTS/TELEMETRY/iNav/"
local FLASH = 3
local SMLCD = LCD_W < 212
local RIGHT_POS = SMLCD and 129 or 195
local GAUGE_WIDTH = SMLCD and 82 or 149
local X_CNTR_1 = SMLCD and 63 or 68
local X_CNTR_2 = SMLCD and 63 or 104

-- Modes: t=text / f=flags for text / w=wave file
local modes = {
	{ t = "! TELEM !", f = FLASH },
	{ t = "HORIZON",   f = 0, w = "hrznmd" },
	{ t = "  ANGLE",   f = 0, w = "anglmd" },
	{ t = "   ACRO",   f = 0, w = "acromd" },
	{ t = " NOT OK ",  f = FLASH },
	{ t = "  READY",   f = 0, w = "ready" },
	{ t = "POS HOLD",  f = 0, w = "poshld" },
	{ t = "3D HOLD",   f = 0, w = "3dhold" },
	{ t = "WAYPOINT",  f = 0, w = "waypt" },
	{ t = " MANUAL",   f = 0, w = "manmd" },
	{ t = "   RTH   ", f = FLASH, w = "rtl" },
	{ t = "FAILSAFE",  f = FLASH, w = "fson" },
	{ t = "! THROT !", f = FLASH }
}

local units = { [0] = "", "V", "A", "mA", "kts", "m/s", "f/s", "km/h", "MPH", "m", "'" }

local function getTelemetryId(name)
	local field = getFieldInfo(name)
	return field and field.id or -1
end

local function getTelemetryUnit(name)
	local field = getFieldInfo(name)
	return (field and field.unit <= 10) and field.unit or 0
end

local rssi, low, crit = getRSSI()
local ver, radio, maj, minor, rev = getVersion()
local tx = string.sub(radio, 0, 2)
local tmp = tx == "x9" and EVT_PLUS_BREAK or (tx == "xl" and EVT_UP_BREAK)
local PREV = tx == "x7" and EVT_ROT_LEFT or tmp
local INCR = tx == "x7" and EVT_ROT_RIGHT or tmp
local tmp = tx == "x9" and EVT_MINUS_BREAK or (tx == "xl" and EVT_DOWN_BREAK)
local NEXT = tx == "x7" and EVT_ROT_RIGHT or tmp
local DECR = tx == "x7" and EVT_ROT_LEFT or tmp
local MENU = tx == "xl" and EVT_SHIFT_BREAK or EVT_MENU_BREAK
local general = getGeneralSettings()
local distanceSensor = getTelemetryId("Dist") > -1 and "Dist" or (getTelemetryId("0420") > -1 and "0420" or "0007")
local data = {
	rssiLow = low,
	rssiCrit = crit,
	txBattMin = general.battMin,
	txBattMax = general.battMax,
	modelName = model.getInfo().name,
	mode_id = getTelemetryId("Tmp1"),
	rxBatt_id = getTelemetryId("RxBt"),
	satellites_id = getTelemetryId("Tmp2"),
	gpsAlt_id = getTelemetryId("GAlt"),
	gpsLatLon_id = getTelemetryId("GPS"),
	heading_id = getTelemetryId("Hdg"),
	altitude_id = getTelemetryId("Alt"),
	distance_id = getTelemetryId(distanceSensor),
	current_id = getTelemetryId("Curr"),
	altitudeMax_id = getTelemetryId("Alt+"),
	distanceMax_id = getTelemetryId(distanceSensor .. "+"),
	currentMax_id = getTelemetryId("Curr+"),
	batt_id = getTelemetryId("VFAS"),
	battMin_id = getTelemetryId("VFAS-"),
	fuel_id = getTelemetryId("Fuel"),
	rssi_id = getTelemetryId("RSSI"),
	rssiMin_id = getTelemetryId("RSSI-"),
	accZ_id = getTelemetryId("AccZ"),
	txBatt_id = getTelemetryId("tx-voltage"),
	gpsAlt_unit = getTelemetryUnit("GAlt"),
	altitude_unit = getTelemetryUnit("Alt"),
	distance_unit = getTelemetryUnit(distanceSensor),
	throttle_id = getTelemetryId("thr"),
	homeResetPrev = false,
	gpsFixPrev = false,
	altNextPlay = 0,
	altLastAlt = 0,
	battNextPlay = 0,
	battPercentPlayed = 100,
	armed = false,
	headFree = false,
	headingHold = false,
	altHold = false,
	telemFlags = -1,
	cells = -1,
	fuel = 100,
	config = 0,
	modeId = 1
}

data.showCurr = data.current_id > -1 and true or false
data.showHead = data.heading_id > -1 and true or false
data.pitot = getTelemetryId("ASpd") > -1 and true or false
data.distPos = data.showCurr and 17 or 21
data.speedPos = data.showCurr and 25 or 33
data.battPos1 = data.showCurr and 49 or 45
data.battPos2 = data.showCurr and 49 or 41
data.distRef = data.distance_unit == 10 and 20 or 6
data.altitude_unit = data.altitude_id == -1 and data.gpsAlt_unit or data.altitude_unit
data.distance_unit = data.distance_unit == 0 and 9 or data.distance_unit
data.systemError = maj + minor / 10 < 2.2 and "OpenTX v2.2+ Required" or false
data.emptyGPS = { lat = 0, lon = 0 }

-- Config options: o=display Order / t=Text / c=Characters / v=default Value / l=Lookup text / d=Decimal / m=Min / x=maX / i=Increment / a=Append text / b=Blocked by
local config = {
	{ o = 1,  t = "Battery View",   c = 1, v = 1, i = 1, l = {[0] = "Cell", "Total"} },
	{ o = 3,  t = "Cell Low",       c = 2, v = 3.5, d = true, m = 2.7, x = 3.9, i = 0.1, a = "V", b = 2 },
	{ o = 4,  t = "Cell Critical",  c = 2, v = 3.4, d = true, m = 2.6, x = 3.8, i = 0.1, a = "V", b = 2 },
	{ o = 15, t = "Voice Alerts",   c = 1, v = 2, x = 2, i = 1, l = {[0] = "Off", "Critical", "All"} },
	{ o = 16, t = "Feedback",       c = 1, v = 3, x = 3, i = 1, l = {[0] = "Off", "Haptic", "Beeper", "All"} },
	{ o = 9,  t = "Max Altitude",   c = 4, v = data.altitude_unit == 10 and 400 or 120, x = 9999, i = data.altitude_unit == 10 and 10 or 1, a = units[data.altitude_unit], b = 8 },
	{ o = 13, t = "Variometer",     c = 1, v = 0, i = 1, x = 3, l = {[0] = "Off", "Display", "Beeper", "Voice"} },
	{ o = 17, t = "RTH Feedback",   c = 1, v = 1, i = 1, l = {[0] = "Off", "On"}, b = 16 },
	{ o = 18, t = "HeadFree Fback", c = 1, v = 1, i = 1, l = {[0] = "Off", "On"}, b = 16 },
	{ o = 19, t = "RSSI Feedback",  c = 1, v = 1, i = 1, l = {[0] = "Off", "On"}, b = 16 },
	{ o = 2,  t = "Battery Alerts", c = 1, v = 2, x = 2, i = 1, l = {[0] = "Off", "Critical", "All"} },
	{ o = 8,  t = "Altitude Alert", c = 1, v = 1, i = 1, l = {[0] = "Off", "On"} },
	{ o = 10, t = "Timer",          c = 1, v = 1, x = 4, i = 1, l = {[0] = "Off", "Auto", "Timer1", "Timer2", "Timer3"} },
	{ o = 12, t = "Rx Voltage",     c = 1, v = 1, i = 1, l = {[0] = "Off", "On"} },
	{ o = 24, t = "GPS",            c = 1, v = 0, x = 0, i = 0, l = {[0] = data.emptyGPS} },
	{ o = 23, t = "GPS Coords",     c = 1, v = 0, x = 2, i = 1, l = {[0] = "Decimal", "Deg/Min", "Geocode"} },
	{ o = 7,  t = "Fuel Critical",  c = 2, v = 20, m = 5, x = 30, i = 5, a = "%", b = 2 },
	{ o = 6,  t = "Fuel Low",       c = 2, v = 30, m = 10, x = 50, i = 5, a = "%", b = 2 },
	{ o = 11, t = "Tx Voltage",     c = 1, v = SMLCD and 1 or 2, x = SMLCD and 1 or 2, i = 1, l = {[0] = "Number", "Graph", "Both"} },
	{ o = 20, t = "Speed Sensor",   c = 1, v = 0, i = 1, l = {[0] = "GPS", "Pitot"} },
	{ o = 22, t = "GPS Warning     >", c = 2, v = 3.5, d = true, m = 1.0, x = 5.0, i = 0.5, a = " HDOP" },
	{ o = 21, t = "GPS HDOP View",  c = 1, v = 0, i = 1, l = {[0] = "Graph", "Decimal"} },
	{ o = 5,  t = "Fuel Unit",      c = 1, v = 0, i = 1, x = 2, l = {[0] = "Percent", "mAh", "mWh"} },
	{ o = 14, t = "Vario Steps",    c = 1, v = 3, m = 1, x = 10, i = 1, l = {[0] = 1, 2, 5, 10, 15, 20, 25, 30, 40, 50}, a = units[data.altitude_unit] },
}
data.configCnt = 24
for i = 1, data.configCnt do
	for ii = 1, data.configCnt do
		if i == config[ii].o then
			config[i].z = ii
			config[ii].o = nil
		end
	end
end

local function reset()
	data.startup = 1
	data.timerStart = 0
	data.timer = 0
	data.distanceLast = 0
	data.gpsHome = false
	data.gpsLatLon = data.emptyGPS
	data.gpsFix = false
	data.headingRef = -1
	data.battLow = false
	data.showMax = false
	data.showDir = true
	data.cells = 1
	data.gpsAltBase = false
	data.configStatus = 0
end

-- Load config data
local fh = io.open(FILE_PATH .. "config.dat", "r")
if fh ~= nil then
	for line = 1, data.configCnt do
		local tmp = io.read(fh, config[line].c)
		if tmp ~= "" then
			config[line].v = config[line].d == nil and tonumber(tmp) or tmp / 10
		end
	end
	io.close(fh)
end
config[7].v = data.accZ_id > -1 and config[7].v or 0
config[15].v = 0
config[19].x = config[14].v == 0 and 2 or SMLCD and 1 or 2
config[19].v = math.min(config[19].x, config[19].v)
config[20].v = data.pitot and config[20].v or 0
local tmp = config[20].v == 0 and "GSpd" or "ASpd"
data.speed_id = getTelemetryId(tmp)
data.speedMax_id = getTelemetryId(tmp .. "+")
data.speed_unit = getTelemetryUnit(tmp)

local function playAudio(file, alert)
	if config[4].v == 2 or (config[4].v == 1 and alert ~= nil) then
		playFile(FILE_PATH .. file .. ".wav")
	end
end

local function flightModes()
	local armedPrev = data.armed
	local headFreePrev = data.headFree
	local headingHoldPrev = data.headingHold
	local altHoldPrev = data.altHold
	local homeReset = false
	local modeIdPrev = data.modeId
	data.modeId = 1 -- No telemetry
	if data.telemetry then
		data.armed = false
		data.headFree = false
		data.headingHold = false
		data.altHold = false
		local modeA = data.mode / 10000
		local modeB = data.mode / 1000 % 10
		local modeC = data.mode / 100 % 10
		local modeD = data.mode / 10 % 10
		local modeE = data.mode % 10
		if bit32.band(modeE, 4) == 4 then
			data.armed = true
			if bit32.band(modeD, 2) == 2 then
				data.modeId = 2 -- Horizon
			elseif bit32.band(modeD, 1) == 1 then
				data.modeId = 3 -- Angle
			else
				data.modeId = 4 -- Acro
			end
			data.headFree = bit32.band(modeB, 4) == 4 and true or false
			data.headingHold = bit32.band(modeC, 1) == 1 and true or false
			data.altHold = bit32.band(modeC, 2) == 2 and true or false
			homeReset = data.satellites >= 4000 and true or false
			if bit32.band(modeC, 4) == 4 then
				data.modeId = data.altHold and 8 or 7 -- If also alt hold 3D hold(8) else pos hold(7)
			end
		else
			data.modeId = (bit32.band(modeE, 2) == 2 or modeE == 0) and (data.throttle > -1000 and 13 or 5) or 6 -- Not OK to arm(5) / Throttle warning(13) / Ready to fly(6)
		end
		if bit32.band(modeA, 4) == 4 then
			data.modeId = 12 -- Failsafe
		elseif bit32.band(modeB, 1) == 1 then
			data.modeId = 11 -- RTH
		elseif bit32.band(modeD, 4) == 4 then
			data.modeId = 10 -- Passthru
		elseif bit32.band(modeB, 2) == 2 then
			data.modeId = 9 -- Waypoint
		end
	end
	
	-- Voice alerts
	local vibrate = false
	local beep = false
	if data.armed and not armedPrev then -- Engines armed
		data.timerStart = getTime()
		data.headingRef = data.heading
		data.gpsHome = false
		data.battPercentPlayed = 100
		data.battLow = false
		data.showMax = false
		data.showDir = false
		data.configStatus = 0
		if not data.gpsAltBase and data.gpsFix then
			data.gpsAltBase = data.gpsAlt
		end
		playAudio("engarm", 1)
	elseif not data.armed and armedPrev then -- Engines disarmed
		if data.distanceLast <= data.distRef then
			data.headingRef = -1
			data.showDir = true
			data.gpsAltBase = false
		end
		playAudio("engdrm", 1)
	end
	if data.gpsFix ~= data.gpsFixPrev then -- GPS status change
		playAudio("gps", not data.gpsFix and 1 or nil)
		playAudio(data.gpsFix and "good" or "lost", not data.gpsFix and 1 or nil)
	end
	if modeIdPrev ~= data.modeId then -- New flight mode
		if data.armed and modes[data.modeId].w ~= nil then
			playAudio(modes[data.modeId].w, modes[data.modeId].f > 0 and 1 or nil)
		elseif not data.armed and data.modeId == 6 and modeIdPrev == 5 then
			playAudio(modes[data.modeId].w)
		end
	end
	data.hdop = math.floor(data.satellites / 100) % 10
	if data.armed then
		data.distanceLast = data.distance
		if config[13].v == 1 then
			data.timer = (getTime() - data.timerStart) / 100 -- Armed so update timer
		elseif config[13].v > 1 then
			data.timer = model.getTimer(config[13].v - 2)["value"]
		end
		if data.altHold ~= altHoldPrev and data.modeId ~= 8 then -- Alt hold status change
			playAudio("althld")
			playAudio(data.altHold and "active" or "off")
		end
		if data.headingHold ~= headingHoldPrev then -- Heading hold status change
			playAudio("hedhld")
			playAudio(data.headingHold and "active" or "off")
		end
		if data.headFree ~= headFreePrev then -- Head free status change
			playAudio(data.headFree and "hfact" or "hfoff", 1)
		end
		if homeReset and not data.homeResetPrev then -- Home reset
			playAudio("homrst")
			data.gpsHome = false
			data.headingRef = data.heading
		end
		if data.altitude + 0.5 >= config[6].v and config[12].v > 0 then -- Altitude alert
			if getTime() > data.altNextPlay then
				if config[4].v > 0 then
					playNumber(data.altitude + 0.5, data.altitude_unit)
				end
				data.altNextPlay = getTime() + 1000
			else
				beep = true
			end
		elseif config[7].v == 2 then -- Vario beeper
			local tmp = math.abs(math.max(math.min(data.accZ - 1, 1), -1))
			if tmp > 0.05 then
				playTone(2000 * math.min(math.max(data.accZ, 0.5), 1.5), 50, 1000 - (tmp * 900), PLAY_BACKGROUND)
			end
		elseif config[7].v == 3 then -- Vario voice
			local tmp = math.floor((data.altitude + 0.5) / config[24].l[config[24].v]) * config[24].l[config[24].v]
			if tmp ~= data.altLastAlt and tmp > 0 and getTime() > data.altNextPlay then
				playNumber(tmp, data.altitude_unit)
				data.altLastAlt = tmp
				data.altNextPlay = getTime() + 1000
			end
		end
		if config[23].v == 0 and data.battPercentPlayed > data.fuel and config[11].v == 2 and config[4].v == 2 then -- Fuel notification
			if data.fuel % 5 == 0 and data.fuel > config[17].v and data.fuel <= config[18].v then
				playAudio("batlow")
				playNumber(data.fuel, 13)
				data.battPercentPlayed = data.fuel
			elseif data.fuel % 10 == 0 and data.fuel < 100 and data.fuel > config[17].v + 10 then
				playAudio("battry")
				playNumber(data.fuel, 13)
				data.battPercentPlayed = data.fuel
			end
		end
		if ((config[23].v == 0 and data.fuel <= config[17].v) or data.cell < config[3].v) and config[11].v > 0 then -- Voltage/fuel critial
			if getTime() > data.battNextPlay then
				playAudio("batcrt", 1)
				if config[23].v == 0 and data.fuel <= config[17].v and data.battPercentPlayed > data.fuel and config[4].v > 0 then
					playNumber(data.fuel, 13)
					data.battPercentPlayed = data.fuel
				end
				data.battNextPlay = getTime() + 500
			else
				vibrate = true
				beep = true
			end
			data.battLow = true
		elseif data.cell < config[2].v and config[11].v == 2 then -- Voltage notification
			if not data.battLow then
				playAudio("batlow")
				data.battLow = true
			end
		else
			data.battNextPlay = 0
		end
		if (data.headFree and config[9].v == 1) or modes[data.modeId].f ~= 0 then
			if data.modeId ~= 11 or (data.modeId == 11 and config[8].v == 1) then
				beep = true
				vibrate = true
			end
		elseif data.rssi < data.rssiLow and config[10].v == 1 then
			if data.rssi < data.rssiCrit then
				vibrate = true
			end
			beep = true
		end
		if data.hdop < 11 - config[21].v * 2 then
			beep = true
		end
		if vibrate and (config[5].v == 1 or config[5].v == 3) then
			playHaptic(25, 3000)
		end
		if beep and config[5].v >= 2 then
			playTone(2000, 100, 3000, PLAY_NOW)
		end
	else
		data.battLow = false
		data.battPercentPlayed = 100
	end
	data.gpsFixPrev = data.gpsFix
	data.homeResetPrev = homeReset
end

local function gpsDegMin(coord, lat)
	local gpsD = math.floor(math.abs(coord))
	return gpsD .. string.format("\64%05.2f", (math.abs(coord) - gpsD) * 60) .. (lat and (coord >= 0 and "N" or "S") or (coord >= 0 and "E" or "W"))
end

local function gpsGeocoding(coord, lat)
	local gpsD = math.floor(math.abs(coord))
	return (lat and (coord >= 0 and "N" or "S") or (coord >= 0 and "E" or "W")) .. gpsD .. string.format("\64%05.2f", (math.abs(coord) - gpsD) * 60)
end

local function background()
	data.rssi = getValue(data.rssi_id)
	if data.telemFlags == -1 then
		reset()
	end
	if data.rssi > 0 or data.telemFlags < 0 then
		data.telemetry = true
		data.mode = getValue(data.mode_id)
		data.rxBatt = getValue(data.rxBatt_id)
		data.satellites = getValue(data.satellites_id)
		data.gpsAlt = getValue(data.gpsAlt_id)
		data.heading = getValue(data.heading_id)
		data.altitude = getValue(data.altitude_id)
		if data.altitude_id == -1 and data.gpsAltBase and data.gpsFix then
			data.altitude = data.gpsAlt - data.gpsAltBase
		end
		data.distance = getValue(data.distance_id)
		data.speed = getValue(data.speed_id)
		if data.showCurr then
			data.current = getValue(data.current_id)
			data.currentMax = getValue(data.currentMax_id)
			data.fuel = getValue(data.fuel_id)
		end
		data.altitudeMax = getValue(data.altitudeMax_id)
		data.distanceMax = getValue(data.distanceMax_id)
		data.speedMax = getValue(data.speedMax_id)
		data.batt = getValue(data.batt_id)
		data.battMin = getValue(data.battMin_id)
		data.cells = (data.batt / data.cells > 4.3) and math.floor(data.batt / 4.3) + 1 or data.cells
		data.cell = data.batt / data.cells
		data.cellMin = data.battMin / data.cells
		data.rssiMin = getValue(data.rssiMin_id)
		data.accZ = getValue(data.accZ_id)
		data.txBatt = getValue(data.txBatt_id)
		data.rssiLast = data.rssi
		local gpsTemp = getValue(data.gpsLatLon_id)
		data.gpsFix = data.satellites > 1000 and type(gpsTemp) == "table" and gpsTemp.lat ~= nil and gpsTemp.lon ~= nil and gpsTemp.lat ~= 0 and gpsTemp.lon ~= 0
		if data.gpsFix then
			data.gpsLatLon = gpsTemp
			config[15].l[0] = gpsTemp
		end
		-- Dist doesn't have a known unit so the transmitter doesn't auto-convert
		if data.distance_unit == 10 then
			data.distance = math.floor(data.distance * 3.28084 + 0.5)
			data.distanceMax = data.distanceMax * 3.28084
		end
		if data.distance > 0 then
			data.distanceLast = data.distance
		end
		data.telemFlags = 0
	else
		data.telemetry = false
		data.telemFlags = FLASH
	end
	data.throttle = getValue(data.throttle_id)

	flightModes()

	if data.armed and data.gpsFix and data.gpsHome == false then
		data.gpsHome = data.gpsLatLon
	end
end

local function drawDirection(heading, width, radius, x, y)
	local rad1 = math.rad(heading)
	local rad2 = math.rad(heading + width)
	local rad3 = math.rad(heading - width)
	local x1 = math.floor(math.sin(rad1) * radius + 0.5) + x
	local y1 = y - math.floor(math.cos(rad1) * radius + 0.5)
	local x2 = math.floor(math.sin(rad2) * radius + 0.5) + x
	local y2 = y - math.floor(math.cos(rad2) * radius + 0.5)
	local x3 = math.floor(math.sin(rad3) * radius + 0.5) + x
	local y3 = y - math.floor(math.cos(rad3) * radius + 0.5)
	lcd.drawLine(x1, y1, x2, y2, SOLID, FORCE)
	lcd.drawLine(x1, y1, x3, y3, SOLID, FORCE)
	if data.headingHold then
		lcd.drawFilledRectangle((x2 + x3) / 2 - 1.5, (y2 + y3) / 2 - 1.5, 4, 4, SOLID)
	else
		lcd.drawLine(x2, y2, x3, y3, SMLCD and DOTTED or SOLID, FORCE + (SMLCD and 0 or GREY_DEFAULT))
	end
end

local function drawData(txt, y, dir, vc, vm, max, ext, frac, flags)
	if data.showMax and dir > 0 then
		vc = vm
		lcd.drawText(0, y, string.sub(txt, 1, 3), SMLSIZE)
		lcd.drawText(15, y, dir == 1 and "\192" or "\193", SMLSIZE)
	else
		lcd.drawText(0, y, txt, SMLSIZE)
	end
	local tmpext = (frac ~= 0 or vc < max) and ext or ""
	if frac ~= 0 and vc + 0.5 < max then
		lcd.drawText(21, y, string.format(frac, vc) .. tmpext, SMLSIZE + flags)
	else
		lcd.drawText(21, y, math.floor(vc + 0.5) .. tmpext, SMLSIZE + flags)
	end
end

local function run(event)
	lcd.clear()

	-- Display system error
	if data.systemError then
		lcd.drawText((LCD_W - string.len(data.systemError) * 5.2) / 2, 27, data.systemError)
		return 0
	end

	-- Startup message
	if data.startup == 1 then
		startupTime = getTime()
		data.startup = 2
	elseif data.startup == 2 then
		if getTime() - startupTime < 200 then
			if not SMLCD then
				lcd.drawText(53, 9, "INAV Lua Telemetry")
			end
			lcd.drawText(SMLCD and 51 or 91, 17, "v" .. VERSION)
		else
			data.startup = 0
		end
	end
	local startupTime = 0

	-- GPS
	local gpsFlags = SMLSIZE + RIGHT + ((data.telemFlags > 0 or not data.gpsFix) and FLASH or 0)
	local tmp = RIGHT_POS - (gpsFlags == SMLSIZE + RIGHT and 0 or 1)
	lcd.drawText(tmp, 17, (data.gpsFix and math.floor(data.gpsAlt + 0.5) or "0") .. units[data.gpsAlt_unit], gpsFlags)
	if config[16].v == 0 then
		lcd.drawText(tmp, 25, string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lat), gpsFlags)
		lcd.drawText(tmp, 33, string.format(SMLCD and "%.5f" or "%.6f", data.gpsLatLon.lon), gpsFlags)
	else
		lcd.drawText(tmp, 25, config[16].v == 1 and gpsDegMin(data.gpsLatLon.lat, true) or gpsGeocoding(data.gpsLatLon.lat, true), gpsFlags)
		lcd.drawText(tmp, 33, config[16].v == 1 and gpsDegMin(data.gpsLatLon.lon, false) or gpsGeocoding(data.gpsLatLon.lon, false), gpsFlags)
	end
	local tmp = ((data.armed or data.modeId == 6) and data.hdop < 11 - config[21].v * 2) or not data.telemetry
	if config[22].v == 0 then
		if tmp then
			lcd.drawText(RIGHT_POS - 30, 9, "    ", SMLSIZE + FLASH)
		end
		for i = 4, 9 do
			lcd.drawLine(RIGHT_POS - (38 - (i * 2)), (data.hdop >= i or not SMLCD) and 17 - i or 14, RIGHT_POS - (38 - (i * 2)), 14, SOLID, (data.hdop >= i or SMLCD) and 0 or GREY_DEFAULT)
		end
	else
		lcd.drawText(RIGHT_POS - 18, 9, (data.hdop == 0 and not data.gpsFix) and "--" or (9 - data.hdop) / 2 + 0.8, SMLSIZE + RIGHT + (tmp and FLASH or 0))
	end
	lcd.drawLine(RIGHT_POS - 16, 9, RIGHT_POS - 12, 13, SOLID, FORCE)
	lcd.drawLine(RIGHT_POS - 16, 10, RIGHT_POS - 13, 13, SOLID, FORCE)
	lcd.drawLine(RIGHT_POS - 16, 11, RIGHT_POS - 14, 13, SOLID, FORCE)
	lcd.drawLine(RIGHT_POS - 17, 14, RIGHT_POS - 13, 10, SOLID, FORCE)
	lcd.drawPoint(RIGHT_POS - 16, 14)
	lcd.drawPoint(RIGHT_POS - 15, 14)
	lcd.drawText(RIGHT_POS - (data.telemFlags == 0 and 0 or 1), 9, data.satellites % 100, SMLSIZE + RIGHT + data.telemFlags)

	-- Directionals
	if data.showHead and data.startup == 0 and data.configStatus == 0 then
		if event == NEXT or event == PREV then
			data.showDir = not data.showDir
		end
		if data.telemetry then
			local indicatorDisplayed = false
			if data.showDir or data.headingRef < 0 or not SMLCD then
				lcd.drawText(X_CNTR_1 - 2, 9, "N " .. math.floor(data.heading + 0.5) .. "\64", SMLSIZE)
				lcd.drawText(X_CNTR_1 + 10, 21, "E", SMLSIZE)
				lcd.drawText(X_CNTR_1 - 14, 21, "W", SMLSIZE)
				if not SMLCD then
					lcd.drawText(X_CNTR_1 - 2, 32, "S", SMLSIZE)
				end
				drawDirection(data.heading, 140, 7, X_CNTR_1, 23)
				indicatorDisplayed = true
			end
			if not data.showDir or data.headingRef >= 0 or not SMLCD then
				if not indicatorDisplayed or not SMLCD then
					drawDirection(data.heading - data.headingRef, 145, 8, SMLCD and 63 or 133, 19)
				end
			end
		end
		if data.gpsHome ~= false and data.distanceLast >= data.distRef then
			if not data.showDir or not SMLCD then
				local o1 = math.rad(data.gpsHome.lat)
				local a1 = math.rad(data.gpsHome.lon)
				local o2 = math.rad(data.gpsLatLon.lat)
				local a2 = math.rad(data.gpsLatLon.lon)
				local y = math.sin(a2 - a1) * math.cos(o2)
				local x = (math.cos(o1) * math.sin(o2)) - (math.sin(o1) * math.cos(o2) * math.cos(a2 - a1))
				local bearing = math.deg(math.atan2(y, x)) - data.headingRef
				local rad1 = math.rad(bearing)
				local x1 = math.floor(math.sin(rad1) * 10 + 0.5) + X_CNTR_2
				local y1 = 19 - math.floor(math.cos(rad1) * 10 + 0.5)
				lcd.drawLine(X_CNTR_2, 19, x1, y1, SMLCD and DOTTED or SOLID, FORCE + (SMLCD and 0 or GREY_DEFAULT))
				lcd.drawFilledRectangle(x1 - 1, y1 - 1, 3, 3, ERASE)
				lcd.drawFilledRectangle(x1 - 1, y1 - 1, 3, 3, SOLID)
			end
		end
	end

	-- Flight mode
	lcd.drawText((SMLCD and 46 or 83) + (modes[data.modeId].f == FLASH and 1 or 0), 33, modes[data.modeId].t, (SMLCD and SMLSIZE or 0) + modes[data.modeId].f)
	if data.headFree then
		lcd.drawText(RIGHT_POS - 41, 9, "HF", FLASH + SMLSIZE)
	end

	-- User input
	if not data.armed and data.configStatus == 0 then
		-- Toggle showing max/min values
		if event == PREV or event == NEXT then
			data.showMax = not data.showMax
		end
		-- Initalize variables on long <Enter>
		if event == EVT_ENTER_LONG then
			reset()
		end
	end

	-- Data & gauges
	drawData("Altd", 9, 1, data.altitude, data.altitudeMax, 10000, units[data.altitude_unit], 0, (data.telemFlags > 0 or data.altitude + 0.5 >= config[6].v) and FLASH or 0)
	if data.altHold then
		lcd.drawRectangle(47, 9, 3, 3, FORCE)
		lcd.drawFilledRectangle(46, 11, 5, 4, FORCE)
		lcd.drawPoint(48, 12)
	end
	local tmp = (data.telemFlags > 0 or data.cell < config[3].v or (config[23].v == 0 and data.fuel <= config[17].v)) and FLASH or 0
	drawData("Dist", data.distPos, 1, data.distanceLast, data.distanceMax, 10000, units[data.distance_unit], 0, data.telemFlags)
	drawData(units[data.speed_unit], data.speedPos, 1, data.speed, data.speedMax, 1000, '', 0, data.telemFlags)
	drawData("Batt", data.battPos1, 2, config[1].v == 0 and data.cell or data.batt, config[1].v == 0 and data.cellMin or data.battMin, 100, "V", config[1].v == 0 and "%.2f" or "%.1f", tmp, 1)
	drawData("RSSI", 57, 2, data.rssiLast, data.rssiMin, 200, "dB", 0, (data.telemFlags > 0 or data.rssi < data.rssiLow) and FLASH or 0)
	if data.showCurr then
		drawData("Curr", 33, 1, data.current, data.currentMax, 100, "A", "%.1f", data.telemFlags)
		drawData(config[23].v == 0 and "Fuel" or config[23].l[config[23].v], 41, 0, data.fuel, 0, 200, config[23].v == 0 and "%" or "", 0, tmp)
		if config[23].v == 0 then
			lcd.drawGauge(46, 41, GAUGE_WIDTH, 7, math.min(data.fuel, 98), 100)
			if data.fuel == 0 then
				lcd.drawLine(47, 42, 47, 46, SOLID, ERASE)
			end
		end
	end
	local tmp = 100 / (4.2 - config[3].v + 0.1)
	lcd.drawGauge(46, data.battPos2, GAUGE_WIDTH, 56 - data.battPos2, math.min(math.max(data.cell - config[3].v + 0.1, 0) * tmp, 98), 100)
	local tmp = (GAUGE_WIDTH - 2) * (math.min(math.max(data.cellMin - config[3].v + 0.1, 0) * tmp, 99) / 100) + 47
	lcd.drawLine(tmp, data.battPos2 + 1, tmp, 54, SOLID, ERASE)
	lcd.drawGauge(46, 57, GAUGE_WIDTH, 7, math.max(math.min((data.rssiLast - data.rssiCrit) / (100 - data.rssiCrit) * 100, 98), 0), 100)
	local tmp = (GAUGE_WIDTH - 2) * (math.max(math.min((data.rssiMin - data.rssiCrit) / (100 - data.rssiCrit) * 100, 99), 0) / 100) + 47
	lcd.drawLine(tmp, 58, tmp, 62, SOLID, ERASE)
	if not SMLCD then
		local w = config[7].v == 1 and 7 or 15
		local l = config[7].v == 1 and 205 or 197
		lcd.drawRectangle(l, 9, w, 48, SOLID)
		local tmp = math.max(math.min(math.ceil(data.altitude / config[6].v * 46), 46), 0)
		lcd.drawFilledRectangle(l + 1, 56 - tmp, w - 2, tmp, INVERS)
		local tmp = 56 - math.max(math.min(math.ceil(data.altitudeMax / config[6].v * 46), 46), 0)
		lcd.drawLine(l + 1, tmp, l + w - 2, tmp, SOLID, GREY_DEFAULT)
		lcd.drawText(l + 1, 58, config[7].v == 1 and "A" or "Alt", SMLSIZE)
	end

	-- Variometer
	if config[7].v == 1 and data.startup == 0 then
		if SMLCD and data.armed and not data.showDir then
			lcd.drawLine(X_CNTR_2 + 17, 21, X_CNTR_2 + 19, 21, SOLID, FORCE)
			lcd.drawLine(X_CNTR_2 + 18, 21, X_CNTR_2 + 18, 21 - math.max(math.min(data.accZ - 1, 1), -1) * 12, SOLID, FORCE)
		elseif not SMLCD then
			lcd.drawRectangle(197, 9, 7, 48, SOLID)
			lcd.drawText(198, 58, "V", SMLSIZE)
			if data.armed then
				local tmp = 33 - math.floor(math.max(math.min(data.accZ - 1, 1), -1) * 23 - 0.5)
				if tmp > 33 then
					lcd.drawFilledRectangle(198, 33, 5, tmp - 33, INVERS)
				else
					lcd.drawFilledRectangle(198, tmp - 1, 5, 33 - tmp + 2, INVERS)
				end
			end
		end
	end

	-- Title
	lcd.drawFilledRectangle(0, 0, LCD_W, 8, FORCE)
	lcd.drawText(0, 0, data.modelName, INVERS)
	if config[13].v > 0 then
		lcd.drawTimer(SMLCD and 60 or 150, 1, data.timer, SMLSIZE + INVERS)
	end
	if config[19].v > 0 then
		lcd.drawFilledRectangle(86, 1, 19, 6, ERASE)
		lcd.drawLine(105, 2, 105, 5, SOLID, ERASE)
		local tmp = math.max(math.min((data.txBatt - data.txBattMin) / (data.txBattMax - data.txBattMin) * 17, 17), 0) + 86
		for i = 87, tmp, 2 do
			lcd.drawLine(i, 2, i, 5, SOLID, FORCE)
		end
	end
	if config[19].v ~= 1 then
		lcd.drawText(SMLCD and (config[14].v == 1 and 105 or LCD_W) or 128, 1, string.format("%.1f", data.txBatt) .. "V", SMLSIZE + RIGHT + INVERS)
	end
	if data.rxBatt > 0 and data.telemetry and config[14].v == 1 then
		lcd.drawText(LCD_W, 1, string.format("%.1f", data.rxBatt) .. "V", SMLSIZE + RIGHT + INVERS)
	end

	-- Config menu
	if data.configStatus == 0 and event == MENU then
		data.configStatus = 1
		data.configSelect = 0
		data.configTop = 1
	end
	if data.configStatus > 0 then
		-- Load config menu
		loadScript(FILE_PATH .. "config.luac", "bT")(FILE_PATH, SMLCD, PREV, INCR, NEXT, DECR, gpsDegMin, gpsGeocoding, config, data, event)
	end

	return 0
end

return { run = run, background = background }