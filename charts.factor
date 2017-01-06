! Copyright (C) 2016-2017 Alexander Ilin.

USING: accessors colors.constants kernel math opengl opengl.gl
sequences specialized-arrays.instances.alien.c-types.float
ui.gadgets ui.render ;
IN: charts

TUPLE: chart < gadget ;

! Data must be sorted by ascending x coordinate.
TUPLE: line < gadget color data ;

M: chart pref-dim* drop { 300 300 } ;

: (line-vertices) ( seq -- vertices )
    concat [ 0.3 + ] float-array{ } map-as ;

: draw-line ( seq -- )
    dup dup length odd? [ [ 1 head* ] dip ] [ 1 head* ] if
    1 tail append
    [ (line-vertices) gl-vertex-pointer GL_LINES 0 ] keep
    length glDrawArrays ;

! Return the bottom-left and top-right corners of the visible area.
: chart-axes ( chart -- seq )
    drop { { 0 300 } { 300 0 } } ;

! There are several things to do to present data on the screen.
! Map the data coordinates to the screen coordinates.
! Cut off data outside the presentation window.
! Remove redundant points from the drawing pass.

M: line draw-gadget*
    dup parent>> dup chart? [
        chart-axes drop
        [ color>> gl-color ]
        [ data>> draw-line ] bi
    ] [ 2drop ] if ;

! chart new line new COLOR: blue >>color { { 0 100 } { 100 0 } { 100 50 } { 150 50 } { 200 100 } } >>data add-gadget gadget.
