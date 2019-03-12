local data = ...

local HORUS = LCD_W >= 480

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
--[[ FPS stuff
data.fpsStart = getTime()
data.frames = 0
]]

if HORUS then
	data.altMin = 0
	data.altMax = 30
	data.altCur = 1
	data.altLst = getTime()
	data.alt = {}
	for i = 1, 60, 1 do
		data.alt[i] = 0
	end
end

return 0