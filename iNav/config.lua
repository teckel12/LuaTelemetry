local data, event, FILE_PATH = ...

local VALUES = 3
lcd.drawFilledRectangle(10, 10, LCD_W - 20, LCD_H - 15, ERASE)
lcd.drawRectangle(10, 10, LCD_W - 20, LCD_H - 15, SOLID)

local extra = data.config == 1 and INVERS + data.configSelect or 0
lcd.drawText(15, 15, "Battery View", SMLSIZE)
lcd.drawText(90, 15, data.showCell == 0 and "Total" or "Cell", SMLSIZE + extra)

extra = data.config == 2 and INVERS + data.configSelect or 0
lcd.drawText(15, 23, "Cell Low", SMLSIZE)
lcd.drawNumber(90, 23, data.battLow * 10, SMLSIZE + PREC1 + extra)
lcd.drawText(lcd.getLastPos(), 23, "V", SMLSIZE + extra)

extra = data.config == 3 and INVERS + data.configSelect or 0
lcd.drawText(15, 31, "Cell Critical", SMLSIZE)
lcd.drawNumber(90, 31, data.battCrit * 10, SMLSIZE + PREC1 + extra)
lcd.drawText(lcd.getLastPos(), 31, "V", SMLSIZE + extra)

if data.configSelect == 0 then
  if event == EVT_EXIT_BREAK then
    local fh = io.open(FILE_PATH .. "config.dat", "w")
    if fh ~= nil then
      io.write(fh, data.showCell, math.floor(data.battLow * 10), math.floor(data.battCrit * 10))
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
      data.showCell = 1
    elseif data.config == 2 then
      data.battLow = math.min(data.battLow + 0.1, 3.9)
    elseif data.config == 3 then
      data.battCrit = math.min(data.battCrit + 0.1, math.min(3.9, data.battLow - 0.1))
    end
  elseif event == EVT_ROT_LEFT or event == EVT_MINUS_BREAK then
    if data.config == 1 then
      data.showCell = 0
    elseif data.config == 2 then
      data.battLow = math.max(data.battLow - 0.1, math.max(3.1, data.battCrit + 0.1))
    elseif data.config == 3 then
      data.battCrit = math.max(data.battCrit - 0.1, 3.1)
    end
  end
end

if event == EVT_ENTER_BREAK then
  data.configSelect = (data.configSelect == 0) and BLINK or 0
end