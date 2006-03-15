! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic hashtables kernel lists math sequences ;

: action ( gadget gesture -- quot )
    swap gadget-gestures ?hash ;

: init-gestures ( gadget -- gestures )
    dup gadget-gestures
    [ ] [ H{ } clone dup rot set-gadget-gestures ] ?if ;

: set-action ( gadget quot gesture -- )
    rot init-gestures set-hash ;

: add-actions ( gadget hash -- )
    dup [ >r init-gestures r> hash-update ] [ 2drop ] if ;

: handle-gesture* ( gesture gadget -- ? )
    tuck gadget-gestures ?hash dup [ call f ] [ 2drop t ] if ;

: handle-gesture ( gesture gadget -- ? )
    #! If a gadget's handle-gesture* generic returns t, the
    #! event was not consumed and is passed on to the gadget's
    #! parent. This word returns t if no gadget handled the
    #! gesture, otherwise returns f.
    [ dupd handle-gesture* ] each-parent nip ;

: user-input ( str gadget -- ? )
    [ dupd user-input* ] each-parent nip ;

! Mouse gestures are lists where the first element is one of:
SYMBOL: motion
SYMBOL: drag
SYMBOL: button-up
SYMBOL: button-down
SYMBOL: wheel-up
SYMBOL: wheel-down
SYMBOL: mouse-enter
SYMBOL: mouse-leave

SYMBOL: lose-focus
SYMBOL: gain-focus
