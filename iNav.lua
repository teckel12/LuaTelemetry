-- Lua Telemetry Flight Status Screen for INAV/Taranis
-- Version: 1.1.4
-- Author: https://github.com/teckel12
-- Docs: https://github.com/iNavFlight/LuaTelemetry

local WAVPATH = "/SCRIPTS/TELEMETRY/iNav/"
local FLASH = INVERS + BLINK
local QX7 = LCD_W < 212
local TIMER_POS = QX7 and 60 or 150
local RXBATT_POS = LCD_W - 17
local RIGHT_POS = QX7 and 129 or 195
local GAUGE_WIDTH = QX7 and 82 or 149
local MODE_POS = QX7 and 48 or 90
local MODE_SIZE = QX7 and SMLSIZE or 0
local X_CNTR_1 = QX7 and 67 or 70
local X_CNTR_2 = QX7 and 67 or 135
local X_CNTR_3 = QX7 and 67 or 107
local GPS_DIGITS = QX7 and 10000 or 1000000

local modeIdPrev = false
local armedPrev = false
local headingHoldPrev = false
local headFreePrev = false
local altHoldPrev = false
local gpsFixPrev = false
local altNextPlay = 0
local battNextPlay = 0
local battPercentPlayed = 100
local telemFlags = -1

-- Modes
--  t = text
--  f = flags for text
--  w = wave file
local modes = {
  { t="NO TELEM",  f=FLASH, w=false },
  { t="HORIZON",   f=0,     w="hrznmd.wav" },
  { t="ANGLE",     f=0,     w="anglmd.wav" },
  { t="ACRO",      f=0,     w="acromd.wav" },
  { t=" NOT OK ",  f=FLASH, w=false },
  { t="READY",     f=0,     w="ready.wav" },
  { t="POS HOLD",  f=0,     w="poshld.wav" },
  { t="3D HOLD",   f=0,     w="3dhold.wav" },
  { t="WAYPOINT",  f=0,     w="waypt.wav" },
  { t="   RTH   ", f=FLASH, w="rtl.wav" },
  { t="FAILSAFE",  f=FLASH, w="fson.wav" }
}

local units = { "?", "?", "?", "?", "mps", "fps", "kmh", "mph", "m", "ft" }

local function getTelemetryId(name)
  local field = getFieldInfo(name)
  return field and field.id or -1
end

local function getTelemetryUnit(name)
  local field = getFieldInfo(name)
  return (field and field.unit <= 10) and field.unit or 1
end

local rssi, low, crit = getRSSI()
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
  txBatt_id = getTelemetryId("tx-voltage"),
  ras_id = getTelemetryId("RAS"),
  gpsAlt_unit = getTelemetryUnit("GAlt"),
  altitude_unit = getTelemetryUnit("Alt"),
  distance_unit = getTelemetryUnit("Dist"),
  speed_unit = getTelemetryUnit("GSpd"),
  timerStart = 0,
  timer = 0,
  distLastPositive = 0,
  gpsHome = false,
  gpsLatLon = false,
  gpsFix = false,
  headingRef = -1,
  showMax = false,
  showDir = true,
  battlow = false,
  showCurr = true,
  fuel = 100
}

if data.current_id == -1 then
  data.showCurr = false
end
data.distPos = data.showCurr and 17 or 21
data.speedPos = data.showCurr and 25 or 33
data.battPos1 = data.showCurr and 49 or 45
data.battPos2 = data.showCurr and 49 or 41
data.distRef = data.distance_unit == 10 and 20 or 6
data.altAlert = data.altitude_unit == 10 and 400 or 123

