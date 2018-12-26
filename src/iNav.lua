-- Lua Telemetry Flight Status for INAV/Taranis
-- Author: https://github.com/teckel12
-- Docs: https://github.com/iNavFlight/LuaTelemetry

VERSION = "1.4.4"
FILE_PATH = "/SCRIPTS/TELEMETRY/iNav/"
SMLCD = LCD_W < 212
HORUS = LCD_W >= 480
FLASH = HORUS and WARNING_COLOR or 3

local tmp, view

-- Build with Companion
local v, r, m, i, e = getVersion()
if string.sub(r, -4) == "simu" then
	loadScript(FILE_PATH .. "build", "tx")()
end

config = loadfile(FILE_PATH .. "config.luac")(SMLCD)
collectgarbage()

modes, units, labels = loadfile(FILE_PATH .. "modes.luac")()
collectgarbage()

data, getTelemetryId, getTelemetryUnit, PREV, INCR, NEXT, DECR, MENU = loadfile(FILE_PATH .. "data.luac")(r, m, i, HORUS)
collectgarbage()

local configCnt = loadfile(FILE_PATH .. "load.luac")(config, data, FILE_PATH)
collectgarbage()

--[[ Simulator language testing
data.lang = "es"
data.voice = "es"
]]

if data.lang ~= "en" or data.voice ~= "en" then
	loadfile(FILE_PATH .. "lang.luac")(modes, config, labels, data, FILE_PATH)
	collectgarbage()
end

loadfile(FILE_PATH .. "reset.luac")(data)
loadfile(FILE_PATH .. "other.luac")(config, data, units, getTelemetryId, getTelemetryUnit, FILE_PATH)
collectgarbage()

title, gpsDegMin, hdopGraph, icons = loadfile(FILE_PATH .. (HORUS and "func_h.luac" or "func_t.luac"))(config, data, FILE_PATH)
collectgarbage()

local function playAudio(f, a)
	if config[4].v == 2 or (config[4].v == 1 and a ~= nil) then
		playFile(FILE_PATH .. data.voice .. "/" .. f .. ".wav")
	end
end

local function calcTrig(gps1, gps2, deg)
	local o1 = math.rad(gps1.lat)
	local a1 = math.rad(gps1.lon)
	local o2 = math.rad(gps2.lat)
	local a2 = math.rad(gps2.lon)
	if deg then
		local y = math.sin(a2 - a1) * math.cos(o2)
		local x = (math.cos(o1) * math.sin(o2)) - (math.sin(o1) * math.cos(o2) * math.cos(a2 - a1))
		return math.deg(math.atan2(y, x))
	else
		local u = math.sin((o2 - o1) / 2)
		local v = math.sin((a2 - a1) / 2)
		return 12742018 * math.asin(math.sqrt(u * u + math.cos(o1) * math.cos(o2) * v * v))
	end
end

local function calcDir(r1, r2, r3, x, y, r)
	--[[ This level of precision probably isn't necessary
	local x1 = math.floor(math.sin(r1) * r + 0.5) + x
	local y1 = y - math.floor(math.cos(r1) * r + 0.5)
	local x2 = math.floor(math.sin(r2) * r + 0.5) + x
	local y2 = y - math.floor(math.cos(r2) * r + 0.5)
	local x3 = math.floor(math.sin(r3) * r + 0.5) + x
	local y3 = y - math.floor(math.cos(r3) * r + 0.5)
	]]
	local x1 = math.sin(r1) * r + x
	local y1 = y - (math.cos(r1) * r)
	local x2 = math.sin(r2) * r + x
	local y2 = y - (math.cos(r2) * r)
	local x3 = math.sin(r3) * r + x
	local y3 = y - (math.cos(r3) * r)
	return x1, y1, x2, y2, x3, y3
end

