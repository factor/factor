! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic hashtables kernel lists math sdl-event ;

: action ( gadget gesture -- quot )
    swap gadget-gestures hash ;

: set-action ( gadget quot gesture -- )
    rot gadget-gestures set-hash ;

: handle-gesture* ( gesture gadget -- ? )
    tuck gadget-gestures hash* dup [
        cdr call f
    ] [
        2drop t
    ] ifte ;

: handle-gesture ( gesture gadget -- )
    #! If a gadget's handle-gesture* generic returns t, the
    #! event was not consumed and is passed on to the gadget's
    #! parent.
    [ dupd handle-gesture* ] each-parent drop ;

! Mouse gestures are lists where the first element is one of:
SYMBOL: motion
SYMBOL: button-up
SYMBOL: button-down

: mouse-enter ( point gadget -- )
    #! If the old point is inside the new gadget, do not fire an
    #! enter gesture, since the mouse did not enter. Otherwise,
    #! fire an enter gesture and go on to the parent.
    [
        [ shape-pos + ] keep
        2dup inside? [
            drop f
        ] [
            [ mouse-enter ] swap handle-gesture* drop t
        ] ifte
    ] each-parent drop ;

: mouse-leave ( point gadget -- )
    #! If the new point is inside the old gadget, do not fire a
    #! leave gesture, since the mouse did not leave. Otherwise,
    #! fire a leave gesture and go on to the parent.
    [
        [ shape-pos + ] keep
        2dup inside? [
            drop f
        ] [
            [ mouse-leave ] swap handle-gesture* drop t
        ] ifte
    ] each-parent drop ;
