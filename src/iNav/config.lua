local data, event, FILE_PATH, altUnit = ...

local function configText(line, y, text, value, number, decimal, append)
  local extra = (data.config == line and INVERS + data.configSelect or 0) + (decimal and PREC1 or 0)
  lcd.drawText(12, y, text, SMLSIZE)
  if number then
    lcd.drawNumber(85, y, value, SMLSIZE + extra)
  else
    lcd.drawText(85, y, value, SMLSIZE + extra)
  end
  if append then
    lcd.drawText(lcd.getLastPos(), y, append, SMLSIZE + extra)
  end
end

local values = (data.showCurr and data.alerts == 1) and 6 or 5

lcd.drawFilledRectangle(8, 11, LCD_W - 16, values * 8 + 2, ERASE)
lcd.drawRectangle(8, 10, LCD_W - 16, values * 8 + 4, SOLID)

configText(1, 13, "Battery View", data.showCell == 1 and "Total" or "Cell", false, false, false)
configText(2, 21, "Cell Low", data.battLow * 10, true, true, "V")
configText(3, 29, "Cell Critical", data.battCrit * 10, true, true, "V")
configText(4, 37, "Max Altitude", data.altAlert, true, false, altUnit)
configText(5, 45, "Voice Alerts", data.alerts == 1 and "On" or "Off", false, false, false)
if data.showCurr and data.alerts == 1 then
  configText(6, 53, "10% mAh Alerts", data.mahAlert == 1 and "On" or "Off", false, false, false)
end

if data.configSelect == 0 then
  if event == EVT_EXIT_BREAK then
    local fh = io.open(FILE_PATH .. "config.dat", "w")
    if fh ~= nil then
      io.write(fh, data.showCell, math.floor(data.battLow * 10), math.floor(data.battCrit * 10), data.alerts, data.mahAlert, data.altAlert)
      io.close(fh)
    end
    data.config = 0
  elseif event == EVT_ROT_RIGHT or event == EVT_PLUS_BREAK then
    data.config = math.min(data.config + 1, values)
  elseif event == EVT_ROT_LEFT or event == EVT_MINUS_BREAK then
    data.config = math.max(data.config - 1, 1)
  end
else
  if event == EVT_EXIT_BREAK then
    data.configSelect = 0
  elseif event == EVT_ROT_RIGHT or event == EVT_PLUS_BREAK then
    if data.config == 1 then
      data.showCell = data.showCell == 1 and 0 or 1
    elseif data.config == 2 then
      data.battLow = math.min(math.floor(data.battLow * 10 + 1) / 10, 3.9)
    elseif data.config == 3 then
      data.battCrit = math.min(math.floor(data.battCrit * 10 + 1) / 10, math.min(3.9, data.battLow - 0.1))
    elseif data.config == 4 then
      data.altAlert = math.min(data.altAlert + 10, 9999)
    elseif data.config == 5 then
      data.alerts = data.alerts == 1 and 0 or 1
    elseif data.config == 6 then
      data.mahAlert = data.mahAlert == 1 and 0 or 1
    end
  elseif event == EVT_ROT_LEFT or event == EVT_MINUS_BREAK then
    if data.config == 1 then
      data.showCell = data.showCell == 1 and 0 or 1
    elseif data.config == 2 then
      data.battLow = math.max(math.floor(data.battLow * 10 - 1) / 10, math.max(3.1, data.battCrit + 0.1))
    elseif data.config == 3 then
      data.battCrit = math.max(math.floor(data.battCrit * 10 - 1) / 10, 3.1)
    elseif data.config == 4 then
      data.altAlert = math.max(data.altAlert - 10, 0)
    elseif data.config == 5 then
      data.alerts = data.alerts == 1 and 0 or 1
    elseif data.config == 6 then
      data.mahAlert = data.mahAlert == 1 and 0 or 1
    end
  end
end

if event == EVT_ENTER_BREAK then
  data.configSelect = (data.configSelect == 0) and BLINK or 0
end