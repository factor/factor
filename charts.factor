! Copyright (C) 2016-2017 Alexander Ilin.

USING: accessors arrays binary-search colors.constants
combinators.short-circuit kernel locals math math.order
math.rectangles math.statistics opengl opengl.gl sequences
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

! : data-rect ( data -- rect )
!    [ [ first first ] [ last first ] bi ] keep
!    [ second ] map minmax swapd
!    2array [ 2array ] dip <extent-rect> ;

: first-in-bounds? ( min,max pairs -- ? )
    {
        [ [ first ] dip last first > not ]
        [ [ second ] dip first first < not ]
    } 2&& ;

: second-in-bounds? ( min,max pairs -- ? )
    [ second ] map minmax 2array
    {
        [ [ first ] dip second > not ]
        [ [ second ] dip first < not ]
    } 2&& ;

! : pairs-in-bounds? ( bounds pairs -- ? )
!    {
!        [ [ first ] dip first-in-bounds? ]
!        [ [ second ] dip second-in-bounds? ]
!    } 2&& ;

: clip-by-first ( min,max pairs -- pairs' )
    2dup first-in-bounds? [
        [ dup first ] dip [ search-index ] keep adjusted-tail
        [ second ] dip [ search-index ] keep adjusted-head
    ] [
        2drop { } clone
    ] if ;

PRIVATE>

! bounds: { { first-min first-max } { second-min second-max } }
: clip-data ( bounds data -- data' )
    dup empty? [ nip ] [
        dupd [ first ] dip clip-by-first
        dup empty? [ nip ] [
            [ second ] dip [ second-in-bounds? ] keep swap
            [ drop { } clone ] unless
        ] if
    ] if ;

! Return the bottom-left and top-right corners of the visible area.
: chart-axes ( chart -- seq )
    drop { { 0 300 } { 0 300 } } ;

! There are several things to do to present data on the screen.
! Map the data coordinates to the screen coordinates.
! Cut off data outside the presentation window.
! Remove redundant points from the drawing pass.

M: line draw-gadget*
    dup parent>> dup chart? [
        chart-axes swap
        [ color>> gl-color ] [ data>> ] bi
        clip-data [ draw-line ] unless-empty
    ] [ 2drop ] if ;

! chart new line new COLOR: blue >>color { { 0 100 } { 100 0 } { 100 50 } { 150 50 } { 200 100 } } >>data add-gadget gadget.
