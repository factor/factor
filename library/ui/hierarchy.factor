! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: gadgets-layouts generic hashtables kernel lists math
namespaces sequences vectors ;

: remove-gadget ( gadget parent -- )
    f pick set-gadget-parent
    [ gadget-children delete ] keep
    relayout ;

: unparent ( gadget -- )
    [
        dup gadget-parent dup
        [ 2dup remove-gadget ] when 2drop
    ] when* ;

: (clear-gadget) ( gadget -- )
    dup gadget-children [ f swap set-gadget-parent ] each
    f swap set-gadget-children ;

: clear-gadget ( gadget -- )
    dup (clear-gadget) relayout ;

: (add-gadget) ( gadget box -- )
    over unparent
    dup pick set-gadget-parent
    [ gadget-children ?push ] keep set-gadget-children ;

: add-gadget ( gadget parent -- )
    #! Add a gadget to a parent gadget.
    [ (add-gadget) ] keep relayout ;

: add-gadgets ( seq parent -- )
    #! Add all gadgets in a sequence to a parent gadget.
    swap [ over (add-gadget) ] each relayout ;

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
    parents { 0 0 0 } [ rect-loc v+ ] reduce ;

: gadget-point ( gadget vector -- point )
    #! { 0 0 0 } - top left corner
    #! { 1/2 1/2 0 } - middle
    #! { 1 1 0 } - bottom right corner
    >r dup screen-loc swap rect-dim r> v* v+ ;

: relative ( g1 g2 -- g2-g1 ) screen-loc swap screen-loc v- ;

: relative-rect ( g1 g2 -- rect )
    [ relative ] keep rect-dim <rect> ;

: child? ( parent child -- ? ) parents memq? ;

GENERIC: focusable-child* ( gadget -- gadget/t )

M: gadget focusable-child* drop t ;

: focusable-child ( gadget -- gadget )
    dup focusable-child*
    dup t = [ drop ] [ nip focusable-child ] if ;

IN: gadgets-layouts

: make-pile ( children -- pack ) <pile> [ add-gadgets ] keep ;

: make-shelf ( children -- pack ) <shelf> [ add-gadgets ] keep ;

: make-stack ( children -- pack ) <stack> [ add-gadgets ] keep ;
