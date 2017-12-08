-- Lua Telemetry Flight Status Screen for INAV/Taranis
-- Author: https://github.com/teckel12
-- Docs: https://github.com/iNavFlight/LuaTelemetry

local VERSION = "1.2.2"
local FILE_PATH = "/SCRIPTS/TELEMETRY/iNav/"
local FLASH = 3
local lcd = LCD or lcd
local LCD_W = lcd.W or LCD_W
local LCD_H = lcd.H or LCD_H
local QX7 = LCD_W < 212
local RIGHT_POS = QX7 and 129 or 195
local GAUGE_WIDTH = QX7 and 82 or 149
local X_CNTR_1 = QX7 and 67 or 70
local X_CNTR_2 = QX7 and 67 or 106
local GPS_DIGITS = QX7 and 10000 or 1000000
local CONFIG_X = QX7 and 6 or 48

-- Modes: t=text / f=flags for text / w=wave file
local modes = {
  { t="NO TELEM",  f=3 },
  { t="HORIZON",   f=0, w="hrznmd" },
  { t="ANGLE",     f=0, w="anglmd" },
  { t="ACRO",      f=0, w="acromd" },
  { t=" NOT OK ",  f=3 },
  { t="READY",     f=0, w="ready" },
  { t="POS HOLD",  f=0, w="poshld" },
  { t="3D HOLD",   f=0, w="3dhold" },
  { t="WAYPOINT",  f=0, w="waypt" },
  { t="PASSTHRU",  f=0 },
  { t="   RTH   ", f=3, w="rtl" },
  { t="FAILSAFE",  f=3, w="fson" }
}

local units = { [0]="m", "V", "A", "mA", "kts", "m/s", "f/s", "kmh", "mph", "m", "ft" }

local function getTelemetryId(name)
  local field = getFieldInfo(name)
  return field and field.id or -1
end

local function getTelemetryUnit(name)
  local field = getFieldInfo(name)
  return (field and field.unit <= 10) and field.unit or 1
end

local rssi, low, crit = getRSSI()
local ver, radio, maj, minor, rev = getVersion()
local general = getGeneralSettings()
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
  distance_id = getTelemetryId("Dist"),
  speed_id = getTelemetryId("GSpd"),
  current_id = getTelemetryId("Curr"),
  altitudeMax_id = getTelemetryId("Alt+"),
  distanceMax_id = getTelemetryId("Dist+"),
  speedMax_id = getTelemetryId("GSpd+"),
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
  distance_unit = getTelemetryUnit("Dist"),
  speed_unit = getTelemetryUnit("GSpd"),
  homeResetPrev = false,
  gpsFixPrev = false,
  gpsLogger = {{lat=0, lon=0}, {lat=0, lon=0}, {lat=0, lon=0}, {lat=0, lon=0}, {lat=0, lon=0}},
  gpsLogPos = 1,
  gpsLogTimer = 0,
  altNextPlay = 0,
  battNextPlay = 0,
  battPercentPlayed = 100,
  armed = false,
  headFree = false,
  headingHold = false,
  altHold = false,
  telemFlags = -1,
  config = 0,
  modeId = 1,
  startup = 1
}

data.showCurr = data.current_id > -1 and true or false
data.showHead = data.heading_id > -1 and true or false
data.showAlt = data.altitude_id > -1 and true or false
data.distPos = data.showCurr and 17 or (data.showAlt and 21 or 13)
data.speedPos = data.showCurr and 25 or (data.showAlt and 33 or 25)
data.battPos1 = data.showCurr and 49 or 45
data.battPos2 = data.showCurr and 49 or 41
data.distRef = data.distance_unit == 10 and 20 or 6
data.version = maj + minor / 10

local function reset()
  data.timerStart = 0
  data.timer = 0
  data.distanceLast = 0
  data.gpsHome = false
  data.gpsLatLon = false
  data.gpsFix = false
  data.headingRef = -1
  data.battLow = false
  data.showMax = false
  data.showDir = true
  data.fuel = 100
  data.config = 0
end

