! Copyright (C) 2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors.constants kernel locals math
math.order opengl sequences ui.gadgets ui.gadgets.charts
ui.gadgets.charts.lines ui.gadgets.charts.utils ui.render ;
IN: ui.gadgets.charts.axes

TUPLE: axis < gadget vertical? color ;

<PRIVATE

ALIAS: x first
ALIAS: y second

: axis-pos ( min,max -- value ) 0 swap first2 clamp ;

:: x-0y-chunk ( x y -- chunk ) x 0 2array x y 2array 2array ;
:: 0x-y-chunk ( x y -- chunk ) 0 y 2array x y 2array 2array ;
: flip-y ( axis-y xmax ymax -- xmax axis-y' ) rot - ;

: ?[x/y] ( ? -- quot )
    [ x ] [ y ] ? [ call( a -- b ) ] curry ; inline

PRIVATE>

M: axis draw-gadget*
    dup parent>> dup chart? [| axis chart |
        axis vertical?>> :> vert?
        chart dim>> :> dim
        COLOR: black axis default-color
        dim chart chart-axes vert? ?[x/y] bi@
        [ axis-pos ] keep first2 swap scale
        dim first2 vert? [ nip x-0y-chunk ] [ flip-y 0x-y-chunk ] if
        draw-line
    ] [ 2drop ] if ;
