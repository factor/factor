! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists namespaces ;

! A box is a gadget holding other gadgets.
TUPLE: box contents delegate ;

C: box ( gadget -- box )
    [ set-box-delegate ] keep ;

M: general-list draw ( list -- )
    [ draw ] each ;

M: box draw ( box -- )
    dup [
        dup [
            dup box-contents draw
            box-delegate draw
        ] with-gadget
    ] with-translation ;

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
    dup [
        2dup inside? [
            2dup box-contents pick-up dup [
                2nip
            ] [
                drop box-delegate pick-up*
            ] ifte
        ] [
            2drop f
        ] ifte
    ] with-translation ;

: box- ( gadget box -- )
    2dup box-contents remove swap set-box-contents
    f swap set-gadget-parent ;

: box+ ( gadget box -- )
    #! Add a gadget to a box.
    over gadget-parent [ pick swap box- ] when*
    [ box-contents cons ] keep set-box-contents ;
