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
  txBatt_id = getTelemetryId("tx-voltage"),
  ras_id = getTelemetryId("RAS"),
  gpsAlt_unit = getTelemetryUnit("GAlt"),
  altitude_unit = getTelemetryUnit("Alt"),
  distance_unit = getTelemetryUnit("Dist"),
  speed_unit = getTelemetryUnit("GSpd"),
  accz =  getTelemetryUnit("AccZ"),
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
data.altAlert = data.altitude_unit == 10 and 400 or 123
data.version = maj + minor / 10

-- User configuration data
local configFile = "/SCRIPTS/TELEMETRY/iNav/config.dat"
local fh = io.open(configFile, "r")
if fh == nil then
  fh = io.open(configFile, "w")
  if fh ~= nil then
    io.write(fh, "03534")
    io.close(fh)
  end
  data.showCell = 0
  data.battLow = 3.5
  data.battCrit = 3.4
else
  data.showCell = io.read(fh, 1)
  data.battLow = io.read(fh, 2) / 10
  data.battCrit = io.read(fh, 2) / 10
  io.close(fh)
end

return data