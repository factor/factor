! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists namespaces ;

! A box is a gadget holding other gadgets.
TUPLE: box children delegate ;

C: box ( gadget -- box )
    [ set-box-delegate ] keep ;

M: box gadget-children box-children ;

M: box draw-shape ( box -- )
    dup box-delegate draw-gadget
    dup [ box-children [ draw-gadget ] each ] with-translation ;

M: general-list pick-up* ( point list -- gadget )
    dup [
        2dup car pick-up dup [
            2nip
        ] [
            drop cdr pick-up
        ] ifte
    ] [
        2drop f
    ] ifte ;

M: box pick-up* ( point box -- gadget )
    #! The logic is thus. If the point is definately outside the
    #! box, return f. Otherwise, see if the point is contained
    #! in any subgadget. If not, see if it is contained in the
    #! box delegate.
    2dup inside? [
        2dup [ translate ] keep box-children pick-up dup [
            2nip
        ] [
            drop box-delegate pick-up*
        ] ifte
    ] [
        2drop f
    ] ifte ;

: box- ( gadget box -- )
    [ 2dup box-children remq swap set-box-children ] keep
    relayout
    f swap set-gadget-parent ;

: (box+) ( gadget box -- )
    [ box-children cons ] keep set-box-children ;

: unparent ( gadget -- )
    dup gadget-parent dup [ box- ] [ 2drop ] ifte ;

: box+ ( gadget box -- )
    #! Add a gadget to a box.
    over unparent
    dup pick set-gadget-parent
    tuck (box+)
    relayout ;
