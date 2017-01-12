! Copyright (C) 2016-2017 Alexander Ilin.

USING: accessors arrays binary-search charts
combinators.short-circuit kernel locals math math.order
math.statistics opengl opengl.gl sequences
specialized-arrays.instances.alien.c-types.float ui.gadgets
ui.render ;
IN: charts.lines

! Data must be a sequence of { x y } coordinates sorted by
! non-descending x vaues.
TUPLE: line < gadget color data ;

<PRIVATE

: (line-vertices) ( seq -- vertices )
    concat [ 0.3 + ] float-array{ } map-as ;

: search-first ( elt seq -- index elt )
    [ first <=> ] with search ;

: search-first? ( elt seq -- index elt exact-match? )
    dupd search-first rot [ dup first ] dip = ;

: finder ( elt seq -- seq quot )
    [ first ] dip [ first = not ] with ; inline

! Return a slice of the seq with all elements equal elt to the
! left of the index, plus one that's not equal, if requested.
:: adjusted-tail-slice ( index elt plus-one? seq -- slice )
    index elt seq finder find-last-from drop seq swap
    [ plus-one? [ 1 + ] unless tail-slice ] when* ;

! Return a slice of the seq with all elements equal elt to the
! right of the index, plus one that's not equal, if requested.
:: adjusted-head-slice ( index elt plus-one? seq -- slice )
    index elt seq finder find-from drop seq swap
    [ plus-one? [ 1 + ] when short head-slice ] when* ;

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
        [ dup first  ] dip [ search-first? not ] keep
        adjusted-tail-slice
        [ second ] dip [ search-first? not ] keep
        adjusted-head-slice
        dup slice? [ dup like ] when
    ] [
        2drop { } clone
    ] if ;

! Split data into chunks to be drawn within the [ymin,ymax] limits.
! Return the (empty?) sequence of chunks, possibly with some new
! points at ymin and ymax at the gap bounds.
: drawable-chunks ( ymin,ymax data -- chunks )
    1array nip ;

! Edge case: all x points may be outside the range, but the line may cross the visible frame. When there are no points directly on the x bounds those should be constructed and added (when needed, e.g. the line may not start with the leftmost x coordinate, even if it has a point to the left of the xmin: the line may enter the visible area from above).
! If the data starts to the left of the bounds, and there is no point directly on the boundary, then one needs to be constructed and added to the data by finding the point of intersection between the left point and the next one to the right of it with the left boundary. This will guarantee to us that we do have points which are on the edges (if the line spreads beyond any of them).

PRIVATE>

: draw-line ( seq -- )
    dup dup length odd? [ [ 1 head* ] dip ] [ 1 head* ] if
    1 tail append
    [ (line-vertices) gl-vertex-pointer GL_LINES 0 ] keep
    length glDrawArrays ;

! bounds: { { first-min first-max } { second-min second-max } }
: clip-data ( bounds data -- data' )
    dup empty? [ nip ] [
        dupd [ first ] dip clip-by-first
        dup empty? [ nip ] [
            [ second ] dip [ second-in-bounds? ] keep swap
            [ drop { } clone ] unless
        ] if
    ] if ;

M: line draw-gadget*
    dup parent>> dup chart? [
        chart-axes swap
        [ color>> gl-color ] [ data>> ] bi
        dupd clip-data [ second ] dip drawable-chunks
        [ [ draw-line ] each ] unless-empty
    ] [ 2drop ] if ;
