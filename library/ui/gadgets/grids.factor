! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-grids
USING: arrays gadgets kernel math namespaces sequences words ;

TUPLE: grid children gap ;

: set-grid-children* ( children grid -- )
    [ set-grid-children ] 2keep
    >r concat [ ] subset r> add-gadgets ;

C: grid ( children -- grid )
    dup delegate>gadget
    [ set-grid-children* ] keep
    { 0 0 } over set-grid-gap ;

: grid-child ( grid i j -- gadget ) rot grid-children nth nth ;

: grid-add ( gadget grid i j -- )
    >r >r over [ over add-gadget ] when* r> r>
    3dup grid-child unparent rot grid-children nth set-nth ;

: grid-remove ( grid i j -- )
    >r >r >r f r> r> r> grid-add ;

: pref-dim-grid ( -- dims )
    grid get grid-children
    [ [ [ pref-dim ] [ { 0 0 } ] if* ] map ] map ;

: compute-grid ( -- horiz vert )
    pref-dim-grid
    dup flip [ max-dim ] map swap [ max-dim ] map ;

: with-grid ( grid quot -- | quot: horiz vert -- )
    [ >r grid set compute-grid r> call ] with-scope ; inline

: gap grid get grid-gap ;

: (pair-up) ( horiz vert -- dim )
    >r first r> second 2array ;

M: grid pref-dim* ( grid -- dim )
    [
        [ gap [ v+ gap v+ ] reduce ] 2apply (pair-up)
    ] with-grid ;

: do-grid ( dims quot -- )
    swap grid get grid-children [
        [ dup [ pick call ] [ 2drop ] if ] 2each
    ] 2each drop ; inline

: pair-up ( horiz vert -- dims )
    [ swap [ swap (pair-up) ] map-with ] map-with ;

: grid-positions ( dims -- locs )
    gap [ v+ gap v+ ] accumulate ;

: position-grid ( horiz vert -- )
    [ grid-positions ] 2apply
    pair-up [ set-rect-loc ] do-grid ;

: resize-grid ( horiz vert -- )
    pair-up [ set-layout-dim ] do-grid ;

: grid-layout ( horiz vert -- )
    2dup position-grid resize-grid ;

M: grid layout* ( frame -- dim )
    [ grid-layout ] with-grid ;

: grid-add-spec ( { quot setter loc } -- )
    first3 >r >r call
    grid get 2dup r> dup [ execute ] [ 3drop ] if
    r> execute grid-add ;

: build-grid ( grid specs -- )
    #! Specs is an array of triples { quot setter loc }.
    #! The setter has stack effect ( new gadget -- ),
    #! the loc is @center, @top, etc.
    [ swap grid set [ grid-add-spec ] each ] with-scope ;
