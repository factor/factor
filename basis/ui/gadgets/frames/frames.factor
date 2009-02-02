! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays generic kernel math namespaces sequences
words splitting grouping math.vectors ui.gadgets.grids
ui.gadgets math.geometry.rect ;
IN: ui.gadgets.frames

TUPLE: glue < gadget ;

M: glue pref-dim* drop { 0 0 } ;

: <glue> ( -- glue ) glue new-gadget ;

: <frame-grid> ( -- grid ) 9 [ <glue> ] replicate 3 group ;

: @center 1 1 ; inline
: @left 0 1 ; inline
: @right 2 1 ; inline
: @top 1 0 ; inline
: @bottom 1 2 ; inline

: @top-left 0 0 ; inline
: @top-right 2 0 ; inline
: @bottom-left 0 2 ; inline
: @bottom-right 2 2 ; inline

TUPLE: frame < grid ;

: new-frame ( class -- frame )
    <frame-grid> swap new-grid ; inline

: <frame> ( -- frame )
    frame new-frame ;

: (fill-center) ( dim vec -- )
    [ [ first ] [ third ] bi v+ [v-] ] keep set-second ;

: fill-center ( dim horiz vert -- )
    [ (fill-center) ] bi-curry@ bi ;

M: frame layout*
    dup compute-grid
    [ [ dim>> ] 2dip fill-center ] [ grid-layout ] 3bi ;
