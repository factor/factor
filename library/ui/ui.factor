! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: gadgets-layouts gadgets-listener generic help io kernel
listener lists math namespaces prettyprint sdl sequences shells
styles threads words ;

: world-theme
    {{
        [[ background @{ 255 255 255 }@ ]]
        [[ rollover-bg @{ 236 230 232 }@ ]]
        [[ bevel-1 { 160 160 160 }@ ]]
        [[ bevel-2 @{ 232 232 232 }@ ]]
        [[ foreground @{ 0 0 0 }@ ]]
        [[ reverse-video f ]]
        [[ font "Monospaced" ]]
        [[ font-size 12 ]]
        [[ font-style plain ]]
    }} ;

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
    [ "Factor " % version % " - " % "image" get % ] "" make ;

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