local function background()
	data.rssi = getValue(data.rssi_id)
	if data.rssi > 0 then
		data.telem = true
		data.telemFlags = 0
		data.mode = getValue(data.mode_id)
		data.rxBatt = getValue(data.rxBatt_id)
		data.satellites = getValue(data.sat_id)
		data.gpsAlt = data.satellites > 1000 and getValue(data.gpsAlt_id) or 0
		data.heading = getValue(data.hdg_id)
		data.altitude = getValue(data.alt_id)
		if data.alt_id == -1 and data.gpsAltBase and data.gpsFix and data.satellites > 3000 then
			data.altitude = data.gpsAlt - data.gpsAltBase
		end
		data.distance = getValue(data.dist_id)
		data.speed = getValue(data.speed_id)
		if data.showCurr then
			data.current = getValue(data.curr_id)
			data.currentMax = getValue(data.currMax_id)
		end
		if data.showFuel then
			data.fuel = getValue(data.fuel_id)
		end
		data.altitudeMax = getValue(data.altMax_id)
		data.distanceMax = getValue(data.distMax_id)
		data.speedMax = getValue(data.speedMax_id)
		data.batt = getValue(data.batt_id)
		data.battMin = getValue(data.battMin_id)
		if data.a4_id > -1 then
			data.cell = getValue(data.a4_id)
			data.cellMin = getValue(data.a4Min_id)
		else
			if data.batt / data.cells > 4.3 or data.batt / data.cells < 2.2 then
				data.cells = math.floor(data.batt / 4.3) + 1
			end
			data.cell = data.batt / data.cells
			data.cellMin = data.battMin / data.cells
		end
		data.rssiMin = getValue(data.rssiMin_id)
		data.vspeed = getValue(data.vspeed_id)
		if data.pitchRoll then
			data.pitch = getValue(data.pitch_id)
			data.roll = getValue(data.roll_id)
		else
			data.accx = getValue(data.accx_id)
			data.accy = getValue(data.accy_id)
			data.accz = getValue(data.accz_id)
		end
		data.rssiLast = data.rssi
		local gpsTemp = getValue(data.gpsLatLon_id)
		if type(gpsTemp) == "table" and gpsTemp.lat ~= nil and gpsTemp.lon ~= nil then
			data.gpsLatLon = gpsTemp
			if data.satellites > 1000 and gpsTemp.lat ~= 0 and gpsTemp.lon ~= 0 then
				data.gpsFix = true
				config[15].l[0] = gpsTemp
				-- Calculate distance to home if sensor is missing or in simlulator
				if data.gpsHome ~= false and (data.dist_id == -1 or string.sub(r, -4) == "simu") then
					data.distance = calcTrig(data.gpsHome, data.gpsLatLon, false)
					data.distanceMax = math.max(data.distMaxCalc, data.distance)
					data.distMaxCalc = data.distanceMax
					data.dist_unit = data.alt_unit
				end
			end
		end
		-- Dist doesn't have a known unit so the transmitter doesn't auto-convert
		if data.dist_unit == 10 then
			data.distance = math.floor(data.distance * 3.28084 + 0.5)
			data.distanceMax = data.distanceMax * 3.28084
		end
		if data.distance > 0 then
			data.distanceLast = data.distance
		end
	else
		data.telem = false
		data.telemFlags = FLASH
	end
	data.txBatt = getValue(data.txBatt_id)
	data.throttle = getValue(data.thr_id)

	local armedPrev = data.armed
	local headFreePrev = data.headFree
	local headingHoldPrev = data.headingHold
	local altHoldPrev = data.altHold
	local homeReset = false
	local modeIdPrev = data.modeId
	local preArmMode = false
	data.modeId = 1 -- No telemetry
	if data.telem then
		data.armed = false
		data.headFree = false
		data.headingHold = false
		data.altHold = false
		local modeA = data.mode / 10000
		local modeB = data.mode / 1000 % 10
		local modeC = data.mode / 100 % 10
		local modeD = data.mode / 10 % 10
		local modeE = data.mode % 10
		if bit32.band(modeD, 2) == 2 then
			data.modeId = 2 -- Horizon
		elseif bit32.band(modeD, 1) == 1 then
			data.modeId = 3 -- Angle
		else
			data.modeId = 4 -- Acro
		end
		data.headFree = bit32.band(modeB, 4) == 4 and true or false
		data.headingHold = bit32.band(modeC, 1) == 1 and true or false
		if bit32.band(modeE, 4) == 4 then
			data.armed = true
			data.altHold = (bit32.band(modeC, 2) == 2 or bit32.band(modeC, 4) == 4) and true or false
			homeReset = data.satellites >= 4000 and true or false
			data.modeId = bit32.band(modeC, 4) == 4 and 7 or data.modeId -- Pos hold
		else
			preArmMode = data.modeId
			data.modeId = (bit32.band(modeE, 2) == 2 or modeE == 0) and (data.throttle > -945 and 12 or 5) or 6 -- Not OK to arm(5) / Throttle warning(12) / Ready to fly(6)
		end
		if bit32.band(modeA, 4) == 4 then
			data.modeId = 11 -- Failsafe
		elseif bit32.band(modeB, 1) == 1 then
			data.modeId = 10 -- RTH
		elseif bit32.band(modeD, 4) == 4 then
			data.modeId = 9 -- Manual
		elseif bit32.band(modeB, 2) == 2 then
			data.modeId = 8 -- Waypoint
		elseif bit32.band(modeB, 8) == 8 then
			data.modeId = 13 -- Cruise
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
			data.showMax = false
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
	elseif preArmMode ~= false and data.preArmModePrev ~= preArmMode then
		playAudio(modes[preArmMode].w)
	end
	data.hdop = math.floor(data.satellites / 100) % 10
	if data.headingHold ~= headingHoldPrev then -- Heading hold status change
		playAudio("hedhld")
		playAudio(data.headingHold and "active" or "off")
	end
	if data.headFree ~= headFreePrev then -- Head free status change
		playAudio(data.headFree and "hfact" or "hfoff", 1)
	end
	if data.armed then
		data.distanceLast = data.distance
		if config[13].v == 1 then
			data.timer = (getTime() - data.timerStart) / 100 -- Armed so update timer
		elseif config[13].v > 1 then
			data.timer = model.getTimer(config[13].v - 2)["value"]
		end
		if data.altHold ~= altHoldPrev then -- Alt hold status change
			playAudio("althld")
			playAudio(data.altHold and "active" or "off")
		end
		if homeReset and not data.homeResetPrev then -- Home reset
			playAudio("homrst")
			data.gpsHome = false
			data.headingRef = data.heading
		end
		if data.altitude + 0.5 >= config[6].v and config[12].v > 0 then -- Altitude alert
			if getTime() > data.altNextPlay then
				if config[4].v > 0 then
					playNumber(data.altitude + 0.5, data.alt_unit)
				end
				data.altNextPlay = getTime() + 1000
			else
				beep = true
			end
		elseif config[7].v > 1 then -- Vario voice
			if math.abs(data.altitude - data.altLastAlt) + 0.5 >= config[24].l[config[24].v] then
				if math.abs(data.altitude + 0.5 - data.altLastAlt) / config[24].l[config[24].v] > 1.5 then
					tmp = math.floor((data.altitude + 0.5) / config[24].l[config[24].v]) * config[24].l[config[24].v]
				else
					tmp = math.floor(data.altitude / config[24].l[config[24].v] + 0.5) * config[24].l[config[24].v]
				end
				if tmp > 0 and getTime() > data.altNextPlay then
					playNumber(tmp, data.alt_unit)
					data.altLastAlt = tmp
					data.altNextPlay = getTime() + 500
				end
			end
		end
		if data.showCurr and config[23].v == 0 and data.battPercentPlayed > data.fuel and config[11].v == 2 and config[4].v == 2 then -- Fuel notifications
			if data.fuel >= config[17].v and data.fuel <= config[18].v and data.fuel > config[17].v then -- Fuel low
				playAudio("batlow")
				playNumber(data.fuel, 13)
				data.battPercentPlayed = data.fuel
			elseif data.fuel % 10 == 0 and data.fuel < 100 and data.fuel > config[18].v then -- Fuel 10% notification
				playAudio("battry")
				playNumber(data.fuel, 13)
				data.battPercentPlayed = data.fuel
			end
		end
		if ((data.showCurr and config[23].v == 0 and data.fuel <= config[17].v) or data.cell < config[3].v) and config[11].v > 0 then -- Voltage/fuel critial
			if getTime() > data.battNextPlay then
				playAudio("batcrt", 1)
				if data.showCurr and config[23].v == 0 and data.fuel <= config[17].v and data.battPercentPlayed > data.fuel and config[4].v > 0 then
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
			if data.modeId ~= 10 or (data.modeId == 10 and config[8].v == 1) then
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
		-- Altitude hold center feedback
		if config[26].v == 1 and config[5].v > 0 then
			if data.altHold then
				if data.thrCntr == -2000 then
					data.thrCntr = data.throttle
					data.trCnSt = true
				end
				if math.abs(data.throttle - data.thrCntr) < 50 then
					if not data.trCnSt then
						playHaptic(15, 0)
						data.trCnSt = true
					end
				elseif data.trCnSt then
					playTone(data.throttle > data.thrCntr and 600 or 400, 75, 0, PLAY_NOW + PLAY_BACKGROUND)
					data.trCnSt = false
				end
			else
				data.thrCntr = -2000
				data.trCnSt = false
			end
		end
	else
		data.battLow = false
		data.battPercentPlayed = 100
	end
	data.gpsFixPrev = data.gpsFix
	data.homeResetPrev = homeReset
	data.preArmModePrev = preArmMode

	if data.armed and data.gpsFix and data.gpsHome == false then
		data.gpsHome = data.gpsLatLon
	end
