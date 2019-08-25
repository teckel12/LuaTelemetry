local SMLCD = ...

-- Config options: o=display Order / c=Characters / v=default Value / d=Decimal / x=maX
local config = {
	{ o = 1,  c = 1, v = 1 }, -- Battery View - 1
	{ o = 3,  c = 2, v = 3.5, d = true, x = 3.9}, -- Cell Low - 2
	{ o = 4,  c = 2, v = 3.4, d = true, x = 3.8 }, -- Cell Critical - 3
	{ o = 18, c = 1, v = 2, x = 2 }, -- Voice Alerts - 4
	{ o = 19, c = 1, v = 3, x = 3 }, -- Feedback - 5
	{ o = 11, c = 4, v = -1, x = 9999 }, -- Max Altitude - 6
	{ o = 15, c = 1, v = 0, x = 3 }, -- Variometer - 7
	{ o = 20, c = 1, v = 1 }, -- RTH Feedback - 8
	{ o = 21, c = 1, v = 1 }, -- HeadFree Feedback - 9
	{ o = 22, c = 1, v = 1 }, -- RSSI Feedback - 10
	{ o = 2,  c = 1, v = 2, x = 2 }, -- Battery Alerts - 11
	{ o = 10, c = 1, v = 1 }, -- Altitude Alert - 12
	{ o = 12, c = 1, v = 1, x = 3 }, -- Timer - 13
	{ o = 14, c = 1, v = 1 }, -- Rx Voltage - 14
	{ o = 28, c = 1, v = 0 }, -- HUD Home Icon - 15
	{ o = 33, c = 1, v = 0 }, -- GPS - 16
	{ o = 9,  c = 2, v = 20, x = 40 }, -- Fuel Critical - 17
	{ o = 8,  c = 2, v = 30, x = 50 }, -- Fuel Low - 18
	{ o = 13, c = 1, v = SMLCD and 1 or 2, x = SMLCD and 1 or 2 }, -- Tx Voltage - 19
	{ o = 24, c = 1, v = 0 }, -- Speed Sensor - 20
	{ o = 32, c = 2, v = 3.5, d = true, x = 5.0 }, -- GPS Warning - 21
	{ o = 31, c = 1, v = 0 }, -- GPS HDOP View - 22
	{ o = 6,  c = 1, v = 0, x = 2 }, -- Fuel Unit - 23
	{ o = 16, c = 1, v = 3, x = 9 }, -- Vario Steps - 24
	{ o = 25, c = 1, v = 0, x = 3 }, -- View Mode - 25
	{ o = 23, c = 1, v = 0 }, -- AltHold Center FB - 26
	{ o = 7,  c = 5, v = 1500, x = 9950 }, -- Battery Capacity - 27
	{ o = 17, c = 1, v = 0, x = 6 }, -- Altitude Graph - 28
	{ o = 5,  c = 2, v = 4.3, d = true, x = 4.5 }, -- Cell Calculation - 29
	{ o = 27, c = 1, v = 0, x = 5 }, -- Aircraft Symbol - 30
	{ o = 29, c = 1, v = 0 }, -- Center Map Home - 31
	{ o = 30, c = 1, v = 0 }, -- Orientation - 32
	{ o = 26, c = 1, v = 0 }, -- Roll Scale - 33
	{ o = 34, c = 1, v = 0, l = {[0] = "?"} }, -- Review Log Date - 34
}

for i = 1, #config do
	for ii = 1, #config do
		if i == config[ii].o then
			config[i].z = ii
			config[ii].o = nil
		end
	end
end

return config