local function flightModes()
  armed = false
  headFree = false
  headingHold = false
  altHold = false
  if data.telemetry then
    local modeA = data.mode / 10000
    local modeB = data.mode / 1000 % 10
    local modeC = data.mode / 100 % 10
    local modeD = data.mode / 10 % 10
    local modeE = data.mode % 10
    if bit32.band(modeE, 4) == 4 then
      armed = true
      if bit32.band(modeD, 2) == 2 then
        data.modeId = 2 -- Horizon
      elseif bit32.band(modeD, 1) == 1 then
        data.modeId = 3 -- Angle
      else
        data.modeId = 4 -- Acro
      end
      headFree = bit32.band(modeB, 4) == 4 and true or false
      headingHold = bit32.band(modeC, 1) == 1 and true or false
      altHold = bit32.band(modeC, 2) == 2 and true or false
      if bit32.band(modeC, 4) == 4 then
        data.modeId = altHold and 8 or 7 -- If also alt hold 3D hold else pos hold
      end
    end
    if bit32.band(modeE, 2) == 2 or modeE == 0 then
      data.modeId = 5 -- Not OK to arm
    elseif not armed then
      data.modeId = 6 -- Ready to fly
    end
    if bit32.band(modeA, 4) == 4 then
      data.modeId = 11 -- Failsafe
    elseif bit32.band(modeB, 1) == 1 then
      data.modeId = 10 -- RTH
    elseif bit32.band(modeB, 2) == 2 then
      data.modeId = 9 -- Waypoint
    end
  else
    data.modeId = 1 -- No telemetry
  end

  -- Voice alerts
  local vibrate = false
  local beep = false
  if armed and not armedPrev then -- Engines armed
    data.timerStart = getTime()
    data.distLastPositive = 0
    data.headingRef = data.heading
    data.gpsHome = false
    battPercentPlayed = 100
    data.battlow = false
    data.showMax = false
    data.showDir = false
    playFile(WAVPATH .. "engarm.wav")
  elseif not armed and armedPrev then -- Engines disarmed
    if data.distLastPositive <= data.distRef then
      data.headingRef = -1
      data.showDir = true
    end
    playFile(WAVPATH .. "engdrm.wav")
  end
  if data.gpsFix ~= gpsFixPrev then -- GPS status change
    playFile(WAVPATH .. "gps.wav")
    playFile(WAVPATH .. (data.gpsFix and "good.wav" or "lost.wav"))
  end
  if modeIdPrev and modeIdPrev ~= data.modeId then -- New flight mode
    if armed and modes[data.modeId].w then
      playFile(WAVPATH .. modes[data.modeId].w)
    elseif not armed and data.modeId == 6 and modeIdPrev == 5 then
      playFile(WAVPATH .. modes[data.modeId].w)
    end
  end
  if armed then
    if altHold ~= altHoldPrev and data.modeId ~= 8 then -- Alt hold status change
      playFile(WAVPATH .. "althld.wav")
      playFile(WAVPATH .. (altHold and "active.wav" or "off.wav"))
    end
    if headingHold ~= headingHoldPrev then -- Heading hold status change
      playFile(WAVPATH .. "hedhld.wav")
      playFile(WAVPATH .. (headingHold and "active.wav" or "off.wav"))
    end
    if headFree ~= headFreePrev then -- Head free status change
      playFile(WAVPATH .. (headFree and "hfact.wav" or "hfoff.wav"))
    end
    if data.altitude + 0.5 >= data.altAlert then -- Altitude alert
      if getTime() > altNextPlay then
        playNumber(data.altitude + 0.5, data.altitude_unit)
        altNextPlay = getTime() + 1000
      else
        beep = true
      end
    end
    if battPercentPlayed > data.fuel then -- Battery notification/alert
      if data.fuel == 30 or data.fuel == 25 then
        playFile(WAVPATH .. "batlow.wav")
        playNumber(data.fuel, 13)
        battPercentPlayed = data.fuel
      elseif data.fuel % 10 == 0 and data.fuel < 100 and data.fuel >= 40 then
        playFile(WAVPATH .. "battry.wav")
        playNumber(data.fuel, 13)
        battPercentPlayed = data.fuel
      end
    end
    if data.fuel <= 20 or data.cell < 3.40 then
      if getTime() > battNextPlay then
        playFile(WAVPATH .. "batcrt.wav")
        if data.fuel <= 20 and battPercentPlayed > data.fuel then
          playNumber(data.fuel, 13)
          battPercentPlayed = data.fuel
        end
        battNextPlay = getTime() + 500
      else
        vibrate = true
        beep = true
      end
      data.battlow = true
    elseif data.cell < 3.50 then
      if not data.battlow then
        playFile(WAVPATH .. "batlow.wav")
        data.battlow = true
      end
    else
      battNextPlay = 0
    end
    if headFree or modes[data.modeId].f > 0 then
      beep = true
      vibrate = true
    elseif data.rssi < data.rssiLow then
      if data.rssi < data.rssiCrit then
        vibrate = true
      end
      beep = true
    end
    if vibrate then
      playHaptic(25, 3000)
    end
    if beep then
      playTone(2000, 100, 3000, PLAY_NOW)
    end
  else
    data.battlow = false
    battPercentPlayed = 100
  end
  modeIdPrev = data.modeId
  headingHoldPrev = headingHold
  headFreePrev = headFree
  altHoldPrev = altHold
  armedPrev = armed
  gpsFixPrev = data.gpsFix
