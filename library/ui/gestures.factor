! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic hashtables kernel lists sdl-event ;

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
    dup [
        2dup handle-gesture* [
            gadget-parent handle-gesture
        ] [
            2drop
        ] ifte
    ] [
        2drop
    ] ifte ;

! Redraw gesture. Don't handle this yourself.
: redraw ( gadget -- )
    \ redraw swap handle-gesture ;

! Mouse gestures are lists where the first element is one of:
SYMBOL: motion
SYMBOL: button-up
SYMBOL: button-down
