! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists sdl-event ;

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

TUPLE: redraw-gesture ;
C: redraw-gesture ;

M: object redraw ( gadget -- )
    <redraw-gesture> swap handle-gesture ;
