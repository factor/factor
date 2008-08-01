
USING: kernel quotations arrays sequences math math.ranges fry
       opengl opengl.gl ui.render ui.gadgets.cartesian processing.shapes
       accessors ;

IN: ui.gadgets.plot

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

M: quotation plot-function ( plot quotation -- plot )
  >r dup plot-range r> '[ dup @ 2array ] map line-strip ;

M: function plot-function ( plot function -- plot )
   dup color>> dup [ >stroke-color ] [ drop ] if
   >r dup plot-range r> function>> '[ dup @ 2array ] map line-strip ;

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