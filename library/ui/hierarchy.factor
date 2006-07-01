! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel math namespaces sequences
vectors words ;

GENERIC: graft* ( gadget -- )

M: gadget graft* drop ;

: graft ( gadget -- )
    t over set-gadget-grafted?
    dup graft*
    [ graft ] each-child ;

GENERIC: ungraft* ( gadget -- )

M: gadget ungraft* drop ;

: ungraft ( gadget -- )
    dup gadget-grafted? [
        dup [ ungraft* ] each-child
        dup ungraft*
        f over set-gadget-grafted?
    ] when drop ;

: (unparent) ( gadget -- )
    dup ungraft
    dup forget-pref-dim f swap set-gadget-parent ;

: unparent ( gadget -- )
    [
        dup gadget-parent dup [
            over (unparent)
            [ gadget-children delete ] keep relayout
        ] [
            2drop
        ] if
    ] when* ;

: (clear-gadget) ( gadget -- )
    dup [ (unparent) ] each-child f swap set-gadget-children ;

: clear-gadget ( gadget -- )
    dup (clear-gadget) relayout ;

: ((add-gadget)) ( gadget box -- )
    [ gadget-children ?push ] keep set-gadget-children ;

: (add-gadget) ( gadget box -- )
    over unparent
    dup pick set-gadget-parent
    [ ((add-gadget)) ] 2keep
    gadget-grafted? [ graft ] [ drop ] if ;

: add-gadget ( gadget parent -- )
    #! Add a gadget to a parent gadget.
    [ (add-gadget) ] keep relayout ;

: add-gadgets ( seq parent -- )
    #! Add all gadgets in a sequence to a parent gadget.
    swap [ over (add-gadget) ] each relayout ;

: add-spec ( { quot setter post loc } quot -- )
    [
        over first %
        over second [ [ dup gadget get ] % , ] when*
        over third %
        [ gadget get ] %
        swap fourth ,
        %
    ] [ ] make call ;

: (parents) ( gadget vector -- )
    over
    [ 2dup push >r gadget-parent r> (parents) ] [ 2drop ] if ;

: parents ( gadget -- vector )
    #! A list of all parents of the gadget, the first element
    #! is the gadget itself.
    V{ } clone [ (parents) ] keep ;

: each-parent ( gadget quot -- ? )
    >r parents r> all? ; inline

: find-parent ( gadget quot -- gadget )
    >r parents r> find nip ; inline

: screen-loc ( gadget -- point )
    #! The position of the gadget on the screen.
    parents { 0 0 } [ rect-loc v+ ] reduce ;

: gadget-point ( gadget vector -- point )
    #! { 0 0 } - top left corner
    #! { 1/2 1/2 } - middle
    #! { 1 1 } - bottom right corner
    >r dup screen-loc swap rect-dim r> v* v+ ;

: relative-loc ( g1 point -- point-g1 ) swap screen-loc v- ;

: child? ( parent child -- ? ) parents memq? ;

GENERIC: focusable-child* ( gadget -- gadget/t )

M: gadget focusable-child* drop t ;

: focusable-child ( gadget -- gadget )
    dup focusable-child*
    dup t eq? [ drop ] [ nip focusable-child ] if ;

: make-pile ( children -- pack ) <pile> [ add-gadgets ] keep ;

: make-shelf ( children -- pack ) <shelf> [ add-gadgets ] keep ;
