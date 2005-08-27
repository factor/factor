! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic hashtables kernel lists math matrices sdl
sequences ;

: action ( gadget gesture -- quot )
    swap gadget-gestures ?hash ;

: set-action ( gadget quot gesture -- )
    pick gadget-gestures ?set-hash swap set-gadget-gestures ;

: add-actions ( alist gadget -- )
    swap [ unswons set-action ] each-with ;

: handle-gesture* ( gesture gadget -- ? )
    tuck gadget-gestures ?hash dup [ call f ] [ 2drop t ] ifte ;

: handle-gesture ( gesture gadget -- ? )
    #! If a gadget's handle-gesture* generic returns t, the
    #! event was not consumed and is passed on to the gadget's
    #! parent. This word returns t if no gadget handled the
    #! gesture, otherwise returns f.
    [ dupd handle-gesture* ] each-parent nip ;

: user-input ( ch gadget -- ? )
    [ dupd user-input* ] each-parent nip ;

! Mouse gestures are lists where the first element is one of:
SYMBOL: motion
SYMBOL: drag
SYMBOL: button-up
SYMBOL: button-down
SYMBOL: mouse-enter
SYMBOL: mouse-leave

SYMBOL: lose-focus
SYMBOL: gain-focus
