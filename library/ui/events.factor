! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic kernel lists math namespaces sdl sdl-event
sdl-video ;

GENERIC: handle-event ( event -- )

M: alien handle-event ( event -- )
    drop ;

M: quit-event handle-event ( event -- )
    drop f world get set-world-running? ;

M: resize-event handle-event ( event -- )
    dup resize-event-w swap resize-event-h
    [ world get resize-gadget ] 2keep
    0 SDL_HWSURFACE SDL_RESIZABLE bitor init-screen
    world get redraw ;

: button-event-pos ( event -- #{ x y }# )
    dup button-event-x swap button-event-y rect> ;

M: button-down-event handle-event ( event -- )
    dup button-event-pos my-hand set-hand-click-pos
    my-hand hand-click-pos world get pick-up
    my-hand set-hand-clicked
    button-event-button dup my-hand button/
    button-down swap 2list my-hand button-gesture ;

M: button-up-event handle-event ( event -- )
    button-event-button
    dup my-hand button\
    button-up swap 2list my-hand button-gesture
    f my-hand set-hand-clicked
    f my-hand set-hand-click-pos ;

M: motion-event handle-event ( event -- )
    dup motion-event-x swap motion-event-y my-hand move-gadget
    [ motion ] my-hand motion-gesture ;
