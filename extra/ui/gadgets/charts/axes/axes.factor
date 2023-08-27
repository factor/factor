! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors kernel locals math
math.order opengl sequences ui.gadgets ui.gadgets.charts
ui.gadgets.charts.lines ui.gadgets.charts.utils ui.render ;
IN: ui.gadgets.charts.axes

TUPLE: axis < gadget color ;
TUPLE: vertical-axis < axis ;
TUPLE: horizontal-axis < axis ;

<PRIVATE

ALIAS: x first
ALIAS: y second

: axis-pos ( min,max -- value ) 0 swap first2 clamp ;

:: x-0y-chunk ( x y -- chunk ) x 0 2array x y 2array 2array ;
:: 0x-y-chunk ( x y -- chunk ) 0 y 2array x y 2array 2array ;
: flip-y ( axis-y xmax ymax -- xmax axis-y' ) rot - ;

GENERIC: axis-line ( pos xmax ymax axis -- chunk )
GENERIC: chart-dims ( chart axis -- pixel-width axis-min,max )

M: vertical-axis axis-line
    drop nip x-0y-chunk ;

M: horizontal-axis axis-line
    drop flip-y 0x-y-chunk ;

M: vertical-axis chart-dims
    drop [ dim>> x ] [ chart-axes x ] bi ;

M: horizontal-axis chart-dims
    drop [ dim>> y ] [ chart-axes y ] bi ;

PRIVATE>

M: axis draw-gadget*
    dup parent>> dup chart? [| axis chart |
        COLOR: black axis default-color
        chart axis chart-dims [ axis-pos ] keep first2 swap scale
        chart dim>> first2 axis axis-line draw-line
    ] [ 2drop ] if ;
