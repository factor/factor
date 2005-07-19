! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel namespaces sdl sequences ;

IN: shells

: ui ( -- )
    #! Start the Factor graphics subsystem with the given screen
    #! dimensions.
    ttf-init
    ?init-world
    world get rectangle-dim 2unseq 0 SDL_RESIZABLE [
        [
            "Factor " version append dup SDL_WM_SetCaption
            start-world
            run-world
        ] with-screen
    ] with-scope ;
