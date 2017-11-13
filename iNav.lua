-- Lua Telemetry Flight Status Screen for INAV/Taranis
-- Author: https://github.com/teckel12
-- Docs: https://github.com/iNavFlight/LuaTelemetry

-- Values that can be changed
local SHOW_CELL = false -- false = Show total battery voltage / true = Show cell average (default = false)
local BATT_LOW = 3.5    -- Battery warning level per cell in volts (default = 3.5)
local BATT_CRIT = 3.4   -- Critical battery level per cell in volts (default = 3.4)
local FILE_PATH = "/SCRIPTS/TELEMETRY/iNav/" -- Path to iNav telemetry files

local VERSION = "1.1.8"
local lcd = LCD or lcd
local LCD_W = lcd.W or LCD_W
local LCD_H = lcd.H or LCD_H
local FLASH = 3
local QX7 = LCD_W < 212
local RIGHT_POS = QX7 and 129 or 195
local GAUGE_WIDTH = QX7 and 82 or 149
local X_CNTR_1 = QX7 and 67 or 70
local X_CNTR_2 = QX7 and 67 or 106
local GPS_DIGITS = QX7 and 10000 or 1000000

local armed = false
local headFree = false
local headingHold = false
local altHold = false
local homeResetPrev = false
local gpsFixPrev = false
local altNextPlay = 0
local battNextPlay = 0
local battPercentPlayed = 100
local telemFlags = -1

local units = { [0]="m", "V", "A", "mA", "kts", "m/s", "f/s", "kmh", "mph", "m", "ft" }

local data = loadScript(FILE_PATH .. "data.lua")()

local currentFlightMode = loadScript(FILE_PATH .. "modes.lua")(data.modeId) 

local function flightModes()
  local armedPrev = armed
  local headFreePrev = headFree
  local headingHoldPrev = headingHold
  local altHoldPrev = altHold
  local homeReset = false
  local modeIdPrev = data.modeId
  armed = false
  headFree = false
  headingHold = false
  altHold = false
  data.modeId = 1 -- No telemetry
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
      homeReset = data.satellites >= 4000 and true or false
      if bit32.band(modeC, 4) == 4 then
        data.modeId = altHold and 8 or 7 -- If also alt hold 3D hold else pos hold
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
  if armed and not armedPrev then -- Engines armed
    data.timerStart = getTime()
    data.headingRef = data.heading
    data.gpsHome = false
    battPercentPlayed = 100
    data.battlow = false
    data.showMax = false
    data.showDir = false
    playFile(FILE_PATH .. "engarm.wav")
  elseif not armed and armedPrev then -- Engines disarmed
    if data.distanceLast <= data.distRef then
      data.headingRef = -1
      data.showDir = true
    end
    playFile(FILE_PATH .. "engdrm.wav")
  end
  if data.gpsFix ~= gpsFixPrev then -- GPS status change
    playFile(FILE_PATH .. "gps.wav")
    playFile(FILE_PATH .. (data.gpsFix and "good.wav" or "lost.wav"))
  end
  if modeIdPrev ~= data.modeId then -- New flight mode
    currentFlightMode = loadScript(FILE_PATH .. "modes.lua")(data.modeId)
    if armed and currentFlightMode.w then
      playFile(FILE_PATH .. currentFlightMode.w)
    elseif not armed and data.modeId == 6 and modeIdPrev == 5 then
      playFile(FILE_PATH .. currentFlightMode.w)
    end
  end
  if armed then
    data.distanceLast = data.distance
    data.timer = (getTime() - data.timerStart) / 100 -- Armed so update timer    
    if altHold ~= altHoldPrev and data.modeId ~= 8 then -- Alt hold status change
      playFile(FILE_PATH .. "althld.wav")
      playFile(FILE_PATH .. (altHold and "active.wav" or "off.wav"))
    end
    if headingHold ~= headingHoldPrev then -- Heading hold status change
      playFile(FILE_PATH .. "hedhld.wav")
      playFile(FILE_PATH .. (headingHold and "active.wav" or "off.wav"))
    end
    if headFree ~= headFreePrev then -- Head free status change
      playFile(FILE_PATH .. (headFree and "hfact.wav" or "hfoff.wav"))
    end
    if homeReset and not homeResetPrev then -- Home reset
      playFile(FILE_PATH .. "homrst.wav")
      data.gpsHome = false
      data.headingRef = data.heading
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
        playFile(FILE_PATH .. "batlow.wav")
        playNumber(data.fuel, 13)
        battPercentPlayed = data.fuel
      elseif data.fuel % 10 == 0 and data.fuel < 100 and data.fuel >= 40 then
        playFile(FILE_PATH .. "battry.wav")
        playNumber(data.fuel, 13)
        battPercentPlayed = data.fuel
      end
    end
    if data.fuel <= 20 or data.cell < BATT_CRIT then
      if getTime() > battNextPlay then
        playFile(FILE_PATH .. "batcrt.wav")
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
    elseif data.cell < BATT_LOW then
      if not data.battlow then
        playFile(FILE_PATH .. "batlow.wav")
        data.battlow = true
      end
    else
      battNextPlay = 0
    end
    if headFree or currentFlightMode.f ~= 0 then
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
  gpsFixPrev = data.gpsFix
  homeResetPrev = homeReset
