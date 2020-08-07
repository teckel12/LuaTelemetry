lcd.drawText(1,1,"Starting",0)
lcd.clear()
countera = 0
counterb = 0
-- test all virtual buttons. Current event code shown at bottom left of screen.
-- short exit press will clear screen

local function run(event)

    if event == EVT_VIRTUAL_NEXT then
        lcd.drawText(1,1,"NEXT",0)
    end
    if event == EVT_VIRTUAL_PREV then
        lcd.drawText(1,11,"PREV",0)
    end
    if event == EVT_VIRTUAL_INC then
        lcd.drawText(1,21,"INC",0)
    end
    if event == EVT_VIRTUAL_DEC then
        lcd.drawText(1,31,"DEC",0)
    end
    if event == EVT_VIRTUAL_ENTER then
        lcd.drawText(1,41,"Enter",0)
    end
    if event == EVT_VIRTUAL_MENU then
        lcd.drawText(60,21,"MENU",0)
    end
    if event == EVT_VIRTUAL_NEXT_PAGE then
        lcd.drawText(60,1,"NEXT_PAGE",0)
    end
    if event == EVT_VIRTUAL_PREV_PAGE then
        lcd.drawText(60,11,"PREV_PAGE",0)
    end
    if event == EVT_VIRTUAL_NEXT_REPT then
        lcd.drawText(60,51,"          ",0)
        lcd.drawText(60,51,"NEXT_REPT",0)
        countera = countera + 1
        lcd.drawText(40,51,"       ",0)
        lcd.drawText(40,51,countera,0)
    end
    if event == EVT_VIRTUAL_PREV_REPT then
        lcd.drawText(60,51,"          ",0)
        lcd.drawText(60,51,"PREV_REPT",0)
        countera = countera - 1
        lcd.drawText(40,51,"       ",0)
        lcd.drawText(40,51,countera,0)
    end
    if event == EVT_VIRTUAL_INC_REPT then
        lcd.drawText(60,41,"          ",0)
        lcd.drawText(60,41,"INC_REPT",0)
        counterb = counterb + 1
        lcd.drawText(40,41,"       ",0)
        lcd.drawText(40,41,counterb,0)
    end
    if event == EVT_VIRTUAL_DEC_REPT then
        lcd.drawText(60,41,"          ",0)
        lcd.drawText(60,41,"DEC_REPT",0)
        counterb = counterb - 1
        lcd.drawText(40,41,"       ",0)
        lcd.drawText(40,41,counterb,0)
    end
    
    lcd.drawText(1,51,event,0)
    
    if event == EVT_VIRTUAL_EXIT then
        lcd.clear()
    end
    
    return 0
end

return {run=run}