local data = ...

data.startup = 1
data.timerStart = 0
data.timer = 0
data.distanceLast = 0
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
if data.crsf then
	data.rssiMin = 99
end
--[[ FPS stuff
data.fpsStart = getTime()
data.frames = 0
]]

return 0