end

local function background()
  data.rssi = getValue(data.rssi_id)
  if telemFlags == -1 then
    loadScript(FILE_PATH .. "reset.lua")(data)
  end
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
    data.cells = math.floor(data.batt / 4.3) + 1
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
      data.distanceMax = data.distanceMax * 3.28084
    end
    if data.distance > 0 then
      data.distanceLast = data.distance
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
  if frac and vc + 0.5 < max then
    lcd.drawNumber(22, y, vc * 10.05, SMLSIZE + PREC1 + flags)
  else
    lcd.drawText(22, y, math.floor(vc + 0.5), SMLSIZE + flags)
  end
  if frac or vc < max then
    lcd.drawText(lcd.getLastPos(), y, ext, SMLSIZE + flags)
  end
end

local function run(event)
  lcd.clear()
  background()

  -- Minimum OpenTX version
  if (data.version < 2.2) then
    lcd.drawText(QX7 and 5 or 47, 27, "OpenTX v2.2.0+ Required")
    --popupWarning("OpenTX v2.2+ Required", 0);
    return 0
  end

  -- GPS
  if data.gpsLatLon ~= false then
    local gpsFlags = (telemFlags > 0 or not data.gpsFix) and FLASH or 0
    gpsData(math.floor(data.gpsAlt + 0.5) .. units[data.gpsAlt_unit], 17, gpsFlags)
    gpsData(math.floor(data.gpsLatLon.lat * GPS_DIGITS) / GPS_DIGITS, 25, gpsFlags)
    gpsData(math.floor(data.gpsLatLon.lon * GPS_DIGITS) / GPS_DIGITS, 33, gpsFlags)
  else
    lcd.drawFilledRectangle(RIGHT_POS - 41, 17, 41, 23, INVERS)
    lcd.drawText(RIGHT_POS - 37, 20, "No GPS", INVERS)
    lcd.drawText(RIGHT_POS - 28, 30, "Fix", INVERS)
  end
  gpsData("Sats " .. data.satellites % 100, 9, telemFlags)

  -- Startup message
  if data.startup == 1 then
    startupTime = getTime()
    data.startup = 2
  elseif data.startup == 2 then
    if getTime() - startupTime < 200 then
      if not QX7 then
        lcd.drawText(55, 9, "iNav Lua Telemetry")
      end
      lcd.drawText(QX7 and 55 or 93, 17, "v" .. VERSION)
      data.showHead = false
    else
      data.startup = 0
    end
  end
  local startupTime = 0

  -- Directionals
  if data.showHead then
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
  lcd.drawText(0, 0, currentFlightMode.t, (QX7 and SMLSIZE or 0) + currentFlightMode.f)
  local x = X_CNTR_2 - (lcd.getLastPos() / 2)
  lcd.drawText(x, 33, currentFlightMode.t, (QX7 and SMLSIZE or 0) + currentFlightMode.f)
  if headFree then
    if QX7 then
      lcd.drawText(63, 9, "HF", SMLSIZE + FLASH)
    else
      lcd.drawText(lcd.getLastPos() + 2, 33, " HF ", FLASH)
    end
  end

  -- User input
  if not armed then
    if event == EVT_ROT_LEFT or event == EVT_ROT_RIGHT or event == EVT_PLUS_BREAK or event == EVT_MINUS_BREAK then
      data.showMax = not data.showMax
    end
    -- Initalize variables on long <Enter>
    if not armed and event == EVT_ENTER_LONG then
      loadScript(FILE_PATH .. "reset.lua")(data)
    end
  end

  -- Data & gauges
  local altFlags = (telemFlags > 0 or data.altitude + 0.5 >= data.altAlert) and FLASH or 0
  local battFlags = (telemFlags > 0 or data.battlow) and FLASH or 0
  local rssiFlags = (telemFlags > 0 or data.rssi < data.rssiLow) and FLASH or 0
  local battNow = SHOW_CELL and data.cell or data.batt
  local battLow = SHOW_CELL and (data.battMin / data.cells) or data.battMin
  if data.showAlt then
    drawData("Altd", 9, 1, data.altitude, data.altitudeMax, QX7 and 1000 or 10000, units[data.altitude_unit], false, altFlags)
    if altHold then
      lcd.drawText(lcd.getLastPos() + 1, 9, "\192", SMLSIZE + INVERS)
    end
  end
  drawData("Dist", data.distPos, 1, data.distanceLast, data.distanceMax, QX7 and 1000 or 10000, units[data.distance_unit], false, telemFlags)
  drawData("Sped", data.speedPos, 1, data.speed, data.speedMax, QX7 and 100 or 1000, units[data.speed_unit], false, telemFlags)
  drawData("Batt", data.battPos1, 2, battNow, battLow, QX7 and 100 or 1000, "V", true, battFlags)
  drawData("RSSI", 57, 2, data.rssiLast, data.rssiMin, 200, "dB", false, rssiFlags)
  if data.showCurr then
    drawData("Curr", 33, 1, data.current, data.currentMax, 100, "A", true, telemFlags)
    drawData("Fuel", 41, 0, data.fuel, 0, 200, "%", false, battFlags)
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
  if not QX7 and data.showAlt then
    lcd.drawRectangle(197, 9, 15, 48, SOLID)
    local height = math.max(math.min(math.ceil(data.altitude / data.altAlert * 46), 46), 0)
    lcd.drawFilledRectangle(198, 56 - height, 13, height, INVERS)
    local max = 56 - math.max(math.min(math.ceil(data.altitudeMax / data.altAlert * 46), 46), 0)
    lcd.drawLine(198, max, 210, max, DOTTED, FORCE)
    lcd.drawText(198, 58, "Alt", SMLSIZE)
  end

  -- Title
  lcd.drawFilledRectangle(0, 0, LCD_W, 8, FORCE)
  lcd.drawText(0, 0, data.modelName, INVERS)
  lcd.drawTimer(QX7 and 60 or 150, 1, data.timer, SMLSIZE + INVERS)
  lcd.drawFilledRectangle(86, 1, 19, 6, ERASE)
  lcd.drawLine(105, 2, 105, 5, SOLID, ERASE)
  local battGauge = math.max(math.min((data.txBatt - data.txBattMin) / (data.txBattMax - data.txBattMin) * 17, 17), 0) + 86
  for i = 87, battGauge, 2 do
    lcd.drawLine(i, 2, i, 5, SOLID, FORCE)
  end
  if not QX7 then
    lcd.drawNumber(110 , 1, data.txBatt * 10.01, SMLSIZE + PREC1 + INVERS)
    lcd.drawText(lcd.getLastPos(), 1, "V", SMLSIZE + INVERS)
  end
  if data.rxBatt > 0 and data.telemetry then
    lcd.drawNumber(LCD_W - 17, 1, data.rxBatt * 10.01, SMLSIZE + PREC1 + INVERS)
    lcd.drawText(lcd.getLastPos(), 1, "V", SMLSIZE + INVERS)
  end

  return 0
end

return {run = run, background = background}