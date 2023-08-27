! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel math math.order sequences ui.gadgets
ui.gadgets.grids ui.gadgets.grids.private ;
IN: ui.gadgets.frames

TUPLE: frame < grid { filled-cell initial: { 0 0 } } ;

<PRIVATE

TUPLE: glue < gadget ;

M: glue pref-dim* drop { 0 0 } ;

: <glue> ( -- glue ) glue new ;

: <frame-grid> ( cols rows -- grid )
    swap '[ _ [ <glue> ] replicate ] replicate ;

: (fill- ( frame grid-layout quot1 quot2 -- pref-dim gap filled-cell dims )
    [ '[ [ dim>> ] [ gap>> ] [ filled-cell>> ] tri _ tri@ ] dip ] dip call ; inline

: available-space ( pref-dim gap dims -- avail )
    length 1 + * [-] ; inline

: -center) ( pref-dim gap filled-cell dims -- )
    [ nip available-space ]
    [ [ remove-nth sum [-] ] [ set-nth ] 2bi ] 2bi ; inline

: (fill-center) ( frame grid-layout quot1 quot2 -- ) (fill- -center) ; inline

: fill-center ( frame grid-layout -- )
    [ [ first ] [ column-widths>> ] (fill-center) ]
    [ [ second ] [ row-heights>> ] (fill-center) ] 2bi ;

: <frame-layout> ( frame -- grid-layout )
    dup <grid-layout> [ fill-center ] [ ] bi ;

PRIVATE>

M: frame layout*
    [ grid>> ] [ <frame-layout> ] bi layout-grid ;

: new-frame ( cols rows class -- frame )
    [ <frame-grid> ] dip new-grid ; inline

: <frame> ( cols rows -- frame )
    frame new-frame ;
