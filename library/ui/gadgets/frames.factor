! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays generic kernel math namespaces sequences words ;

! A frame arranges gadgets in a 3x3 grid, where the center
! gadgets gets left-over space.
TUPLE: frame ;

: <frame-grid> 3 [ drop 3 f <array> ] map ;

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
    <frame-grid> <grid> over set-gadget-delegate ;

: delegate>frame ( tuple -- ) <frame> swap set-delegate ;

: (fill-center) ( vec n -- )
    over first pick third + - 0 max 1 rot set-nth ;

: fill-center ( horiz vert dim -- )
    tuck second (fill-center) first (fill-center) ;

M: frame layout* ( frame -- dim )
    [ grid-children dup compute-grid 2dup ] keep
    rect-dim fill-center grid-layout ;

: make-frame ( specs -- gadget )
    <frame> [ swap build-grid ] keep ;

: make-frame* ( gadget specs -- gadget )
    over [ delegate>frame build-grid ] keep ;