-- Config options: o=display Order / t=Text / c=Characters / v=default Value / l=Lookup text / d=Decimal / m=Min / x=maX / i=Inc / a=Append text / b=Blocked by
local config = {
  { o=1,  t="Battery View",  c=1, v=1, i=1, l={[0]="Cell", "Total"} },
  { o=3,  t="Cell Low",      c=2, v=3.5, d=true, m=3.1, x=3.9, i=0.1, a="V", b=2 },
  { o=4,  t="Cell Critical", c=2, v=3.4, d=true, m=3.1, x=3.9, i=0.1, a="V", b=2 },
  { o=10, t="Voice Alerts",  c=1, v=2, x=2, i=1, l={[0]="Off", "Critical", "On"} },
  { o=11, t="Feedback",      c=1, v=3, x=3, i=1, l={[0]="Off", "Haptic", "Beeper", "On"} },
  { o=6,  t="Max Altitude",  c=4, v=data.altitude_unit == 10 and 400 or 120, x=9999, i=data.altitude_unit == 10 and 10 or 1, a=units[data.altitude_unit], b=5 },
  { o=9,  t="Variometer",    c=1, v=1, i=1, l={[0]="Off", "On"} },
  { o=12, t="RTH Feedback",  c=1, v=1, i=1, l={[0]="Off", "On"}, b=11 },
  { o=13, t="HF Feedback",   c=1, v=1, i=1, l={[0]="Off", "On"}, b=11 },
  { o=14, t="RSSI Feedback", c=1, v=1, i=1, l={[0]="Off", "On"}, b=11 },
  { o=2,  t="Battery Alerts",c=1, v=2, x=2, i=1, l={[0]="Off", "Critical", "On"} },
  { o=5,  t="Altitude Alert",c=1, v=1, i=1, l={[0]="Off", "On"} },
  { o=7,  t="Timer",         c=1, v=1, x=4, i=1, l={[0]="Off", "Auto", "Timer1", "Timer2", "Timer3"} },
  { o=8,  t="Rx Voltage",    c=1, v=1, i=1, l={[0]="Off", "On"} }
}
local configValues = 14
for i = 1, configValues do
  for ii = 1, configValues do
    if i == config[ii].o then
      config[i].z = ii
      config[ii].o = nil
    end
  end
end

local function saveConfig()
  local fh = io.open(FILE_PATH .. "config.dat", "w")
  for line = 1, configValues do
    if config[line].d == nil then
      io.write(fh, string.format("%0" .. config[line].c .. "d", config[line].v))
    else 
      io.write(fh, math.floor(config[line].v * 10))
    end
  end
  io.close(fh)
end

-- Load config data
local fh = io.open(FILE_PATH .. "config.dat", "r")
if fh == nil then
  saveConfig()
else
  for line = 1, configValues do
    local tmp = io.read(fh, config[line].c)
    if tmp ~= "" then
      config[line].v = config[line].d == nil and tonumber(tmp) or tmp / 10
    end
  end
  io.close(fh)
end

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
  data.armed = false
  data.headFree = false
  data.headingHold = false
  data.altHold = false
  data.modeId = 1 -- No telemetry
  if data.telemetry then
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
        data.modeId = data.altHold and 8 or 7 -- If also alt hold 3D hold else pos hold
      end
    else
      data.modeId = (bit32.band(modeE, 2) == 2 or modeE == 0) and 5 or 6 -- Not OK to arm / Ready to fly
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
    data.config = 0
    playAudio("engarm", 1)
  elseif not data.armed and armedPrev then -- Engines disarmed
    if data.distanceLast <= data.distRef then
      data.headingRef = -1
      data.showDir = true
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
    end
    if data.battPercentPlayed > data.fuel and config[11].v == 2 and config[4].v == 2 then -- Fuel notification
      if data.fuel == 30 or data.fuel == 25 then
        playAudio("batlow")
        playNumber(data.fuel, 13)
        data.battPercentPlayed = data.fuel
      elseif data.fuel % 10 == 0 and data.fuel < 100 and data.fuel >= 40 then
        playAudio("battry")
        playNumber(data.fuel, 13)
        data.battPercentPlayed = data.fuel
      end
    end
    if (data.fuel <= 20 or data.cell < config[3].v) and config[11].v > 0 then -- Voltage/fuel critial
      if getTime() > data.battNextPlay then
        playAudio("batcrt", 1)
        if data.fuel <= 20 and data.battPercentPlayed > data.fuel and config[4].v > 0 then
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
    data.cells = math.floor(data.batt / 4.3) + 1
    data.cell = data.batt/data.cells
    data.cellMin = data.battMin/data.cells
    data.rssiMin = getValue(data.rssiMin_id)
    data.accZ = getValue(data.accZ_id)
    data.txBatt = getValue(data.txBatt_id)
    data.rssiLast = data.rssi
    local gpsTemp = getValue(data.gpsLatLon_id)
    data.gpsFix = data.satellites > 3900 and type(gpsTemp) == "table" and gpsTemp.lat ~= nil and gpsTemp.lon ~= nil
    if data.gpsFix then
      data.gpsLatLon = gpsTemp
      if getTime() > data.gpsLogTimer then
        data.gpsLogTimer = getTime() + 100
        data.gpsLogger[data.gpsLogPos] = data.gpsLatLon
        data.gpsLogPos = data.gpsLogPos == 5 and 1 or data.gpsLogPos + 1
      end
      lcd.drawText(RIGHT_POS - 60, 20, data.gpsLogger[data.gpsLogPos].lat, INVERS)
      --data.distance = 70
      --data.gpsLatLon.lat = math.deg(data.gpsLatLon.lat)
      --data.gpsLatLon.lon = math.deg(data.gpsLatLon.lon * 2.1064)
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

  flightModes()

  if data.armed and data.gpsFix and data.gpsHome == false then
    data.gpsHome = data.gpsLatLon
  end
