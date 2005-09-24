! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-layouts
USING: arrays gadgets generic kernel lists math namespaces
sequences ;

! A frame arranges gadgets in a 3x3 grid, where the center
! gadgets gets left-over space.
TUPLE: frame grid ;

: <frame-grid> { { f f f } { f f f } { f f f } } [ clone ] map ;

C: frame ( -- frame )
    <gadget> over set-delegate <frame-grid> over set-frame-grid ;

: frame-child ( frame i j -- gadget ) rot frame-grid nth nth ;

: set-frame-child ( gadget frame i j -- )
    3dup frame-child unparent
    >r >r 2dup add-gadget r> r>
    rot frame-grid nth set-nth ;

: add-center ( gadget frame -- ) 1 1 set-frame-child ;
: add-left   ( gadget frame -- ) 0 1 set-frame-child ;
: add-right  ( gadget frame -- ) 2 1 set-frame-child ;
: add-top    ( gadget frame -- ) 1 0 set-frame-child ;
: add-bottom ( gadget frame -- ) 1 2 set-frame-child ;

: get-center ( frame -- gadget ) 1 1 frame-child ;
: get-left   ( frame -- gadget ) 0 1 frame-child ;
: get-right  ( frame -- gadget ) 2 1 frame-child ;
: get-top    ( frame -- gadget ) 1 0 frame-child ;
: get-bottom ( frame -- gadget ) 1 2 frame-child ;

: reduce-grid ( grid -- seq )
    [ @{ 0 0 0 }@ [ vmax ] reduce ] map ;

: frame-pref-dim ( grid -- dim )
    reduce-grid @{ 0 0 0 }@ [ v+ ] reduce ;

: pref-dim-grid ( grid -- grid )
    [ [ [ pref-dim ] [ @{ 0 0 0 }@ ] if* ] map ] map ;

M: frame pref-dim ( frame -- dim )
    frame-grid pref-dim-grid
    dup flip frame-pref-dim first
    swap frame-pref-dim second
    0 3array ;

: frame-layout ( horiz vert -- grid )
    [ swap [ swap 0 3array ] map-with ] map-with ;

: do-grid ( dim-grid gadget-grid quot -- )
    -rot [
        [ dup [ pick call ] [ 2drop ] if ] 2each
    ] 2each drop ; inline

: position-grid ( gadgets horiz vert -- )
    [ 0 [ + ] accumulate ] 2apply
    frame-layout swap [ set-rect-loc ] do-grid ;

: resize-grid ( gadgets horiz vert -- )
    frame-layout swap [ set-gadget-dim ] do-grid ;

: (fill-center) ( vec n -- )
    over first pick third + - 0 max 1 rot set-nth ;

: fill-center ( horiz vert dim -- )
    tuck second (fill-center) first (fill-center) ;

M: frame layout* ( frame -- dim )
    [
        frame-grid dup pref-dim-grid
        dup flip reduce-grid [ first ] map
        swap reduce-grid [ second ] map
        2dup
    ] keep rect-dim fill-center 3dup position-grid resize-grid ;
