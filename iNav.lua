-- Lua Telemetry Flight Status Screen for INAV/Taranis
-- Version: 1.1.2
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
local X_CNTR_1 = QX7 and 67 or 70
local X_CNTR_2 = QX7 and 67 or 135
local X_CNTR_3 = QX7 and 67 or 107
local GPS_DIGITS = QX7 and 10000 or 1000000

local modeIdPrev = false
local armedPrev = false
local headingHoldPrev = false
local altHoldPrev = false
local gpsFixPrev = false
local altNextPlay = 0
local battNextPlay = 0
local battPercentPlayed = 100
local telemFlags = -1

-- Modes
--  t = text
--  f = flags for text
--  a = show alititude hold
--  w = wave file
local modes = {
  { t="NO TELEM",  f=FLASH, a=false, w=false },
  { t="HORIZON",   f=0,     a=true,  w="hrznmd.wav" },
  { t="ANGLE",     f=0,     a=true,  w="anglmd.wav" },
  { t="ACRO",      f=0,     a=true,  w="acromd.wav" },
  { t=" NOT OK ",  f=FLASH, a=false, w=false },
  { t="READY",     f=0,     a=false, w="ready.wav" },
  { t="POS HOLD",  f=0,     a=true,  w="poshld.wav" },
  { t="3D HOLD",   f=0,     a=true,  w="3dhold.wav" },
  { t="WAYPOINT",  f=0,     a=false, w="waypt.wav" },
  { t="   RTH   ", f=FLASH, a=false, w="rtl.wav" },
  { t="FAILSAFE",  f=FLASH, a=false, w="fson.wav" },
}

local data = {}

local function getTelemetryId(name)
  local field = getFieldInfo(name)
  if field then
   return field.id
  else
   return -1
  end
end

local function flightModes()
  armed = false
  headFree = false
  headingHold = false
  altHold = false
  ok2arm = false
  posHold = false
  if data.telemetry then
    local modeA = math.floor(data.mode / 10000)
    local modeB = math.floor(data.mode / 1000) % 10
    local modeC = math.floor(data.mode / 100) % 10
    local modeD = math.floor(data.mode / 10) % 10
    local modeE = data.mode % 10
    if bit32.band(modeE, 4) == 4 then
      armed = true
      if bit32.band(modeD, 2) == 2 then
        data.modeId = 2
      elseif bit32.band(modeD, 1) == 1 then
        data.modeId = 3
      else
        data.modeId = 4
      end
    end
    if bit32.band(modeE, 2) == 2 or modeE == 0 then
      data.modeId = 5
    else
      ok2arm = true
      if not armed then
        data.modeId = 6
      end
    end
    if bit32.band(modeB, 4) == 4 then
      headFree = true
    end
    if bit32.band(modeC, 4) == 4 then
      if armed then
        data.modeId = 7
        posHold = true
      end
    end
    if bit32.band(modeC, 2) == 2 then
      altHold = true
      if posHold then
        data.modeId = 8
      end
    end
    if bit32.band(modeC, 1) == 1 then
      headingHold = true
    end  
    if bit32.band(modeA, 4) == 4 then
      data.modeId = 11
    elseif bit32.band(modeB, 1) == 1 then
      data.modeId = 10
    elseif bit32.band(modeB, 2) == 2 then
      data.modeId = 9
    end
  else
    data.modeId = 1
  end

  -- Flight mode feedback
  local vibrate = false
  local beep = false
  if armed and not armedPrev then
    data.timerStart = getTime()
    data.distLastPositive = 0
    data.headingRef = data.heading
    data.gpsHome = false
    battPercentPlayed = 100
    data.battlow = false
    data.showMax = false
    data.showDir = false
    playFile(WAVPATH .. "engarm.wav")
  elseif not armed and armedPrev then
    if data.distLastPositive < 15 then
      data.headingRef = -1
      data.showDir = true
    end
    playFile(WAVPATH .. "engdrm.wav")
  end
  if data.gpsFix and not gpsFixPrev then
    playFile(WAVPATH .. "gps.wav")
    playFile(WAVPATH .. "good.wav")
  elseif not data.gpsFix and gpsFixPrev then
    playFile(WAVPATH .. "gps.wav")
    playFile(WAVPATH .. "lost.wav")
  end
  if modeIdPrev and modeIdPrev ~= data.modeId then
    if not armed and data.modeId == 6 and modeIdPrev == 5 then
      playFile(WAVPATH .. modes[data.modeId].w)
    end
    if armed then
      if modes[data.modeId].w then
        playFile(WAVPATH .. modes[data.modeId].w)
      end
      if modes[data.modeId].f > 0 then
        vibrate = true
      end
    end
  end
  if armed then
    if altHold and modes[data.modeId].a and altHoldPrev ~= altHold then
      playFile(WAVPATH .. "althld.wav")
      playFile(WAVPATH .. "active.wav")
    elseif not altHold and modes[data.modeId].a and altHoldPrev ~= altHold then
      playFile(WAVPATH .. "althld.wav")
      playFile(WAVPATH .. "off.wav")
    end
    if headingHold and headingHoldPrev ~= headingHold then
      playFile(WAVPATH .. "hedhlda.wav")
    elseif not headingHold and headingHoldPrev ~= headingHold then
      playFile(WAVPATH .. "hedhld.wav")
      playFile(WAVPATH .. "off.wav")
    end
    if data.altitude > 400 then
      if getTime() > altNextPlay then
        playNumber(data.altitude, 10)
        altNextPlay = getTime() + 1000
      else
        beep = true
      end
    end
    if battPercentPlayed > data.fuel then
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
    end
    if data.rssi < data.rssiLow then
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
  altHoldPrev = altHold
  armedPrev = armed
  gpsFixPrev = data.gpsFix
