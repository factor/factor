! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: gadgets-layouts gadgets-listener generic help io kernel
listener lists math memory namespaces prettyprint sdl sequences
shells styles threads words ;

: init-world
    ttf-init
    global [
        <world> world set
        @{ 600 700 0 }@ world get set-gadget-dim
        
        world-theme world get set-gadget-paint

        <plain-gadget> add-layer

        listener-application
    ] bind ;

SYMBOL: first-time

global [ first-time on ] bind

: ?init-world
    first-time get [ init-world first-time off ] when ;

: ui-title
    [ "Factor " % version % " - " % image % ] "" make ;

IN: shells

: ui ( -- )
    #! Start the Factor graphics subsystem with the given screen
    #! dimensions.
    ttf-init
    ?init-world
    world get rect-dim first2 0 SDL_RESIZABLE [
        [
            ui-title dup SDL_WM_SetCaption
            start-world
            run-world
        ] with-screen
    ] with-scope ;
