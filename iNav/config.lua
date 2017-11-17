local data, event, FILE_PATH = ...

local VALUES = 4

local function configText(line, y, text, value, number, append)
  local extra = data.config == line and INVERS + data.configSelect or 0
  lcd.drawText(15, y, text, SMLSIZE)
  if number then
    lcd.drawNumber(90, y, value * 10, SMLSIZE + PREC1 + extra)
  else
    lcd.drawText(90, y, value, SMLSIZE + extra)
  end
  if append then
    lcd.drawText(lcd.getLastPos(), y, append, SMLSIZE + extra)
  end
end

lcd.drawFilledRectangle(10, 10, LCD_W - 20, LCD_H - 15, ERASE)
lcd.drawRectangle(10, 10, LCD_W - 20, LCD_H - 15, SOLID)

configText(1, 15, "Battery View", data.showCell == 1 and "Cell" or "Total", false, false)
configText(2, 23, "Cell Low", data.battLow, true, "V")
configText(3, 31, "Cell Critical", data.battCrit, true, "V")
configText(4, 39, "10% mAh Alerts", data.mahAlert == 1 and "Yes" or "No", false, false)

if data.configSelect == 0 then
  if event == EVT_EXIT_BREAK then
    local fh = io.open(FILE_PATH .. "config.dat", "w")
    if fh ~= nil then
      io.write(fh, data.showCell, math.floor(data.battLow * 10), math.floor(data.battCrit * 10), data.mahAlert)
      io.close(fh)
    end
    data.config = 0
  elseif event == EVT_ROT_RIGHT or event == EVT_PLUS_BREAK then
    data.config = math.min(data.config + 1, VALUES)
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
      data.mahAlert = data.mahAlert == 1 and 0 or 1
    end
  end
end

if event == EVT_ENTER_BREAK then
  data.configSelect = (data.configSelect == 0) and BLINK or 0
end