end

local function run(event)
	--[[ Lock display at ~10fps
	if event == 0 then
		if getTime() - data.last < 10 then
			return 0
		end
		data.last = getTime()
	end
	]]

	-- Required when running as a one-time script
	background()

	-- Startup message
	if data.startup == 1 then
		data.startupTime = getTime()
		data.startup = 2
	elseif data.startup == 2 and getTime() - data.startupTime >= 200 then
		data.startup = 0
		data.msg = false
	end

	-- Clear screen
	if HORUS then
		lcd.setColor(CUSTOM_COLOR, 264) --lcd.RGB(0, 32, 65)
		lcd.clear(CUSTOM_COLOR)
	else
		lcd.clear()
	end

	-- Display system error
	if data.msg then
		lcd.drawText((LCD_W - string.len(data.msg) * (HORUS and 13 or 5.2)) / 2, HORUS and 130 or 27, data.msg, HORUS and MIDSIZE or 0)
		return 0
	end

	-- Config menu or views
	if data.configStatus > 0 then
		if data.v ~= 9 then
			view = nil
			collectgarbage()
			view = loadfile(FILE_PATH .. "menu.luac")()
			data.v = 9
		end
		view(data, config, event, configCnt, gpsDegMin, getTelemetryId, getTelemetryUnit, FILE_PATH, SMLCD, FLASH, PREV, INCR, NEXT, DECR)
	else
		-- User input
		if not data.armed then
			if event == PREV or event == NEXT then
				-- Toggle showing max/min values
				data.showMax = not data.showMax
			elseif event == EVT_ENTER_LONG then
				-- Initalize variables on long <Enter>
				loadfile(FILE_PATH .. "reset.luac")(data)
			end
		end
		if event == NEXT or event == PREV then
			data.showDir = not data.showDir
		elseif event == EVT_ENTER_BREAK and not HORUS then
			-- Cycle through views
			config[25].v = config[25].v >= config[25].x and 0 or config[25].v + 1
		elseif event == MENU then
			-- Config menu
			data.configStatus = data.configLast
		end
		
		-- Views
		if data.v ~= config[25].v then
			view = nil
			collectgarbage()
			view = loadfile(FILE_PATH .. (HORUS and "horus.luac" or (config[25].v == 1 and "pilot.luac" or (config[25].v == 0 and "view.luac" or "radar.luac"))))()
			data.v = config[25].v
		end
		view(data, config, modes, units, labels, gpsDegMin, hdopGraph, icons, calcTrig, calcDir, VERSION, SMLCD, FLASH, FILE_PATH)
	end
	collectgarbage()

	-- Paint title
	title(data, config, SMLCD)

	return 0
end

return { run = run, background = background }