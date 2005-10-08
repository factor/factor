! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: arrays alien gadgets-layouts generic kernel lists math
namespaces sdl sequences strings ;

GENERIC: handle-event ( event -- )

M: object handle-event ( event -- )
    drop ;

: button-gesture ( button gesture -- )
    swap add hand get hand-clicked handle-gesture drop ;

M: button-down-event handle-event ( event -- )
    button-event-button dup hand get button/
    [ button-down ] button-gesture ;

M: button-up-event handle-event ( event -- )
    button-event-button dup hand get button\
    [ button-up ] button-gesture ;

: motion-event-loc ( event -- loc )
    dup motion-event-x swap motion-event-y 0 3array ;

M: key-down-event handle-event ( event -- )
    dup keyboard-event>binding
    hand get hand-focus handle-gesture [
        keyboard-event-unicode dup control? [
            drop
        ] [
            hand get hand-focus user-input drop
        ] if
    ] [
        drop
    ] if ;
