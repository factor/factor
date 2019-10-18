! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel namespaces sdl sequences ;

: title ( -- str )
    "Factor " version append ;

SYMBOL: first-time?
global [ first-time? on ] bind

: first-time ( -- )
    first-time? get [
        world get gadget-paint [ console ] bind
        global [ first-time? off ] bind
    ] when ;

IN: shells

: ui ( -- )
    #! Start the Factor graphics subsystem with the given screen
    #! dimensions.
    world get shape-size 0 SDL_RESIZABLE [
        0 x set 0 y set [
            title dup SDL_WM_SetCaption first-time
            start-world
            run-world
        ] with-screen
    ] with-scope ;
