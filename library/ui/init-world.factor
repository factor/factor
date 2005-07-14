! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic io kernel listener math namespaces styles threads ;

: init-world
    global [
        <world> world set
        
        {{
            [[ background [ 255 255 255 ] ]]
            [[ rollover-bg [ 255 255 204 ] ]]
            [[ foreground [ 0 0 0 ] ]]
            [[ reverse-video f ]]
            [[ font "Sans Serif" ]]
            [[ font-size 12 ]]
            [[ font-style plain ]]
        }} world get set-gadget-paint
        
        { 1024 768 0 } world get set-gadget-dim
        
        <plain-gadget> add-layer
    
        <pane> dup
        
        <scroller> "Stack display goes here" <label> 3/4 <y-splitter> add-layer
        
        [ [ clear  print-banner listener ] with-stream ] in-thread
        
        dup request-focus
        
        pane set
    ] bind ;

SYMBOL: first-time

global [ first-time on ] bind

: ?init-world
    first-time get [ init-world first-time off ] when ;
