
USING: kernel quotations arrays sequences math math.ranges fry
       opengl opengl.gl ui.render ui.gadgets.cartesian processing.shapes
       accessors
       help.syntax
       easy-help ;

IN: ui.gadgets.plot

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ARTICLE: "ui.gadgets.plot" "Plot Gadget"

Summary:

    A simple gadget for ploting two dimentional functions.

    Use the arrow keys to move around.

    Use 'a' and 'z' keys to zoom in and out. ..

Example:

    <plot> [ sin ] add-function gadget.    ..

Example:

    <plot>
      [ sin ] red  function boa add-function
      [ cos ] blue function boa add-function
    gadget.    ..

;

ABOUT: "ui.gadgets.plot"

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: plot < cartesian functions points ;

: init-plot ( plot -- plot )
  init-cartesian
    { } >>functions
    100 >>points ;

: <plot> ( -- plot ) plot new init-plot ;

: step-size ( plot -- step-size )
  [ [ x-max>> ] [ x-min>> ] bi - ] [ points>> ] bi / ;

: plot-range ( plot -- range )
  [ x-min>> ] [ x-max>> ] [ step-size ] tri <range> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: function function color ;

GENERIC: plot-function ( plot object -- plot )

M: callable plot-function ( plot quotation -- plot )
  [ dup plot-range ] dip '[ dup @ 2array ] map line-strip ;

M: function plot-function ( plot function -- plot )
   dup color>> dup [ >stroke-color ] [ drop ] if
   [ dup plot-range ] dip function>> '[ dup @ 2array ] map line-strip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: plot-functions ( plot -- plot ) dup functions>> [ plot-function ] each ;

: draw-axis ( plot -- plot )
  dup
    [ [ x-min>> ] [ drop 0  ] bi 2array ]
    [ [ x-max>> ] [ drop 0  ] bi 2array ] bi line*
  dup
    [ [ drop 0  ] [ y-min>> ] bi 2array ]
    [ [ drop 0  ] [ y-max>> ] bi 2array ] bi line* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: ui.gadgets.slate ;

M: plot draw-slate ( plot -- plot )
   2 glLineWidth
   draw-axis
   plot-functions
   fill-mode
   1 glLineWidth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: add-function ( plot function -- plot )
  over functions>> swap suffix >>functions ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: x-span ( plot -- span ) [ x-max>> ] [ x-min>> ] bi - ;
: y-span ( plot -- span ) [ y-max>> ] [ y-min>> ] bi - ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: ui.gestures ui.gadgets ;

: left ( plot -- plot )
  dup [ x-min>> ] [ x-span 1/10 * ] bi - >>x-min
  dup [ x-max>> ] [ x-span 1/10 * ] bi - >>x-max
  dup relayout-1 ;

: right ( plot -- plot )
  dup [ x-min>> ] [ x-span 1/10 * ] bi + >>x-min
  dup [ x-max>> ] [ x-span 1/10 * ] bi + >>x-max
  dup relayout-1 ;

: down ( plot -- plot )
  dup [ y-min>> ] [ y-span 1/10 * ] bi - >>y-min
  dup [ y-max>> ] [ y-span 1/10 * ] bi - >>y-max
  dup relayout-1 ;

: up ( plot -- plot )
  dup [ y-min>> ] [ y-span 1/10 * ] bi + >>y-min
  dup [ y-max>> ] [ y-span 1/10 * ] bi + >>y-max
  dup relayout-1 ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: zoom-in-horizontal ( plot -- plot )
  dup [ x-min>> ] [ x-span 1/10 * ] bi + >>x-min
  dup [ x-max>> ] [ x-span 1/10 * ] bi - >>x-max ;

: zoom-in-vertical ( plot -- plot )
  dup [ y-min>> ] [ y-span 1/10 * ] bi + >>y-min
  dup [ y-max>> ] [ y-span 1/10 * ] bi - >>y-max ;

: zoom-in ( plot -- plot )
  zoom-in-horizontal
  zoom-in-vertical
  dup relayout-1 ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: zoom-out-horizontal ( plot -- plot )
  dup [ x-min>> ] [ x-span 1/10 * ] bi - >>x-min
  dup [ x-max>> ] [ x-span 1/10 * ] bi + >>x-max ;

: zoom-out-vertical ( plot -- plot )
  dup [ y-min>> ] [ y-span 1/10 * ] bi - >>y-min
  dup [ y-max>> ] [ y-span 1/10 * ] bi + >>y-max ;

: zoom-out ( plot -- plot )
  zoom-out-horizontal
  zoom-out-vertical
  dup relayout-1 ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

plot
  H{
    { T{ mouse-enter } [ request-focus ] }
    { T{ key-down f f "LEFT"  } [ left drop  ] }
    { T{ key-down f f "RIGHT" } [ right drop ] }
    { T{ key-down f f "DOWN"  } [ down drop  ] }
    { T{ key-down f f "UP"    } [ up drop    ] }
    { T{ key-down f f "a"     } [ zoom-in  drop ] }
    { T{ key-down f f "z"     } [ zoom-out drop ] }
  }
set-gestures