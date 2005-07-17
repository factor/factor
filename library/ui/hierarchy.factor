! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math matrices namespaces
sequences ;

: remove-gadget ( gadget parent -- )
    [ 2dup gadget-children remq swap set-gadget-children ] keep
    relayout
    f swap set-gadget-parent ;

: unparent ( gadget -- )
    [
        dup gadget-parent dup
        [ remove-gadget ] [ 2drop ] ifte
    ] when* ;

: clear-gadget ( gadget -- )
    dup gadget-children [ f swap set-gadget-parent ] each
    0 over gadget-children set-length relayout ;

: ?push ( elt seq/f -- seq )
    [ push ] [ 1vector ] ifte* ;

: (add-gadget) ( gadget box -- )
    over unparent
    dup pick set-gadget-parent
    [ gadget-children ?push ] keep set-gadget-children ;

: add-gadget ( gadget parent -- )
    #! Add a gadget to a parent gadget.
    [ (add-gadget) ] keep relayout ;

: parents ( gadget -- list )
    #! A list of all parents of the gadget, the first element
    #! is the gadget itself.
    dup [ dup gadget-parent parents cons ] when ;

: each-parent ( gadget quot -- ? )
    #! Keep executing the quotation on higher and higher
    #! parents until it returns f.
    >r parents r> all? ; inline

: screen-loc ( gadget -- point )
    #! The position of the gadget on the screen.
    parents { 0 0 0 } [ shape-loc v+ ] reduce ;

: relative ( g1 g2 -- g2-g1 )
    screen-loc swap screen-loc v- ;

: child? ( parent child -- ? )
    dup [
        2dup eq? [ 2drop t ] [ gadget-parent child? ] ifte
    ] [
        2drop f
    ] ifte ;
