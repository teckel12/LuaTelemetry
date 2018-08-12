local data, config, modes, FILE_PATH = ...

local function playAudio(file, alert)
	if config[4].v == 2 or (config[4].v == 1 and alert ~= nil) then
		playFile(FILE_PATH .. file .. ".wav")
	end
end

local armedPrev = data.armed
local headFreePrev = data.headFree
local headingHoldPrev = data.headingHold
local altHoldPrev = data.altHold
local homeReset = false
local modeIdPrev = data.modeId
local preArmMode = false
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
		data.modeId = bit32.band(modeC, 4) == 4 and 7 or data.modeId -- pos hold
	else
		preArmMode = data.modeId
		data.modeId = (bit32.band(modeE, 2) == 2 or modeE == 0) and (data.throttle > -1000 and 12 or 5) or 6 -- Not OK to arm(5) / Throttle warning(12) / Ready to fly(6)
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
				playNumber(data.altitude + 0.5, data.altitude_unit)
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
				playNumber(tmp, data.altitude_unit)
				data.altLastAlt = tmp
				data.altNextPlay = getTime() + 500
			end
		end
	end
	if config[23].v == 0 and data.battPercentPlayed > data.fuel and config[11].v == 2 and config[4].v == 2 then -- Fuel notifications
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
else
	data.battLow = false
	data.battPercentPlayed = 100
end
data.gpsFixPrev = data.gpsFix
data.homeResetPrev = homeReset
data.preArmModePrev = preArmMode

return 0