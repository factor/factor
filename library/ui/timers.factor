! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: hashtables kernel math namespaces sequences ;

TUPLE: timer object delay last ;

: timer-now millis swap set-timer-last ;

C: timer ( object delay -- timer )
    [ set-timer-delay ] keep
    [ set-timer-object ] keep
    dup timer-now ;

GENERIC: tick ( ms object -- )

: timers \ timers global hash ;

H{ } clone \ timers set-global

: add-timer ( object delay -- )
    over >r <timer> r> timers set-hash ;

: remove-timer ( object -- ) timers remove-hash ;

: restart-timer ( object -- )
    timers hash [ timer-now ] when* ;

: next-time ( timer -- ms ) dup timer-delay swap timer-last + ;

: advance-timer ( ms timer -- delay )
    [ timer-last - 0 max ] 2keep set-timer-last ;

: do-timer ( ms timer -- )
    dup next-time pick <= [
        [ advance-timer ] keep timer-object tick
    ] [
        2drop
    ] if ;

: do-timers ( -- )
    millis timers hash-values [ do-timer ] each-with ;
