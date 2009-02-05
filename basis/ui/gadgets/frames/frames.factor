! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays generic kernel math namespaces sequences
words splitting grouping math.vectors ui.gadgets.grids
ui.gadgets.grids.private ui.gadgets math.order math.rectangles ;
IN: ui.gadgets.frames

CONSTANT: @center { 1 1 }
CONSTANT: @left { 0 1 }
CONSTANT: @right { 2 1 }
CONSTANT: @top { 1 0 }
CONSTANT: @bottom { 1 2 }

CONSTANT: @top-left { 0 0 }
CONSTANT: @top-right { 2 0 }
CONSTANT: @bottom-left { 0 2 }
CONSTANT: @bottom-right { 2 2 }

TUPLE: frame < grid ;

<PRIVATE

TUPLE: glue < gadget ;

M: glue pref-dim* drop { 0 0 } ;

: <glue> ( -- glue ) glue new-gadget ;

: <frame-grid> ( -- grid ) 9 [ <glue> ] replicate 3 group ;

: (fill-center) ( n seq -- )
    [ [ first ] [ third ] bi + [-] ] keep set-second ;

: fill-center ( dim grid-layout -- )
    [ [ first ] [ column-widths>> ] bi* ]
    [ [ second ] [ row-heights>> ] bi* ] 2bi
    [ (fill-center) ] 2bi@ ;

PRIVATE>

M: frame layout*
    [ grid>> ] [ dim>> ] [ <grid-layout> ] tri
    [ fill-center ] keep grid-layout ;

: new-frame ( class -- frame )
    <frame-grid> swap new-grid ; inline

: <frame> ( -- frame )
    frame new-frame ;