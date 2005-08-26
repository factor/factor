! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: help
DEFER: <tutorial-button>

IN: gadgets
USING: generic help io kernel listener math namespaces
prettyprint sdl sequences styles threads words shells ;

SYMBOL: stack-display

: ui.s ( -- )
    stack-display get dup pane-clear [ .s ] with-stream* ;

: listener-thread
    pane get [
        [ ui.s ] listener-hook set <tutorial-button> gadget. tty
    ] with-stream* ;

: listener-application
    <pane> dup pane set <scroller>
    <pane> dup stack-display set <scroller>
    5/6 <x-splitter> add-layer
    [ clear listener-thread ] in-thread
    pane get request-focus ;

: init-world
    global [
        <world> world set
        { 700 800 0 } world get set-gadget-dim
        
        {{
            [[ background { 255 255 255 } ]]
            [[ rollover-bg { 236 230 232 } ]]
            [[ bevel-1 { 160 160 160 } ]]
            [[ bevel-2 { 216 216 216 } ]]
            [[ foreground { 0 0 0 } ]]
            [[ reverse-video f ]]
            [[ font "Sans Serif" ]]
            [[ font-size 12 ]]
            [[ font-style plain ]]
        }} world get set-gadget-paint

        <plain-gadget> add-layer

        listener-application
    ] bind ;

SYMBOL: first-time

global [ first-time on ] bind

: ?init-world
    first-time get [ init-world first-time off ] when ;

IN: shells

: ui-title
    [ "Factor " % version % " - " % "image" get % ] "" make ;

: ui ( -- )
    #! Start the Factor graphics subsystem with the given screen
    #! dimensions.
    ttf-init
    ?init-world
    world get rect-dim 2unseq 0 SDL_RESIZABLE [
        [
            ui-title dup SDL_WM_SetCaption
            start-world
            run-world
        ] with-screen
    ] with-scope ;
