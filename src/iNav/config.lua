local SMLCD = ...

-- Config options: o=display Order / t=Text / c=Characters / v=default Value / l=Lookup text / d=Decimal / m=Min / x=maX / i=Increment / a=Append text / b=Blocked by
local config = {
	{ o = 1,  t = "Battery View",     c = 1, v = 1, i = 1, l = {[0] = "Cell", "Total"} },
	{ o = 3,  t = "Cell Low",         c = 2, v = 3.5, d = true, m = 2.7, x = 3.9, i = 0.1, a = "V", b = 2 },
	{ o = 4,  t = "Cell Critical",    c = 2, v = 3.4, d = true, m = 2.6, x = 3.8, i = 0.1, a = "V", b = 2 },
	{ o = 15, t = "Voice Alerts",     c = 1, v = 2, x = 2, i = 1, l = {[0] = "Off", "Critical", "All"} },
	{ o = 16, t = "Feedback",         c = 1, v = 3, x = 3, i = 1, l = {[0] = "Off", "Haptic", "Beeper", "All"} },
	{ o = 9,  t = "Max Altitude",     c = 4, x = 9999, b = 8 },
	{ o = 13, t = "Variometer",       c = 1, v = 0, i = 1, x = 3, l = {[0] = "Off", "Graph", "Voice", "Both"} },
	{ o = 17, t = "RTH Feedback",     c = 1, v = 1, i = 1, l = {[0] = "Off", "On"}, b = 16 },
	{ o = 18, t = "HeadFree Feedback",c = 1, v = 1, i = 1, l = {[0] = "Off", "On"}, b = 16 },
	{ o = 19, t = "RSSI Feedback",    c = 1, v = 1, i = 1, l = {[0] = "Off", "On"}, b = 16 },
	{ o = 2,  t = "Battery Alerts",   c = 1, v = 2, x = 2, i = 1, l = {[0] = "Off", "Critical", "All"} },
	{ o = 8,  t = "Altitude Alert",   c = 1, v = 1, i = 1, l = {[0] = "Off", "On"} },
	{ o = 10, t = "Timer",            c = 1, v = 1, x = 4, i = 1, l = {[0] = "Off", "Auto", "Timer1", "Timer2", "Timer3"} },
	{ o = 12, t = "Rx Voltage",       c = 1, v = 1, i = 1, l = {[0] = "Off", "On"} },
	{ o = 26, t = "GPS",              c = 1, v = 0, x = 0, i = 0, l = {[0] = { lat = 0, lon = 0 }} },
	{ o = 25, t = "GPS Coordinates",  c = 1, v = 0, i = 1, l = {[0] = "Decimal", "Deg/Min"} },
	{ o = 7,  t = "Fuel Critical",    c = 2, v = 20, m = 1, x = 40, i = 1, a = "%", b = 2 },
	{ o = 6,  t = "Fuel Low",         c = 2, v = 30, m = 2, x = 50, i = 1, a = "%", b = 2 },
	{ o = 11, t = "Tx Voltage",       c = 1, v = SMLCD and 1 or 2, x = SMLCD and 1 or 2, i = 1, l = {[0] = "Number", "Graph", "Both"} },
	{ o = 21, t = "Speed Sensor",     c = 1, v = 0, i = 1, l = {[0] = "GPS", "Pitot"} },
	{ o = 24, t = "GPS Warning",      c = 2, v = 3.5, d = true, m = 1.0, x = 5.0, i = 0.5, a = " HDOP" },
	{ o = 23, t = "GPS HDOP View",    c = 1, v = 0, i = 1, l = {[0] = "Graph", "Decimal"} },
	{ o = 5,  t = "Fuel Unit",        c = 1, v = 0, i = 1, x = 2, l = {[0] = "Percent", "mAh", "mWh"} },
	{ o = 14, t = "Vario Steps",      c = 1, v = 3, m = 0, x = 9, i = 1, l = {[0] = 1, 2, 5, 10, 15, 20, 25, 30, 40, 50} },
	{ o = 22, t = "View Mode",        c = 1, v = 0, i = 1, x = 1, l = {[0] = "Classic", "Pilot"} },
	{ o = 20, t = "AltHold Center FB",c = 1, v = 0, i = 1, l = {[0] = "Off", "On"}, b = 16 },
}

return config