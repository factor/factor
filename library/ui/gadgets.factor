! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists namespaces ;

! Gadget protocol.
GENERIC: pick-up ( point gadget -- gadget )

! A gadget is a shape together with paint, and a reference to
! the gadget's parent. A gadget delegates to its shape.
TUPLE: gadget paint parent delegate ;

C: gadget ( shape -- gadget )
    [ set-gadget-delegate ] keep
    [ <namespace> swap set-gadget-paint ] keep ;

: paint-property ( gadget key -- value )
    swap gadget-paint hash ;

: set-paint-property ( gadget value key -- )
    rot gadget-paint set-hash ;

: with-gadget ( gadget quot -- )
    #! All drawing done inside the quotation is done with the
    #! gadget's paint. If the gadget does not have any custom
    #! paint, just call the quotation.
    >r gadget-paint r> bind ;

M: gadget draw ( gadget -- )
    dup [ gadget-delegate draw ] with-gadget ;

M: gadget pick-up tuck inside? [ drop f ] unless ;

! An invisible gadget.
WRAPPER: ghost
M: ghost draw drop ;
M: ghost pick-up 2drop f ;

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

M: general-list pick-up ( point list -- gadget )
    dup [
        2dup car pick-up dup [
            2nip
        ] [
            drop cdr pick-up
        ] ifte
    ] [
        2drop f
    ] ifte ;

M: box pick-up ( point box -- )
    #! The logic is thus. If the point is definately outside the
    #! box, return f. Otherwise, see if the point is contained
    #! in any subgadget. If not, see if it is contained in the
    #! box delegate.
    dup [
        2dup gadget-delegate inside? [
            2dup box-contents pick-up dup [
                2nip
            ] [
                drop box-delegate pick-up
            ] ifte
        ] [
            2drop f
        ] ifte
    ] with-translation ;
