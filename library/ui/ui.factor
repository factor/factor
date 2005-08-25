! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: help
DEFER: tutorial

IN: gadgets
USING: generic help io kernel listener math namespaces
prettyprint sdl sequences styles threads words ;

SYMBOL: stack-display

: ui.s ( -- )
    stack-display get dup pane-clear [ .s ] with-stream* ;

: init-world
    global [
        <world> world set
        
        {{
            [[ background { 255 255 255 } ]]
            [[ rollover-bg { 216 216 255 } ]]
            [[ bevel-1 { 160 160 160 } ]]
            [[ bevel-2 { 216 216 216 } ]]
            [[ foreground { 0 0 0 } ]]
            [[ reverse-video f ]]
            [[ font "Sans Serif" ]]
            [[ font-size 12 ]]
            [[ font-style plain ]]
        }} world get set-gadget-paint
        
        { 700 800 0 } world get set-gadget-dim
        
        <plain-gadget> add-layer
    
        <pane> dup pane set <scroller>
        <pane> dup stack-display set <scroller>
        5/6 <x-splitter> add-layer
        
        [
            pane get [
                [ ui.s ] listener-hook set
                clear print-banner
                "Tutorial" [ drop [ tutorial ] pane get pane-call ] <button> gadget.
                listener
            ] with-stream
        ] in-thread
    ] bind
        
        pane get request-focus ;

SYMBOL: first-time

global [ first-time on ] bind

: ?init-world
    first-time get [ init-world first-time off ] when ;
IN: shells

: ui ( -- )
    #! Start the Factor graphics subsystem with the given screen
    #! dimensions.
    ttf-init
    ?init-world
    world get rect-dim 2unseq 0 SDL_RESIZABLE [
        [
            "Factor " version append dup SDL_WM_SetCaption
            start-world
            run-world
        ] with-screen
    ] with-scope ;
