-- S.Port
--Date,Time,Tmp1(@C),Tmp2(@C),A4(V),VFAS(V),Curr(A),Alt(ft),A2(V),RSSI(dB),RxBt(V),Fuel(%),VSpd(f/s),Hdg(@),Ptch(@),Roll(@),Dist(ft),GAlt(ft),GSpd(mph),GPS,Rud,Ele,Thr,Ail,S1,6P,S2,LS,RS,SA,SB,SC,SD,SE,SF,SG,SH,LSW,TxBat(V)

local function fake(data, config, record, label, toNum)
	data.rssi = toNum(record[label.rssi])
	data.satellites = toNum(record[label.tmp2])
	data.fuel = toNum(record[label.fuel])
	data.heading = toNum(record[label.hdg])
	if data.pitchRoll then
		data.pitch = toNum(record[label.ptch])
		data.roll = toNum(record[label.roll])
	else
		data.accx = toNum(record[label.accx])
		data.accy = toNum(record[label.accy])
		data.accz = toNum(record[label.accz])
	end
	data.mode = toNum(record[label.tmp1])
	data.rxBatt = toNum(record[label.rxbt])
	if data.lang == "fr" and data.rxBatt == 0 then data.rxBatt = toNum(record[label.btrx]) end
	data.gpsAlt = data.satellites > 1000 and toNum(record[label.galt]) or 0
	data.distance = toNum(record[label.dist])
	data.batt = toNum(record[label.vfas])
end

return fake