end

local function gpsData(txt, y, flags)
  lcd.drawText(0, 0, txt, SMLSIZE)
  local x = RIGHT_POS - lcd.getLastPos()
  lcd.drawText(x, y, txt, SMLSIZE + flags)
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
  local lineType = (data.headFree and QX7) and DOTTED or SOLID
  lcd.drawLine(x1, y1, x2, y2, lineType, FORCE)
  lcd.drawLine(x1, y1, x3, y3, lineType, FORCE)
  if data.headingHold then
    lcd.drawFilledRectangle((x2 + x3) / 2 - 1.5, (y2 + y3) / 2 - 1.5, 4, 4, SOLID)
  else
    lcd.drawLine(x2, y2, x3, y3, DOTTED, FORCE)
  end
end

local function drawData(txt, y, dir, vc, vm, max, ext, frac, flags)
  lcd.drawText(0, y, txt, SMLSIZE)
  if data.showMax and dir > 0 then
    vc = vm
    lcd.drawText(14, y, dir == 1 and "\192" or "\193", SMLSIZE)
  end
  if frac ~= 0 and vc + 0.5 < max then
    lcd.drawNumber(21, y, vc * 10.02, SMLSIZE + frac + flags)
  else
    lcd.drawText(21, y, math.floor(vc + 0.5), SMLSIZE + flags)
  end
  if frac ~= 0 or vc < max then
    lcd.drawText(lcd.getLastPos(), y, ext, SMLSIZE + flags)
  end
end

