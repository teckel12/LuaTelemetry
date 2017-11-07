FLASH = INVERS + BLINK
QX7 = LCD_W < 212
RIGHT_POS = QX7 and 129 or 195
GAUGE_WIDTH = QX7 and 82 or 149
X_CNTR_1 = QX7 and 67 or 70
X_CNTR_2 = QX7 and 67 or 106
GPS_DIGITS = QX7 and 10000 or 1000000

armed = false
headFree = false
headingHold = false
altHold = false
homeResetPrev = false
gpsFixPrev = false
altNextPlay = 0
battNextPlay = 0
battPercentPlayed = 100
telemFlags = -1

-- Modes: t=text / f=flags for text / w=wave file
modes = {
  { t="NO TELEM",  f=FLASH, w=false },
  { t="HORIZON",   f=0,     w="hrznmd.wav" },
  { t="ANGLE",     f=0,     w="anglmd.wav" },
  { t="ACRO",      f=0,     w="acromd.wav" },
  { t=" NOT OK ",  f=FLASH, w=false },
  { t="READY",     f=0,     w="ready.wav" },
  { t="POS HOLD",  f=0,     w="poshld.wav" },
  { t="3D HOLD",   f=0,     w="3dhold.wav" },
  { t="WAYPOINT",  f=0,     w="waypt.wav" },
  { t="PASSTHRU",  f=0,     w=false },
  { t="   RTH   ", f=FLASH, w="rtl.wav" },
  { t="FAILSAFE",  f=FLASH, w="fson.wav" }
}

units = { [0]="m", "V", "A", "mA", "kts", "m/s", "f/s", "kmh", "mph", "m", "ft" }

local function getTelemetryId(name)
  local field = getFieldInfo(name)
  return field and field.id or -1
end

local function getTelemetryUnit(name)
  local field = getFieldInfo(name)
  return (field and field.unit <= 10) and field.unit or 1
end

rssi, low, crit = getRSSI()
general = getGeneralSettings()
data = {
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
  modeId = 1
}

data.showCurr = data.current_id > -1 and true or false
data.showHead = data.heading_id > -1 and true or false
data.showAlt = data.altitude_id > -1 and true or false
data.distPos = data.showCurr and 17 or (data.showAlt and 21 or 13)
data.speedPos = data.showCurr and 25 or (data.showAlt and 33 or 25)
data.battPos1 = data.showCurr and 49 or 45
data.battPos2 = data.showCurr and 49 or 41
data.distRef = data.distance_unit == 10 and 20 or 6
data.altAlert = data.altitude_unit == 10 and 400 or 123
