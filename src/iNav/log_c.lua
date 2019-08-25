--Crossfire
--Date,Time,FM,1RSS(dB),2RSS(dB),RQly(%),RSNR(dB),RFMD,TPWR(mW),TRSS(dB),TQly(%),TSNR(dB),RxBt(V),Curr(A),Capa(mAh),GPS,GSpd(mph),Hdg(@),Alt(ft),Sats,Ptch(rad),Roll(rad),Yaw(rad),Rud,Ele,Thr,Ail,S1,6P,S2,LS,RS,SA,SB,SC,SD,SE,SF,SG,SH,LSW,TxBat(V)

local function fake(data, config, record, label, toNum)
	data.rssi = toNum(record[label.rqly])
	data.tpwr = toNum(record[label.tpwr])
	data.rfmd = toNum(record[label.rfmd])
	data.pitch = math.deg(toNum(record[label.ptch])) * 10
	data.roll = math.deg(toNum(record[label.roll])) * 10
	data.batt = toNum(record[label.rxbt])
	if data.lang == "fr" and data.batt == 0 then data.batt = toNum(record[label.btrx]) end
	-- Overflow shenanigans
	local tmp = toNum(record[label.yaw])
	data.heading = math.deg(tmp < 0 and tmp + 6.55 or tmp)
	if data.fpv_id > -1 then
		tmp = toNum(record[label.hdg])
		data.fpv = (tmp < 0 and tmp + 65.54 or tmp) * 10
	end
	--[[ Replacement code once the Crossfire/OpenTX Yaw/Hdg int overflow shenanigans are corrected
	data.heading = math.deg(toNum(record[label.yaw]))
	if data.fpv_id > -1 then data.fpv =toNum(record[label.hdg]) * 10 end
	]]
	data.fuel = toNum(record[label.capa])
	data.fuelRaw = data.fuel
	if data.showFuel and config[23].v == 0 then
		data.fuel = math.max(math.min(math.floor((1 - (data.fuel) / config[27].v) * 100 + 0.5), 100), 0)
	end
	-- Don't know the flight mode with Crossfire, so assume armed and ACRO
	data.mode = 5
	data.satellites = toNum(record[label.sats])
	--Fake HDOP based on satellite lock count and assume GPS fix when there's at least 6 satellites
	data.satellites = data.satellites + (math.floor(math.min(data.satellites + 10, 25) * 0.36 + 0.5) * 100) + (data.satellites >= 6 and 3000 or 0)
end

return fake