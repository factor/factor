! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic kernel lists math namespaces sdl sdl-event
sdl-video ;

DEFER: pick-up*

: pick-up-list ( point list -- gadget )
    dup [
        2dup car pick-up dup [
            2nip
        ] [
            drop cdr pick-up-list
        ] ifte
    ] [
        2drop f
    ] ifte ;

: pick-up* ( point gadget -- gadget/t )
    #! The logic is thus. If the point is definately outside the
    #! box, return f. Otherwise, see if the point is contained
    #! in any subgadget. If not, see if it is contained in the
    #! box delegate.
    2dup inside? [
        2dup [ translate ] keep
        gadget-children pick-up-list dup [
            2nip
        ] [
            drop inside?
        ] ifte
    ] [
        2drop f
    ] ifte ;

: pick-up ( point gadget -- gadget )
    #! pick-up* returns t to mean 'this gadget', avoiding the
    #! exposed facade issue.
    tuck pick-up* dup t = [ drop ] [ nip ] ifte ;

DEFER: world

! The hand is a special gadget that holds mouse position and
! mouse button click state. The hand's parent is the world, but
! it is special in that the world does not list it as part of
! its contents.
TUPLE: hand click-pos clicked buttons delegate ;

C: hand ( world -- hand )
    0 0 <point> <gadget>
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
