! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays gadgets-panes kernel math sequences ;

TUPLE: grid children ;

: collapse-grid concat [ ] subset ;

: set-grid-children* ( children grid -- )
    [ set-grid-children ] 2keep
    >r collapse-grid r> add-gadgets ;

C: grid ( children -- grid )
    dup delegate>gadget [ set-grid-children* ] keep ;

: grid-child ( grid i j -- gadget ) rot grid-children nth nth ;

: grid-add ( gadget grid i j -- )
    >r >r over [ over add-gadget ] when* r> r>
    3dup grid-child unparent rot grid-children nth set-nth ;

: grid-remove ( grid i j -- )
    >r >r >r f r> r> r> grid-add ;

: reduce-grid [ max-dim ] map ;

: grid-pref-dim ( dims -- dim )
    reduce-grid { 0 0 0 } [ v+ ] reduce ;

: pref-dim-grid ( children -- dims )
    [ [ [ pref-dim ] [ { 0 0 0 } ] if* ] map ] map ;

M: grid pref-dim* ( frame -- dim )
    grid-children pref-dim-grid
    dup flip grid-pref-dim first
    swap grid-pref-dim second
    0 3array ;

: pair-up ( horiz vert -- dims )
    [ swap [ swap 0 3array ] map-with ] map-with ;

: do-grid ( children dims quot -- )
    -rot swap [
        [ dup [ pick call ] [ 2drop ] if ] 2each
    ] 2each drop ; inline

: position-grid ( children horiz vert -- )
    [ 0 [ + ] accumulate ] 2apply
    pair-up [ set-rect-loc ] do-grid ;

: resize-grid ( children horiz vert -- )
    pair-up [ set-gadget-dim ] do-grid ;

: grid-layout ( children horiz vert -- )
    3dup position-grid resize-grid ;

: compute-grid ( children -- horiz vert )
    pref-dim-grid
    dup flip reduce-grid [ first ] map
    swap reduce-grid [ second ] map ;

M: grid layout* ( frame -- dim )
    grid-children dup compute-grid grid-layout ;

: pane-grid ( quot grid -- gadget )
    [ [ swap make-pane ] map-with ] map-with <grid> ;
