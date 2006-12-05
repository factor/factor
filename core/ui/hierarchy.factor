! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: generic hashtables inference kernel math namespaces
sequences vectors words parser ;

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

: add-spec ( quot spec -- )
    dup first %
    dup second [ [ dup gadget get ] % , ] when*
    dup third %
    [ gadget get ] %
    fourth ,
    % ;

: (build-spec) ( quot spec -- quot )
    [ [ add-spec ] each-with ] [ ] make ;

: build-spec ( spec quot -- )
    swap (build-spec) call ;

\ build-spec 2 0 <effect> "inferred-effect" set-word-prop

\ build-spec [
    pop-literal pop-literal nip (build-spec) infer-quot-value
] "infer" set-word-prop

: (parents) ( gadget -- )
    [ dup , gadget-parent (parents) ] when* ;

: parents ( gadget -- vector )
    #! A list of all parents of the gadget, the first element
    #! is the gadget itself.
    [ (parents) ] { } make ;

: each-parent ( gadget quot -- ? )
    >r parents r> all? ; inline

: find-parent ( gadget quot -- gadget )
    >r parents r> find nip ; inline

: screen-loc ( gadget -- point )
    #! The position of the gadget on the screen.
    parents { 0 0 } [ rect-loc v+ ] reduce ;

: child? ( parent child -- ? ) parents memq? ;

GENERIC: focusable-child* ( gadget -- gadget/t )

M: gadget focusable-child* drop t ;

: focusable-child ( gadget -- gadget )
    dup focusable-child*
    dup t eq? [ drop ] [ nip focusable-child ] if ;

: make-pile ( children -- pack ) <pile> [ add-gadgets ] keep ;

: make-filled-pile ( children -- pack )
    make-pile 1 over set-pack-fill ;

: make-shelf ( children -- pack ) <shelf> [ add-gadgets ] keep ;
