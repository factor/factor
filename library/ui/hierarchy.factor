! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math matrices namespaces
sequences vectors ;

: remove-gadget ( gadget parent -- )
    [ 2dup gadget-children remove swap set-gadget-children ] keep
    relayout f swap set-gadget-parent ;

: unparent ( gadget -- )
    [
        dup gadget-parent dup
        [ remove-gadget ] [ 2drop ] ifte
    ] when* ;

: (clear-gadget) ( gadget -- )
    gadget-children [
        dup [ f swap set-gadget-parent ] each 0 swap set-length
    ] when* ;

: clear-gadget ( gadget -- )
    dup (clear-gadget) relayout ;

: ?push ( elt seq/f -- seq )
    [ [ push ] keep ] [ 1vector ] ifte* ;

: (add-gadget) ( gadget box -- )
    over unparent
    dup pick set-gadget-parent
    [ gadget-children ?push ] keep set-gadget-children ;

: add-gadget ( gadget parent -- )
    #! Add a gadget to a parent gadget.
    [ (add-gadget) ] keep relayout ;

: (parents-down) ( list gadget -- list )
    [ [ swons ] keep gadget-parent (parents-down) ] when* ;

: parents-down ( gadget -- list )
    #! A list of all parents of the gadget, the last element
    #! is the gadget itself.
    f swap (parents-down) ;

: parents-up ( gadget -- list )
    #! A list of all parents of the gadget, the first element
    #! is the gadget itself.
    dup [ dup gadget-parent parents-up cons ] when ;

: each-parent ( gadget quot -- ? )
    >r parents-up r> all? ; inline

: find-parent ( gadget quot -- ? )
    >r parents-up r> find nip ; inline

: screen-loc ( gadget -- point )
    #! The position of the gadget on the screen.
    parents-up { 0 0 0 } [ rect-loc v+ ] reduce ;

: relative ( g1 g2 -- g2-g1 ) screen-loc swap screen-loc v- ;

: child? ( parent child -- ? ) parents-down memq? ;

GENERIC: focusable-child* ( gadget -- gadget/t )

M: gadget focusable-child* drop t ;

: focusable-child ( gadget -- gadget )
    dup focusable-child*
    dup t = [ drop ] [ nip focusable-child ] ifte ;

GENERIC: children-on ( rect/point gadget -- list )

M: gadget children-on ( rect/point gadget -- list )
    nip gadget-children ;

: inside? ( bounds gadget -- ? )
    dup gadget-visible?
    [ >absolute intersects? ] [ 2drop f ] ifte ;

: pick-up-list ( rect/point gadget -- gadget/f )
    dupd children-on reverse-slice [ inside? ] find-with nip ;

: translate ( rect/point -- )
    rect-loc origin [ v+ ] change ;

: pick-up ( rect/point gadget -- gadget )
    2dup inside? [
        [
            dup translate 2dup pick-up-list dup
            [ nip pick-up ] [ rot 2drop ] ifte
        ] with-scope
    ] [ 2drop f ] ifte ;