end

local function init()
  local rssi, low, crit = getRSSI()
  data.rssiLow = low
  data.rssiCrit = crit
  local general = getGeneralSettings()
  data.txBattMin = general.battMin
  data.txBattMax = general.battMax
  --data.units = general.imperial
  data.modelName = model.getInfo()["name"]
  data.mode_id = getTelemetryId("Tmp1")
  data.rxBatt_id = getTelemetryId("RxBt")
  data.satellites_id = getTelemetryId("Tmp2")
  data.gpsAlt_id = getTelemetryId("GAlt")
  data.gpsLatLon_id = getTelemetryId("GPS")
  data.heading_id = getTelemetryId("Hdg")
  data.altitude_id = getTelemetryId("Alt")
  data.distance_id = getTelemetryId("Dist")
  data.speed_id = getTelemetryId("GSpd")
  data.current_id = getTelemetryId("Curr")
  data.altitudeMax_id = getTelemetryId("Alt+")
  data.distanceMax_id = getTelemetryId("Dist+")
  data.speedMax_id = getTelemetryId("GSpd+")
  data.currentMax_id = getTelemetryId("Curr+")
  data.batt_id = getTelemetryId("VFAS")
  data.battMin_id = getTelemetryId("VFAS-")
  data.fuel_id = getTelemetryId("Fuel")
  data.rssi_id = getTelemetryId("RSSI")
  data.rssiMin_id = getTelemetryId("RSSI-")
  data.txBatt_id = getTelemetryId("tx-voltage")
  data.ras_id = getTelemetryId("RAS")
  data.timerStart = 0
  data.timer = 0
  data.distLastPositive = 0
  data.gpsHome = false
  data.gpsLatLon = false
  data.gpsFix = false
  data.headingRef = -1
  data.showMax = false
  data.showDir = true
  data.battlow = false
  data.showCurr = true
  data.battPos1 = 49
  data.battPos2 = 49
  if data.current_id == -1 or data.fuel_id == -1 then
    data.showCurr = false
    data.current = 0
    data.currentMax = 0
    data.fuel = 100
    data.battPos1 = 45
    data.battPos2 = 41
  end
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
    data.distance = math.floor(getValue(data.distance_id) * 3.28084 + 0.5)
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
      --data.distance = 237
      --data.gpsLatLon.lat = math.deg(data.gpsLatLon.lat)
      --data.gpsLatLon.lon = math.deg(data.gpsLatLon.lon * 2.2)
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
  if headingHold and armed then
    lcd.drawFilledRectangle((x2 + x3) / 2 - 1.5, (y2 + y3) / 2 - 1.5, 4, 4, SOLID)
  else
    lcd.drawLine(x2, y2, x3, y3, DOTTED, FORCE)
  end
end

local function drawData(t, y, d, v, m, e, p, f)
  lcd.drawText(0, y, t, SMLSIZE)
  if d == 1 then
    lcd.drawText(15, y, "\192", SMLSIZE)
  elseif d == 2 then
    lcd.drawText(15, y, "\193", SMLSIZE)
  end
  if p then
    lcd.drawNumber(22, y, v * 10.05, SMLSIZE + PREC1 + f)
  else
    lcd.drawText(22, y, math.floor(v + 0.5), SMLSIZE + f)
  end
  if v < m then
    lcd.drawText(lcd.getLastPos(), y, e, SMLSIZE + f)
  end
