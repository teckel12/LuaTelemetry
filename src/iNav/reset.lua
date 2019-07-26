local data = ...

data.armed = false
data.startup = 1
data.timerStart = 0
data.timer = 0
data.distanceLast = 0
data.distanceMax = 0
data.distMaxCalc = 0
data.gpsHome = false
data.gpsLatLon = { lat = 0, lon = 0 }
data.gpsFix = false
data.headingRef = -1
data.battLow = false
data.showMax = false
data.showDir = true
data.cells = 1
data.gpsAltBase = false
data.configStatus = 0
data.startupTime = 0
data.thrCntr = -2000
data.trCnSt = false
data.fuelEst = -1
data.altitudeMax = 0
data.speedMax = 0
data.currentMax = 0
data.battMin = 0
data.cellMin = 0
data.rssiMin = 100
data.bkgd = false
data.doLogs = false
data.altMin = 0
data.altMax = data.alt_unit == 10 and 50 or 30
data.altCur = 1
data.altLst = getTime()
for i = 1, 60 do
	data.alt[i] = 0
end

--[[ FPS stuff
data.fpsStart = getTime()
data.frames = 0
]]

return 0