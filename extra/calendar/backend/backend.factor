USING: kernel ;
IN: calendar.backend

SYMBOL: calendar-backend
HOOK: gmt-offset calendar-backend ( -- hours minutes seconds )
