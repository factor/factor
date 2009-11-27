! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: calendar namespaces models threads kernel init ;
IN: calendar.model

SYMBOL: time

: (time-thread) ( -- )
    now time get set-model
    1 seconds sleep (time-thread) ;

: time-thread ( -- )
    [
        init-namespaces
        (time-thread)
    ] "Time model update" spawn drop ;

f <model> time set-global
[ time-thread ] "calendar.model" add-startup-hook
