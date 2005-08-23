! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: hashtables kernel math namespaces sequences ;

TUPLE: timer gadget last ;

C: timer ( gadget -- timer )
    [ set-timer-gadget ] keep
    millis over set-timer-last ;

GENERIC: tick* ( ms gadget -- )

: next-time ( timer -- ms )
    dup timer-gadget gadget-framerate swap timer-last + ;

: advance-timer ( ms timer -- delay )
    #! Outputs the time since the last firing.
    [ timer-last - 0 max ] 2keep set-timer-last ;

: do-timer ( ms timer -- )
    #! Takes current time, and a timer. If the timer is set to
    #! fire, calls its callback.
    dup next-time pick <=
    [ [ advance-timer ] keep timer-gadget tick* ] [ 2drop ] ifte ;

: timers ( -- hash ) world get world-timers ;

: add-timer ( gadget -- ) [ <timer> ] keep timers set-hash ;

: remove-timer ( gadget -- ) timers remove-hash ;

: do-timers ( -- )
    millis timers hash-values [ do-timer ] each-with ;

M: gadget tick* ( ms gadget -- ) 2drop ;
