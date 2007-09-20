! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic kernel math namespaces sequences words
splitting math.vectors ui.gadgets.grids ui.gadgets ;
IN: ui.gadgets.frames

! A frame arranges gadgets in a 3x3 grid, where the center
! gadgets gets left-over space.
TUPLE: frame ;

: <frame-grid> 9 [ drop <gadget> ] map 3 group ;

: @center 1 1 ;
: @left 0 1 ;
: @right 2 1 ;
: @top 1 0 ;
: @bottom 1 2 ;

: @top-left 0 0 ;
: @top-right 2 0 ;
: @bottom-left 0 2 ;
: @bottom-right 2 2 ;

: <frame> ( -- frame )
    frame construct-empty
    <frame-grid> <grid> over set-gadget-delegate ;

: (fill-center) ( vec n -- )
    over first pick third v+ [v-] 1 rot set-nth ;

: fill-center ( horiz vert dim -- )
    tuck (fill-center) (fill-center) ;

M: frame layout*
    dup compute-grid
    [ rot rect-dim fill-center ] 3keep
    grid-layout ;

: make-frame ( quot -- frame )
    <frame> make-gadget ; inline

: build-frame ( tuple quot -- tuple )
    <frame> build-gadget ; inline

: frame, ( gadget i j -- )
    \ make-gadget get -rot grid-add ;
