! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: generic hashtables kernel math namespaces sequences vectors words ;
IN: gadgets

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
        dup [ ungraft ] each-child
        dup ungraft*
        f over set-gadget-grafted?
    ] when drop ;

: (unparent) ( gadget -- )
    dup ungraft
    dup forget-pref-dim
    f swap set-gadget-parent ;

: unfocus-gadget ( child gadget -- )
    tuck gadget-focus eq?
    [ f swap set-gadget-focus ] [ drop ] if ;

: unparent ( gadget -- )
    [
        dup gadget-parent dup [
            over (unparent)
            [ unfocus-gadget ] 2keep
            [ gadget-children delete ] keep
            relayout
        ] [
            2drop
        ] if
    ] when* ;

: (clear-gadget) ( gadget -- )
    dup [ (unparent) ] each-child
    f over set-gadget-focus
    f swap set-gadget-children ;

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
    [ (add-gadget) ] keep relayout ;

: add-gadgets ( seq parent -- )
    swap [ over (add-gadget) ] each relayout ;

: (parents) ( gadget -- )
    [ dup , gadget-parent (parents) ] when* ;

: parents ( gadget -- seq )
    [ (parents) ] { } make ;

: each-parent ( gadget quot -- ? )
    >r parents r> all? ; inline

: find-parent ( gadget quot -- parent )
    >r parents r> find nip ; inline

: screen-loc ( gadget -- loc )
    parents { 0 0 } [ rect-loc v+ ] reduce ;

: (screen-rect) ( gadget -- loc ext )
    dup gadget-parent [
        >r rect-extent r> (screen-rect)
        >r tuck v+ r> vmin >r v+ r>
    ] [
        rect-extent
    ] if* ;

: screen-rect ( gadget -- rect )
    (screen-rect) <extent-rect> ;

: child? ( parent child -- ? )
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ dup not ] [ 2drop f ] }
        { [ t ] [ gadget-parent child? ] }
    } cond ;

GENERIC: focusable-child* ( gadget -- child/t )

M: gadget focusable-child* drop t ;

: focusable-child ( gadget -- child )
    dup focusable-child*
    dup t eq? [ drop ] [ nip focusable-child ] if ;

: make-gadget ( quot gadget -- gadget )
    [ dup \ make-gadget set slip ] with-scope ; inline

: gadget, ( gadget -- ) \ make-gadget get add-gadget ;

: make-pile ( quot -- pack )
    <pile> make-gadget ; inline

: make-filled-pile ( quot -- pack )
    <filled-pile> make-gadget ; inline

: make-shelf ( quot -- pack )
    <shelf> make-gadget ; inline

: with-gadget ( gadget quot -- )
    [ swap gadget set call ] with-scope ; inline

: g ( -- gadget ) gadget get ;

: g-> ( x -- x x gadget ) dup g ;

: with-gadget ( gadget quot -- )
    [
        swap dup \ make-gadget set gadget set call
    ] with-scope ; inline

: build-gadget ( tuple quot gadget -- tuple )
    pick set-gadget-delegate over >r with-gadget r> ; inline
