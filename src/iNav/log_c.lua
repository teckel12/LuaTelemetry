--Crossfire
--Date,Time,FM,1RSS(dB),2RSS(dB),RQly(%),RSNR(dB),RFMD,TPWR(mW),TRSS(dB),TQly(%),TSNR(dB),RxBt(V),Curr(A),Capa(mAh),GPS,GSpd(mph),Hdg(@),Alt(ft),Sats,Ptch(rad),Roll(rad),Yaw(rad),Rud,Ele,Thr,Ail,S1,6P,S2,LS,RS,SA,SB,SC,SD,SE,SF,SG,SH,LSW,TxBat(V)

local function fake(data, config, record, label)
	data.rssi = tonumber(record[label.rqly])
	data.tpwr = tonumber(record[label.tpwr])
	data.rfmd = tonumber(record[label.rfmd])
	data.pitch = math.deg(tonumber(record[label.ptch])) * 10
	data.roll = math.deg(tonumber(record[label.roll])) * 10
	data.batt = tonumber(record[label.rxbt])
	-- The following shenanigans are requred due to int rollover bugs in the Crossfire protocol for yaw and hdg
	local tmp = tonumber(record[label.yaw])
	if tmp < -0.26 then
		tmp = tmp + 0.27
	end
	data.heading = (math.deg(tmp) + 360) % 360
	-- Flight path vector
	if data.fpv_id > -1 then
		tmp = tonumber(record[label.hdg])
		data.fpv = ((tmp < 0 and tmp + 65.54 or tmp) * 10 + 360) % 360
	end
	data.fuel = tonumber(record[label.capa])
	data.fuelRaw = data.fuel
	if data.showFuel and config[23].v == 0 then
		data.fuel = math.max(math.min(math.floor((1 - (data.fuel) / config[27].v) * 100 + 0.5), 100), 0)
	end
	-- Don't know the flight mode with Crossfire, so assume armed and ACRO
	data.mode = 5
	data.satellites = tonumber(record[label.sats])
	--Fake HDOP based on satellite lock count and assume GPS fix when there's at least 6 satellites
	data.satellites = data.satellites + (math.floor(math.min(data.satellites + 10, 25) * 0.36 + 0.5) * 100) + (data.satellites >= 6 and 3000 or 0)
end

return fake