end

local function drawAltHold()
  if armed and altHold and modes[data.modeId].a then
    lcd.drawText(lcd.getLastPos() + 1, 9, "\192", SMLSIZE + INVERS)
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
    gpsData(math.floor(data.gpsAlt + 0.5) .. "ft", 17, gpsFlags)
    gpsData(math.floor(data.gpsLatLon.lat * GPS_DIGITS + 0.5) / GPS_DIGITS, 25, gpsFlags)
    gpsData(math.floor(data.gpsLatLon.lon * GPS_DIGITS + 0.5) / GPS_DIGITS, 33, gpsFlags)
  else
    lcd.drawFilledRectangle(RIGHT_POS - 41, 17, 41, 23, INVERS)
    lcd.drawText(RIGHT_POS - 37, 20, "No GPS", INVERS)
    lcd.drawText(RIGHT_POS - 28, 30, "Fix", INVERS)
  end
  gpsData("    Sats " .. tonumber(string.sub(data.satellites, -2)), 9, telemFlags)

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
  if data.gpsLatLon ~= false and data.gpsHome ~= false and data.distLastPositive >= 25 then
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
  lcd.drawText(48, 34, modes[data.modeId].t, SMLSIZE + modes[data.modeId].f)
  pos = MODE_POS + (87 - lcd.getLastPos()) / 2
  lcd.drawFilledRectangle(46, 33, 40, 10, ERASE)
  lcd.drawText(pos, 33, modes[data.modeId].t, SMLSIZE + modes[data.modeId].f)
  if armed and headFree then
    lcd.drawText(85, 9, "HF", SMLSIZE + FLASH)
  end

  -- Data & gauges
  if not armed then
    if event == EVT_ROT_LEFT or event == EVT_ROT_RIGHT or event == EVT_PLUS_BREAK or event == EVT_MINUS_BREAK then
      data.showMax = not data.showMax
    end
  end
  local battFlags = (telemFlags > 0 or data.battlow) and FLASH or 0
  local rssiFlags = (telemFlags > 0 or data.rssi < data.rssiLow) and FLASH or 0
  if data.showMax then
    drawData("Alt", 9, 1, data.altitudeMax, 1000, "ft", false, telemFlags)
    drawAltHold()
    drawData("Dst", 17, 1, data.distanceMax * 3.28084, 1000, "ft", false, telemFlags)
    drawData("Spd", 25, 1, data.speedMax, 100, "mph", false, telemFlags)
    if data.showCurr then
      drawData("Cur", 33, 1, data.currentMax, 100, "A", true, telemFlags)
    end
    drawData("Bat", data.battPos1, 2, data.battMin, 100, "V", true, battFlags)
    drawData("RSI", 57, 2, data.rssiMin, 100, "dB", false, rssiFlags)
  else
    drawData("Altd", 9, 0, data.altitude, 1000, "ft", false, telemFlags)
    drawAltHold()
    drawData("Dist", 17, 0, data.distLastPositive, 1000, "ft", false, telemFlags)
    drawData("Sped", 25, 0, data.speed, 100, "mph", false, telemFlags)
    if data.showCurr then
      drawData("Curr", 33, 0, data.current, 100, "A", true, telemFlags)
    end
    drawData("Batt", data.battPos1, 0, data.batt, 100, "V", true, battFlags)
    drawData("RSSI", 57, 0, data.rssiLast, 100, "dB", false, rssiFlags)
  end
  if data.showCurr then
    drawData("Fuel", 41, 0, data.fuel, 100, "%", false, battFlags)
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
    lcd.drawRectangle(199, 9, 13, 48, SOLID)
    local height = math.max(math.min(math.ceil(data.altitude / 400 * 46), 46), 0)
    lcd.drawFilledRectangle(200, 56 - height, 11, height, INVERS)
    local max = 56 - math.max(math.min(math.ceil(data.altitudeMax / 400 * 46), 46), 0)
    lcd.drawLine(200, max, 210, max, DOTTED, FORCE)
    lcd.drawText(199, 58, "Alt", SMLSIZE)
  end

  return 1
end

return {init = init, run = run, background = background}