! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: namespaces ;

global [
    
    <world> world set
    
    1280 1024 world get resize-gadget
    
    {{

        [[ background [ 255 255 255 ] ]]
        [[ foreground [ 0 0 0 ] ]]
        [[ reverse-video f ]]
        [[ font [[ "Sans Serif" 12 ]] ]]
    }} world get set-gadget-paint
] bind
