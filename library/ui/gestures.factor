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

: hierarchy-gesture ( gadget ? gesture -- ? )
    swap [
        2drop f
    ] [
        swap handle-gesture* drop t
    ] ifte ;

: mouse-enter ( point gadget -- )
    #! If the old point is inside the new gadget, do not fire an
    #! enter gesture, since the mouse did not enter. Otherwise,
    #! fire an enter gesture and go on to the parent.
    [
        [ shape-pos + ] keep
        2dup inside? [ mouse-enter ] hierarchy-gesture
    ] each-parent drop ;

: mouse-leave ( point gadget -- )
    #! If the new point is inside the old gadget, do not fire a
    #! leave gesture, since the mouse did not leave. Otherwise,
    #! fire a leave gesture and go on to the parent.
    [
        [ shape-pos + ] keep
        2dup inside? [ mouse-leave ] hierarchy-gesture
    ] each-parent drop ;

: lose-focus ( new old -- )
    #! If the old focus owner is a child of the new owner, do
    #! not fire a focus lost gesture, since the focus was not
    #! lost. Otherwise, fire a focus lost gesture and go to the
    #! parent.
    [
        2dup child? [ lose-focus ] hierarchy-gesture
    ] each-parent drop ;

: gain-focus ( old new -- )
    #! If the old focus owner is a child of the new owner, do
    #! not fire a focus gained gesture, since the focus was not
    #! gained. Otherwise, fire a focus gained gesture and go on
    #! to the parent.
    [
        2dup child? [ gain-focus ] hierarchy-gesture
    ] each-parent drop ;
