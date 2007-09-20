! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel math namespaces sequences system ;
IN: timers

TUPLE: timer object delay next ;

: <timer> ( object delay initial -- timer )
    millis + timer construct-boa ;

GENERIC: tick ( object -- )

: timers \ timers get-global ;

: init-timers ( -- ) H{ } clone \ timers set-global ;

: add-timer ( object delay initial -- )
    pick >r <timer> r> timers set-at ;

: remove-timer ( object -- ) timers delete-at ;

: advance-timer ( ms timer -- )
    [ timer-delay + ] keep set-timer-next ;

: do-timer ( ms timer -- )
    dup timer-next pick <=
    [ [ advance-timer ] keep timer-object tick ] [ 2drop ] if ;

: do-timers ( -- )
    millis timers values [ do-timer ] curry* each ;
