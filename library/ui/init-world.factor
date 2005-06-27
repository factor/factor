! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel math namespaces styles ;


global [
    <world> world set
    
    {{

        [[ background [ 255 255 255 ] ]]
        [[ rollover-bg [ 216 216 216 ] ]]
        [[ foreground [ 0 0 0 ] ]]
        [[ reverse-video f ]]
        [[ font "Sans Serif" ]]
        [[ font-size 12 ]]
        [[ font-style plain ]]
    }} world get set-gadget-paint
    
    1024 768 world get resize-gadget
    
    <plain-gadget> world get add-gadget

    <console> "Stack display goes here" <label> <y-splitter>
    3/4 over set-splitter-split add-layer
] bind
