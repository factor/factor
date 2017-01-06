! Copyright (C) 2016-2017 Alexander Ilin.

USING: accessors binary-search colors.constants kernel locals
math math.order opengl opengl.gl sequences
specialized-arrays.instances.alien.c-types.float ui.gadgets
ui.render ;
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

<PRIVATE

: search-index ( elt seq -- index elt )
    [ first <=> ] with search ;

: finder ( elt seq -- seq quot )
    [ first ] dip [ first = not ] with ; inline

: adjusted-tail ( index elt seq -- seq' )
    [ finder find-last-from drop ] keep swap [ 1 + tail ] when* ;

: adjusted-head ( index elt seq -- seq' )
    [ finder find-from drop ] keep swap [ head ] when* ;

:: in-bounds? ( bounds data -- ? )
    bounds first data last first < not
    bounds second data first first > not
    and ;

PRIVATE>

: clip-data ( bounds data -- data' )
    2dup in-bounds? [
        [ dup first ] dip [ search-index ] keep adjusted-tail
        [ second ] dip [ search-index ] keep adjusted-head
    ] [
        2drop { } clone
    ] if ;

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
