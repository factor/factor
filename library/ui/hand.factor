! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic kernel lists math namespaces sdl sdl-event
sdl-video ;

SYMBOL: world

! The hand is a special gadget that holds mouse position and
! mouse button click state. The hand's parent is the world, but
! it is special in that the world does not list it as part of
! its contents.
TUPLE: hand click-pos clicked buttons delegate ;

C: hand ( world -- hand )
    0 <gadget> <box>
    over set-hand-delegate
    [ set-gadget-parent ] keep ;

: motion-gesture ( gesture hand -- )
    #! Send the gesture to the gadget at the hand's position in
    #! the world.
    world get pick-up handle-gesture ;

: button-gesture ( gesture hand -- )
    #! Send the gesture to the gadget at the hand's last click
    #! position in the world. This is used to send a button up
    #! to the gadget that was clicked, regardless of the mouse
    #! position at the time of the button up.
    hand-clicked handle-gesture ;

: button/ ( n hand -- )
    [ hand-buttons unique ] keep set-hand-buttons ;

: button\ ( n hand -- )
    [ hand-buttons remove ] keep set-hand-buttons ;
