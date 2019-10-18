! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien gadgets-layouts generic kernel lists math
namespaces sdl sequences vectors ;

GENERIC: handle-event ( event -- )

M: object handle-event ( event -- )
    drop ;

M: quit-event handle-event ( event -- )
    drop f world get set-world-running? ;

M: resize-event handle-event ( event -- )
    dup resize-event-w swap resize-event-h
    [ 0 3vector world get set-gadget-dim ] 2keep
    0 SDL_HWSURFACE SDL_RESIZABLE bitor init-screen
    world get relayout ;

: button-gesture ( button gesture -- )
    swap add hand hand-clicked handle-gesture drop ;

M: button-down-event handle-event ( event -- )
    button-event-button dup hand button/
    [ button-down ] button-gesture ;

M: button-up-event handle-event ( event -- )
    button-event-button dup hand button\
    [ button-up ] button-gesture ;

: motion-event-loc ( event -- loc )
    dup motion-event-x swap motion-event-y 0 3vector ;

M: motion-event handle-event ( event -- )
    motion-event-loc hand move-hand ;

M: key-down-event handle-event ( event -- )
    dup keyboard-event>binding
    hand hand-focus handle-gesture [
        keyboard-event-unicode dup 0 = [
            drop
        ] [
            hand hand-focus user-input drop
        ] ifte
    ] [
        drop
    ] ifte ;
