! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic hashtables kernel lists math sdl ;

: action ( gadget gesture -- quot )
    swap gadget-gestures hash ;

: set-action ( gadget quot gesture -- )
    rot gadget-gestures set-hash ;

: add-actions ( alist gadget -- )
    swap [ unswons set-action ] each-with ;

: handle-gesture* ( gesture gadget -- ? )
    tuck gadget-gestures hash* dup [
        cdr call f
    ] [
        2drop t
    ] ifte ;

: handle-gesture ( gesture gadget -- ? )
    #! If a gadget's handle-gesture* generic returns t, the
    #! event was not consumed and is passed on to the gadget's
    #! parent. This word returns t if no gadget handled the
    #! gesture, otherwise returns f.
    [ dupd handle-gesture* ] each-parent nip ;

: link-action ( gadget to from -- )
    #! When gadget receives 'from' gesture, send a 'to' gesture.
    >r [ swap handle-gesture drop ] cons r> set-action ;

: user-input ( ch gadget -- ? )
    [ dupd user-input* ] each-parent nip ;

! Mouse gestures are lists where the first element is one of:
SYMBOL: motion
SYMBOL: drag
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
    ] each-parent 2drop ;

: mouse-leave ( point gadget -- )
    #! If the new point is inside the old gadget, do not fire a
    #! leave gesture, since the mouse did not leave. Otherwise,
    #! fire a leave gesture and go on to the parent.
    [
        [ shape-pos + ] keep
        2dup inside? [ mouse-leave ] hierarchy-gesture
    ] each-parent 2drop ;

: lose-focus ( new old -- )
    #! If the old focus owner is a child of the new owner, do
    #! not fire a focus lost gesture, since the focus was not
    #! lost. Otherwise, fire a focus lost gesture and go to the
    #! parent.
    [
        2dup child? [ lose-focus ] hierarchy-gesture
    ] each-parent 2drop ;

: gain-focus ( old new -- )
    #! If the old focus owner is a child of the new owner, do
    #! not fire a focus gained gesture, since the focus was not
    #! gained. Otherwise, fire a focus gained gesture and go on
    #! to the parent.
    [
        2dup child? [ gain-focus ] hierarchy-gesture
    ] each-parent 2drop ;