local function run(event)
  lcd.clear()
  background()

  -- Minimum OpenTX version
  if (data.version < 2.2) then
    lcd.drawText(QX7 and 8 or 50, 27, "OpenTX v2.2+ Required")
    return 0
  end

  -- Startup message
  if data.startup == 1 then
    startupTime = getTime()
    data.startup = 2
  elseif data.startup == 2 then
    if getTime() - startupTime < 200 then
      if not QX7 then
        lcd.drawText(55, 9, "INAV Lua Telemetry")
      end
      lcd.drawText(QX7 and 55 or 93, 17, "v" .. VERSION)
    else
      data.startup = 0
    end
  end
  local startupTime = 0

  -- GPS
  if data.gpsLatLon ~= false then
    local gpsFlags = (data.telemFlags > 0 or not data.gpsFix) and FLASH or 0
    gpsData(math.floor(data.gpsAlt + 0.5) .. units[data.gpsAlt_unit], 17, gpsFlags)
    gpsData(math.floor(data.gpsLatLon.lat * GPS_DIGITS) / GPS_DIGITS, 25, gpsFlags)
    gpsData(math.floor(data.gpsLatLon.lon * GPS_DIGITS) / GPS_DIGITS, 33, gpsFlags)
  else
    lcd.drawFilledRectangle(RIGHT_POS - 41, 17, 41, 23, INVERS)
    lcd.drawText(RIGHT_POS - 37, 20, "No GPS", INVERS)
    lcd.drawText(RIGHT_POS - 28, 30, "Fix", INVERS)
  end
  gpsData("Sats " .. data.satellites % 100, 9, data.telemFlags)

  -- Directionals
  if data.showHead and data.startup == 0 then
    if event == EVT_ROT_LEFT or event == EVT_ROT_RIGHT or event == EVT_PLUS_BREAK or event == EVT_MINUS_BREAK then
      data.showDir = not data.showDir
    end
    if data.telemetry then
      local indicatorDisplayed = false
      if data.showDir or data.headingRef < 0 or not QX7 then
        lcd.drawText(X_CNTR_1 - 2, 9, "N " .. math.floor(data.heading + 0.5) .. "\64", SMLSIZE)
        lcd.drawText(X_CNTR_1 + 10, 21, "E", SMLSIZE)
        lcd.drawText(X_CNTR_1 - 14, 21, "W", SMLSIZE)
        if not QX7 then
          lcd.drawText(X_CNTR_1 - 2, 32, "S", SMLSIZE)
        end
        drawDirection(data.heading, 135, 7, X_CNTR_1, 23)
        indicatorDisplayed = true
      end
      if not data.showDir or data.headingRef >= 0 or not QX7 then
        if not indicatorDisplayed or not QX7 then
          drawDirection(data.heading - data.headingRef, 145, 8, QX7 and 67 or 135, 19)
        end
      end
    end
    if data.gpsLatLon ~= false and data.gpsHome ~= false and data.distanceLast >= data.distRef then
      if not data.showDir or not QX7 then
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
        lcd.drawLine(X_CNTR_2, 19, x1, y1, DOTTED, FORCE)
        lcd.drawFilledRectangle(x1 - 1, y1 - 1, 3, 3, ERASE)
        lcd.drawFilledRectangle(x1 - 1, y1 - 1, 3, 3, SOLID)
      end
    end
  end

  -- Flight mode
  lcd.drawText(0, 0, modes[data.modeId].t, (QX7 and SMLSIZE or 0) + modes[data.modeId].f)
  lcd.drawText(X_CNTR_2 - (lcd.getLastPos() / 2), 33, modes[data.modeId].t, (QX7 and SMLSIZE or 0) + modes[data.modeId].f)
  if data.headFree and not QX7 then
    lcd.drawText(lcd.getLastPos() + 1, 33, " HF ", FLASH)
  end

  -- User input
  if not data.armed and data.config == 0 then
    -- Toggle showing max/min values
    if event == EVT_ROT_LEFT or event == EVT_ROT_RIGHT or event == EVT_PLUS_BREAK or event == EVT_MINUS_BREAK then
      data.showMax = not data.showMax
    end
    -- Initalize variables on long <Enter>
    if event == EVT_ENTER_LONG then
      reset()
    end
  end

  -- Data & gauges
  local tmp = (data.telemFlags > 0 or data.fuel <= 20 or data.cell < config[3].v) and FLASH or 0
  if data.showAlt then
    drawData("Altd", 9, 1, data.altitude, data.altitudeMax, QX7 and 1000 or 10000, units[data.altitude_unit], 0, (data.telemFlags > 0 or data.altitude + 0.5 >= config[6].v) and FLASH or 0)
    if data.altHold then
      lcd.drawText(lcd.getLastPos() + 1, 9, "\192", SMLSIZE + INVERS)
    end
  end
  drawData("Dist", data.distPos, 1, data.distanceLast, data.distanceMax, QX7 and 1000 or 10000, units[data.distance_unit], 0, data.telemFlags)
  drawData("Sped", data.speedPos, 1, data.speed, data.speedMax, QX7 and 100 or 1000, units[data.speed_unit], 0, data.telemFlags)
  drawData("Batt", data.battPos1, 2, config[1].v == 0 and data.cell * 10 or data.batt, config[1].v == 0 and (data.battMin * 10 / data.cells) or data.battMin, QX7 and 100 or 1000, "V", config[1].v == 0 and PREC2 or PREC1, tmp, 1)
  drawData("RSSI", 57, 2, data.rssiLast, data.rssiMin, 200, "dB", 0, (data.telemFlags > 0 or data.rssi < data.rssiLow) and FLASH or 0)
  if data.showCurr then
    drawData("Curr", 33, 1, data.current, data.currentMax, 100, "A", PREC1, data.telemFlags)
    drawData("Fuel", 41, 0, data.fuel, 0, 200, "%", 0, tmp)
    lcd.drawGauge(46, 41, GAUGE_WIDTH, 7, math.min(data.fuel, 98), 100)
    if data.fuel == 0 then
      lcd.drawLine(47, 42, 47, 46, SOLID, ERASE)
    end
  end
  tmp = 100 / (4.2 - config[3].v + 0.1)
  lcd.drawGauge(46, data.battPos2, GAUGE_WIDTH, 56 - data.battPos2, math.min(math.max(data.cell - config[3].v + 0.1, 0) * tmp, 98), 100)
  tmp = (GAUGE_WIDTH - 2) * (math.min(math.max(data.cellMin - config[3].v + 0.1, 0) * tmp, 99) / 100) + 47
  lcd.drawLine(tmp, data.battPos2 + 1, tmp, 54, SOLID, ERASE)
  lcd.drawGauge(46, 57, GAUGE_WIDTH, 7, math.max(math.min((data.rssiLast - data.rssiCrit) / (100 - data.rssiCrit) * 100, 98), 0), 100)
  tmp = (GAUGE_WIDTH - 2) * (math.max(math.min((data.rssiMin - data.rssiCrit) / (100 - data.rssiCrit) * 100, 99), 0) / 100) + 47
  lcd.drawLine(tmp, 58, tmp, 62, SOLID, ERASE)
  if not QX7 and data.showAlt then
    local w = config[7].v == 1 and 7 or 15
    local l = config[7].v == 1 and 205 or 197
    lcd.drawRectangle(l, 9, w, 48, SOLID)
    tmp = math.max(math.min(math.ceil(data.altitude / config[6].v * 46), 46), 0)
    lcd.drawFilledRectangle(l + 1, 56 - tmp, w - 2, tmp, INVERS)
    tmp = 56 - math.max(math.min(math.ceil(data.altitudeMax / config[6].v * 46), 46), 0)
    lcd.drawLine(l + 1, tmp, l + w - 2, tmp, DOTTED, FORCE)
    lcd.drawText(l + 1, 58, config[7].v == 1 and "A" or "Alt", SMLSIZE)
  end

  -- Variometer
  if config[7].v == 1 then
    if QX7 and data.armed then
      lcd.drawLine(X_CNTR_2 + 15, 21, X_CNTR_2 + 17, 21, SOLID, FORCE)
      lcd.drawLine(X_CNTR_2 + 16, 21, X_CNTR_2 + 16, 21 - math.max(math.min(data.accZ - 1, 1), -1) * 12, SOLID, FORCE)
    elseif not QX7 then
      local w = data.showAlt and 7 or 15
      lcd.drawRectangle(197, 9, w, 48, SOLID)
      lcd.drawText(198, 58, data.showAlt and "V" or "Var", SMLSIZE)
      if data.armed then
        tmp = 33 - math.floor(math.max(math.min(data.accZ - 1, 1), -1) * 23 - 0.5)
        if tmp > 33 then
          lcd.drawFilledRectangle(198, 33, w - 2, tmp - 33, INVERS)
        else
          lcd.drawFilledRectangle(198, tmp - 1, w - 2, 33 - tmp + 2, INVERS)
        end
      end
    end
  end

  -- Title
  lcd.drawFilledRectangle(0, 0, LCD_W, 8, FORCE)
  lcd.drawText(0, 0, data.modelName, INVERS)
  if config[13].v > 0 then
    lcd.drawTimer(QX7 and 60 or 150, 1, data.timer, SMLSIZE + INVERS)
  end
  lcd.drawFilledRectangle(86, 1, 19, 6, ERASE)
  lcd.drawLine(105, 2, 105, 5, SOLID, ERASE)
  tmp = math.max(math.min((data.txBatt - data.txBattMin) / (data.txBattMax - data.txBattMin) * 17, 17), 0) + 86
  for i = 87, tmp, 2 do
    lcd.drawLine(i, 2, i, 5, SOLID, FORCE)
  end
  if not QX7 then
    lcd.drawNumber(110 , 1, data.txBatt * 10.01, SMLSIZE + PREC1 + INVERS)
    lcd.drawText(lcd.getLastPos(), 1, "V", SMLSIZE + INVERS)
  end
  if data.rxBatt > 0 and data.telemetry and config[14].v == 1 then
    lcd.drawNumber(LCD_W - 17, 1, data.rxBatt * 10.01, SMLSIZE + PREC1 + INVERS)
    lcd.drawText(lcd.getLastPos(), 1, "V", SMLSIZE + INVERS)
  end

  -- Config
  if not data.armed then
    if event == EVT_MENU_BREAK and data.config == 0 then
      data.config = 1
      configSelect = 0
      configTop = 1
    end
    if data.config > 0 then
      -- Display menu
      lcd.drawFilledRectangle(CONFIG_X, 10, 116, 52, ERASE)
      lcd.drawRectangle(CONFIG_X, 10, 116, 52, SOLID)
      for line = configTop, math.min(configValues, configTop + 5) do
        local y = (line - configTop) * 8 + 10 + 3
        local z = config[line].z
        tmp = (data.config == line and INVERS + configSelect or 0) + (config[z].d ~= nil and PREC1 or 0)
        config[z].p = (config[z].b ~= nil and config[config[config[z].b].z].v == 0) and 1 or nil
        lcd.drawText(CONFIG_X + 4, y, config[z].t, SMLSIZE)
        if config[z].p ~= nil then
          lcd.drawText(CONFIG_X + 78, y, "     ", SMLSIZE + tmp)
          lcd.drawLine(CONFIG_X + 77, y + 3, CONFIG_X + 91, y + 3, SOLID, FORCE)
        else
          if config[z].l == nil then
            lcd.drawNumber(CONFIG_X + 78, y, config[z].d ~= nil and config[z].v * 10 or config[z].v, SMLSIZE + tmp)
            if config[z].a ~= nil then
              lcd.drawText(lcd.getLastPos(), y, config[z].a, SMLSIZE + tmp)
            end
          else
            if not config[z].l then
              lcd.drawText(CONFIG_X + 78, y, config[z].v, SMLSIZE + tmp)
            else
              lcd.drawText(CONFIG_X + 78, y, config[z].l[config[z].v], SMLSIZE + tmp)
            end
          end
        end
      end

      if configSelect == 0 then
        if event == EVT_EXIT_BREAK then
          saveConfig()
          data.config = 0
        elseif event == EVT_ROT_RIGHT or event == EVT_MINUS_BREAK then -- Next option
          data.config = math.min(data.config + 1, configValues)
          if data.config > math.min(configValues, configTop + 5) then
            configTop = configTop + 1
          end
        elseif event == EVT_ROT_LEFT or event == EVT_PLUS_BREAK then -- Previous option
          data.config = math.max(data.config - 1, 1)
          if data.config < configTop then
            configTop = configTop - 1
          end
        end
      else
        local z = config[data.config].z
        if event == EVT_EXIT_BREAK then
          configSelect = 0
        elseif event == EVT_ROT_RIGHT or event == EVT_PLUS_BREAK then
          config[z].v = math.min(math.floor(config[z].v * 10 + config[z].i * 10) / 10, config[z].x == nil and 1 or config[z].x)
        elseif event == EVT_ROT_LEFT or event == EVT_MINUS_BREAK then
          config[z].v = math.max(math.floor(config[z].v * 10 - config[z].i * 10) / 10, config[z].m == nil and 0 or config[z].m)
        end

        -- Special cases
        if event then
          if z == 2 then -- Cell low > critical
            config[2].v = math.max(config[2].v, config[3].v + 0.1)
          elseif z == 3 then -- Cell critical < low
            config[3].v = math.min(config[3].v, config[2].v - 0.1)
          elseif config[z].i > 1 then
            config[z].v = math.floor(config[z].v / config[z].i) * config[z].i
          end
        end
      end

      if event == EVT_ENTER_BREAK then
        if config[config[data.config].z].p == nil then
          configSelect = (configSelect == 0) and BLINK or 0
        else
          playTone(2000, 100, 100, PLAY_NOW)
          playHaptic(25, 100)
        end
      end

    end
  end

  return 0
end

return {run = run, background = background}
