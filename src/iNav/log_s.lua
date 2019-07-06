-- S.Port
--Date,Time,Tmp1(@C),Tmp2(@C),A4(V),VFAS(V),Curr(A),Alt(ft),A2(V),RSSI(dB),RxBt(V),Fuel(%),VSpd(f/s),Hdg(@),Ptch(@),Roll(@),Dist(ft),GAlt(ft),GSpd(mph),GPS,Rud,Ele,Thr,Ail,S1,6P,S2,LS,RS,SA,SB,SC,SD,SE,SF,SG,SH,LSW,TxBat(V)

local function fake(data, config, record, label)
	data.rssi = tonumber(record[label.rssi])
	data.satellites = tonumber(record[label.tmp2])
	data.fuel = tonumber(record[label.fuel])
	data.heading = tonumber(record[label.hdg])
	if data.pitchRoll then
		data.pitch = tonumber(record[label.ptch])
		data.roll = tonumber(record[label.roll])
	else
		data.accx = tonumber(record[label.accx])
		data.accy = tonumber(record[label.accy])
		data.accz = tonumber(record[label.accz])
	end
	data.mode = tonumber(record[label.tmp1])
	data.rxBatt = tonumber(record[label.rxbt])
	data.gpsAlt = data.satellites > 1000 and tonumber(record[label.galt]) or 0
	data.distance = tonumber(record[label.dist])
	data.vspeed = tonumber(record[label.vspd])
	data.batt = tonumber(record[label.vfas])
end

return fake