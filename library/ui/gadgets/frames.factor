! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: arrays generic kernel math namespaces sequences words ;

! A frame arranges gadgets in a 3x3 grid, where the center
! gadgets gets left-over space.
TUPLE: frame grid ;

: <frame-grid>
    { { f f f } { f f f } { f f f } } [ clone ] map ;

: @center 1 1 ;
: @left 0 1 ;
: @right 2 1 ;
: @top 1 0 ;
: @bottom 1 2 ;

: @top-left 0 0 ;
: @top-right 2 0 ;
: @bottom-left 0 2 ;
: @bottom-right 2 2 ;

C: frame ( -- frame )
    dup delegate>gadget <frame-grid> over set-frame-grid ;

: delegate>frame ( tuple -- ) <frame> swap set-delegate ;

: frame-child ( frame i j -- gadget ) rot frame-grid nth nth ;

: frame-add ( gadget frame i j -- )
    #! Add a gadget to a frame. Use this with frames instead
    #! of add-gadget.
    >r >r over [ over add-gadget ] when* r> r>
    3dup frame-child unparent rot frame-grid nth set-nth ;

: frame-remove ( frame i j -- )
    #! Remove a gadget from a frame. Use this with frames
    #! instead of unparent.
    >r >r >r f r> r> r> frame-add ;

: reduce-grid ( grid -- seq )
    [ max-dim ] map ;

: frame-pref-dim ( grid -- dim )
    reduce-grid { 0 0 0 } [ v+ ] reduce ;

: pref-dim-grid ( grid -- grid )
    [ [ [ pref-dim ] [ { 0 0 0 } ] if* ] map ] map ;

M: frame pref-dim* ( frame -- dim )
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

: frame-add-spec ( { quot setter loc } -- )
    first3 >r >r call
    frame get 2dup r> dup [ execute ] [ 3drop ] if
    r> execute frame-add ;

: build-frame ( frame specs -- )
    #! Specs is an array of triples { quot setter loc }.
    #! The setter has stack effect ( new gadget -- ),
    #! the loc is @center, @top, etc.
    [ swap frame set [ frame-add-spec ] each ] with-scope ;

: make-frame ( specs -- gadget )
    <frame> [ swap build-frame ] keep ;

: make-frame* ( gadget specs -- gadget )
    over [ delegate>frame build-frame ] keep ;