end

local function background()
  data.rssi = getValue(data.rssi_id)
  if data.rssi > 0 or telemFlags < 0 then
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
    data.cells = math.floor(data.batt/4.3) + 1
    data.cell = data.batt/data.cells
    data.cellMin = data.battMin/data.cells
    data.rssiMin = getValue(data.rssiMin_id)
    data.txBatt = getValue(data.txBatt_id)
    data.rssiLast = data.rssi
    local gpsTemp = getValue(data.gpsLatLon_id)
    data.gpsFix = data.satellites > 3900 and type(gpsTemp) == "table" and gpsTemp.lat ~= nil and gpsTemp.lon ~= nil
    if data.gpsFix then
      data.gpsLatLon = gpsTemp
      --data.distance = 70
      --data.gpsLatLon.lat = math.deg(data.gpsLatLon.lat)
      --data.gpsLatLon.lon = math.deg(data.gpsLatLon.lon * 2.1064)
    end
    -- Dist doesn't have a known unit so the transmitter doesn't auto-convert
    if data.distance_unit == 10 then
      data.distance = math.floor(data.distance * 3.28084 + 0.5)
      data.distanceMax = math.floor(data.distanceMax * 3.28084 + 0.5)
    end
    if data.distance > 0 then
      data.distLastPositive = data.distance
    end
    telemFlags = 0
  else
    data.telemetry = false
    telemFlags = FLASH
  end

  flightModes()

  if armed and data.gpsFix and data.gpsHome == false then
    data.gpsHome = data.gpsLatLon
  end
end

local function gpsData(t, y, f)
  lcd.drawText(RIGHT_POS - 51, 9, t, SMLSIZE)
  local x = RIGHT_POS - 51 + (RIGHT_POS - lcd.getLastPos())
  lcd.drawText(x, y, t, SMLSIZE + f)
end

local function drawDirection(h, w, s, x, y)
  local rad1 = math.rad(h)
  local rad2 = math.rad(h + w)
  local rad3 = math.rad(h - w)
  local x1 = math.floor(math.sin(rad1) * s + 0.5) + x
  local y1 = y - math.floor(math.cos(rad1) * s + 0.5)
  local x2 = math.floor(math.sin(rad2) * s + 0.5) + x
  local y2 = y - math.floor(math.cos(rad2) * s + 0.5)
  local x3 = math.floor(math.sin(rad3) * s + 0.5) + x
  local y3 = y - math.floor(math.cos(rad3) * s + 0.5)
  lcd.drawLine(x1, y1, x2, y2, SOLID, FORCE)
  lcd.drawLine(x1, y1, x3, y3, SOLID, FORCE)
  if headingHold then
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
  if frac then
    lcd.drawNumber(22, y, vc * 10.05, SMLSIZE + PREC1 + flags)
  else
    lcd.drawText(22, y, math.floor(vc + 0.5), SMLSIZE + flags)
  end
  if vc < max then
    lcd.drawText(lcd.getLastPos(), y, ext, SMLSIZE + flags)
  end
end

