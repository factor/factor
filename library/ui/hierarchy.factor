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

: (add-gadget) ( gadget box -- )
    #! This is inefficient.
    over unparent
    dup pick set-gadget-parent
    [ gadget-children swap add ] keep set-gadget-children ;

: add-gadget ( gadget parent -- )
    #! Add a gadget to a parent gadget.
    [ (add-gadget) ] keep relayout ;

: (parents) ( gadget -- )
    [ dup gadget-parent (parents) , ] when* ;

: parents ( gadget -- list )
    #! A list of all parents of the gadget, including the
    #! gadget itself.
    [ (parents) ] make-list ;

: (each-parent) ( list quot -- ? )
    over [
        over car gadget-paint [
            2dup >r >r >r cdr r> (each-parent) [
                r> car r> call
            ] [
                r> r> 2drop f
            ] ifte
        ] bind
    ] [
        2drop t
    ] ifte ; inline

: each-parent ( gadget quot -- ? )
    #! Keep executing the quotation on higher and higher
    #! parents until it returns f.
    >r parents r> (each-parent) ; inline

: screen-pos ( gadget -- point )
    #! The position of the gadget on the screen.
    0 swap [ shape-pos + t ] each-parent drop ;

: screen-loc ( gadget -- point )
    #! The position of the gadget on the screen.
    { 0 0 0 } swap [ shape-loc v+ t ] each-parent drop ;

: relative ( g1 g2 -- g2-g1 )
    screen-loc swap screen-loc v- ;

: child? ( parent child -- ? )
    dup [
        2dup eq? [ 2drop t ] [ gadget-parent child? ] ifte
    ] [
        2drop f
    ] ifte ;
