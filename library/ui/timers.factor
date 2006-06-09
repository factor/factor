! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: hashtables kernel math namespaces sequences ;

TUPLE: timer object delay last ;

C: timer ( object delay -- timer )
    [ set-timer-delay ] keep
    [ set-timer-object ] keep
    millis over set-timer-last ;

GENERIC: tick ( ms object -- )

: timers \ timers get-global ;

: init-timers ( -- ) H{ } clone \ timers set-global ;

: add-timer ( object delay -- )
    over >r <timer> r> timers set-hash ;

: remove-timer ( object -- ) timers remove-hash ;

: next-time ( timer -- ms ) dup timer-delay swap timer-last + ;

: advance-timer ( ms timer -- delay )
    [ timer-last [-] ] 2keep set-timer-last ;

: do-timer ( ms timer -- )
    dup next-time pick <= [
        [ advance-timer ] keep timer-object tick
    ] [
        2drop
    ] if ;

: do-timers ( -- )
    millis timers hash-values [ do-timer ] each-with ;