local function run(event)
  lcd.clear()
  background()

  -- Title
  if armed then
    data.timer = (getTime() - data.timerStart) / 100
  end
  lcd.drawFilledRectangle(0, 0, LCD_W, 8)
  lcd.drawText(0, 0, data.modelName, INVERS)
  lcd.drawTimer(TIMER_POS, 1, data.timer, SMLSIZE + INVERS)
  lcd.drawFilledRectangle(86, 1, 19, 6, ERASE)
  lcd.drawLine(105, 2, 105, 5, SOLID, ERASE)
  local battGauge = math.max(math.min((data.txBatt - data.txBattMin) / (data.txBattMax - data.txBattMin) * 17, 17), 0) + 86
  for i = 87, battGauge, 2 do
    lcd.drawLine(i, 2, i, 5, SOLID, FORCE)
  end
  if not QX7 then
    lcd.drawNumber(110 , 1, data.txBatt * 10.05, SMLSIZE + PREC1 + INVERS)
    lcd.drawText(lcd.getLastPos(), 1, "V", SMLSIZE + INVERS)
  end
  if data.rxBatt > 0 and data.telemetry then
    lcd.drawNumber(RXBATT_POS, 1, data.rxBatt * 10.05, SMLSIZE + PREC1 + INVERS)
    lcd.drawText(lcd.getLastPos(), 1, "V", SMLSIZE + INVERS)
  end

  -- GPS
  if data.gpsLatLon ~= false then
    local gpsFlags = (telemFlags > 0 or not data.gpsFix) and FLASH or 0
    gpsData(math.floor(data.gpsAlt + 0.5) .. units[data.gpsAlt_unit], 17, gpsFlags)
    gpsData(math.floor(data.gpsLatLon.lat * GPS_DIGITS + 0.5) / GPS_DIGITS, 25, gpsFlags)
    gpsData(math.floor(data.gpsLatLon.lon * GPS_DIGITS + 0.5) / GPS_DIGITS, 33, gpsFlags)
  else
    lcd.drawFilledRectangle(RIGHT_POS - 41, 17, 41, 23, INVERS)
    lcd.drawText(RIGHT_POS - 37, 20, "No GPS", INVERS)
    lcd.drawText(RIGHT_POS - 28, 30, "Fix", INVERS)
  end
  gpsData("    Sats " .. data.satellites % 100, 9, telemFlags)

  -- Directionals
  if event == EVT_ROT_LEFT or event == EVT_ROT_RIGHT or event == EVT_PLUS_BREAK or event == EVT_MINUS_BREAK then
    data.showDir = not data.showDir
  end
  if data.telemetry then
    local indicatorDisplayed = false
    if data.showDir or data.headingRef < 0 or not QX7 then
      lcd.drawText(X_CNTR_1 - 2, 9, "N " .. math.floor(data.heading + 0.5) .. "\64", SMLSIZE)
      lcd.drawText(X_CNTR_1 + 10, 21, "E", SMLSIZE)
      lcd.drawText(X_CNTR_1 - 14, 21, "W", SMLSIZE)
      drawDirection(data.heading, 135, 7, X_CNTR_1, 23)
      indicatorDisplayed = true
    end
    if not data.showDir or data.headingRef >= 0 or not QX7 then
      if not indicatorDisplayed or not QX7 then
        drawDirection(data.heading - data.headingRef, 145, 8, X_CNTR_2, 19)
      end
    end
  end
  if data.gpsLatLon ~= false and data.gpsHome ~= false and data.distLastPositive >= data.distRef then
    if not data.showDir or not QX7 then
      local o1 = math.rad(data.gpsHome.lat)
      local a1 = math.rad(data.gpsHome.lon)
      local o2 = math.rad(data.gpsLatLon.lat)
      local a2 = math.rad(data.gpsLatLon.lon)
      local y = math.sin(a2 - a1) * math.cos(o2)
      local x = (math.cos(o1) * math.sin(o2)) - (math.sin(o1) * math.cos(o2) * math.cos(a2 - a1))
      local bearing = math.deg(math.atan2(y, x)) - data.headingRef
      local rad1 = math.rad(bearing)
      local x1 = math.floor(math.sin(rad1) * 10 + 0.5) + X_CNTR_3
      local y1 = 19 - math.floor(math.cos(rad1) * 10 + 0.5)
      lcd.drawLine(X_CNTR_3, 19, x1, y1, DOTTED, FORCE)
      lcd.drawFilledRectangle(x1 - 1, y1 - 1, 3, 3, ERASE)
      lcd.drawFilledRectangle(x1 - 1, y1 - 1, 3, 3, SOLID)
    end
  end

  -- Flight mode
  lcd.drawText(48, 34, modes[data.modeId].t, MODE_SIZE + modes[data.modeId].f)
  pos = MODE_POS + (87 - lcd.getLastPos()) / 2
  lcd.drawFilledRectangle(47, 33, QX7 and 41 or 50, 9, ERASE)
  lcd.drawText(pos, 33, modes[data.modeId].t, MODE_SIZE + modes[data.modeId].f)
  if headFree then
    if QX7 then
      lcd.drawText(84, 17, "HF", SMLSIZE + FLASH)
    else
      lcd.drawText(lcd.getLastPos() + 2, 33, " HF ", FLASH)
    end
  end

  -- Data & gauges
  if not armed then
    if event == EVT_ROT_LEFT or event == EVT_ROT_RIGHT or event == EVT_PLUS_BREAK or event == EVT_MINUS_BREAK then
      data.showMax = not data.showMax
    end
  end
  local altFlags = (telemFlags > 0 or data.altitude + 0.5 >= data.altAlert) and FLASH or 0
  local battFlags = (telemFlags > 0 or data.battlow) and FLASH or 0
  local rssiFlags = (telemFlags > 0 or data.rssi < data.rssiLow) and FLASH or 0
  drawData("Altd", 9, 1, data.altitude, data.altitudeMax, 1000, units[data.altitude_unit], false, altFlags)
  if altHold then
    lcd.drawText(lcd.getLastPos() + 1, 9, "\192", SMLSIZE + INVERS)
  end
  drawData("Dist", data.distPos, 1, data.distLastPositive, data.distanceMax, 1000, units[data.distance_unit], false, telemFlags)
  drawData("Sped", data.speedPos, 1, data.speed, data.speedMax, 100, units[data.speed_unit], false, telemFlags)
  drawData("Batt", data.battPos1, 2, data.batt, data.battMin, 100, "V", true, battFlags)
  drawData("RSSI", 57, 2, data.rssiLast, data.rssiMin, 100, "dB", false, rssiFlags)
  if data.showCurr then
    drawData("Curr", 33, 1, data.current, data.currentMax, 100, "A", true, telemFlags)
    drawData("Fuel", 41, 0, data.fuel, 0, 100, "%", false, battFlags)
    lcd.drawGauge(46, 41, GAUGE_WIDTH, 7, math.min(data.fuel, 98), 100)
    if data.fuel == 0 then
      lcd.drawLine(47, 42, 47, 46, SOLID, ERASE)
    end
  end
  lcd.drawGauge(46, data.battPos2, GAUGE_WIDTH, 56 - data.battPos2, math.min(math.max(data.cell - 3.3, 0) * 111.1, 98), 100)
  min = (GAUGE_WIDTH - 2) * (math.min(math.max(data.cellMin - 3.3, 0) * 111.1, 99) / 100) + 47
  lcd.drawLine(min, data.battPos2 + 1, min, 54, SOLID, ERASE)
  local rssiGauge = math.max(math.min((data.rssiLast - data.rssiCrit) / (100 - data.rssiCrit) * 100, 98), 0)
  lcd.drawGauge(46, 57, GAUGE_WIDTH, 7, rssiGauge, 100)
  min = (GAUGE_WIDTH - 2) * (math.max(math.min((data.rssiMin - data.rssiCrit) / (100 - data.rssiCrit) * 100, 99), 0) / 100) + 47
  lcd.drawLine(min, 58, min, 62, SOLID, ERASE)
  if not QX7 then
    lcd.drawRectangle(197, 9, 15, 48, SOLID)
    local height = math.max(math.min(math.ceil(data.altitude / data.altAlert * 46), 46), 0)
    lcd.drawFilledRectangle(198, 56 - height, 13, height, INVERS)
    local max = 56 - math.max(math.min(math.ceil(data.altitudeMax / data.altAlert * 46), 46), 0)
    lcd.drawLine(198, max, 210, max, DOTTED, FORCE)
    lcd.drawText(198, 58, "Alt", SMLSIZE)
  end

  return 1
end

return {run = run, background = background}