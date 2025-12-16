! Copyright (C) 2016-2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs binary-search colors
combinators combinators.short-circuit kernel make
math math.order math.statistics math.vectors opengl opengl.gl
sequences specialized-arrays splitting.monotonic ui.gadgets
ui.gadgets.charts ui.gadgets.charts.utils ui.render ;
QUALIFIED-WITH: alien.c-types c
IN: ui.gadgets.charts.lines

SPECIALIZED-ARRAY: c:float

! Data must be a sequence of { x y } coordinates sorted by
! non-descending x vaues.
TUPLE: line < gadget color data ;

<PRIVATE

: (line-vertices) ( seq -- vertices )
    concat [ 0.3 + ] float-array{ } map-as ;

ALIAS: x first
ALIAS: y second

: search-first ( elt seq -- index elt )
    [ first <=> ] with search ;

: search-first? ( elt seq -- index elt exact-match? )
    dupd search-first rot [ dup first ] dip = ;

! Return a slice of the seq with all elements equal to elt to the
! left of the index, plus one that's not equal, if requested.
:: adjusted-tail-slice ( n elt plus-one? seq -- slice )
    n seq elt x '[ x _ = not ] find-last-from drop seq swap
    [ plus-one? [ 1 + ] unless tail-slice ] when* ;

! Return a slice of the seq with all elements equal to elt to the
! right of the index, plus one that's not equal, if requested.
:: adjusted-head-slice ( n elt plus-one? seq -- slice )
    n seq elt x '[ x _ = not ] find-from drop seq swap
    [ plus-one? [ 1 + ] when index-or-length head-slice ] when* ;

! : data-rect ( data -- rect )
!    [ [ first x ] [ last x ] bi ] keep
!    [ y ] map minmax swapd
!    [ 2array ] bi@ <extent-rect> ;

: x-in-bounds? ( min,max pairs -- ? )
    {
        [ [ first ] dip last x > not ]
        [ [ second ] dip first x < not ]
    } 2&& ;

: y-in-bounds? ( min,max pairs -- ? )
    [ y ] map minmax 2array
    {
        [ [ first ] dip second > not ]
        [ [ second ] dip first < not ]
    } 2&& ;

! : xy-in-bounds? ( bounds pairs -- ? )
!    {
!        [ [ first ] dip x-in-bounds? ]
!        [ [ second ] dip y-in-bounds? ]
!    } 2&& ;

: calc-line-slope ( point1 point2 -- slope ) v- first2 swap / ;
: calc-y ( slope x point -- y ) first2 [ - * ] dip + ;
: calc-x ( slope y point -- x ) first2 swap [ - swap / ] dip + ;
: y-at ( x point1 point2 -- y ) dupd calc-line-slope -rot calc-y ;

! Due to the way adjusted-tail-slice works, the first element of
! pairs is <= xmin, and if the first is < xmin, then the second is
! > xmin. Otherwise the first one would be = xmin.
: left-cut-x ( xmin pairs -- seq )
    2dup first x > [
        [ dupd first2 y-at 2array ] keep rest-slice swap prefix
    ] [
        nip
    ] if ;

! Due to the way adjusted-head-slice works, the last element of
! pairs is >= xmax, and if the last is > xmax, then the second to
! last is < xmax. Otherwise the last one would be = xmax.
: right-cut-x ( xmax pairs -- seq )
    2dup last x < [
        [ dupd last2 y-at 2array ] keep but-last-slice swap suffix
    ] [
        nip
    ] if ;

! If the line spans beyond min or max, make sure there are points
! with x = min and x = max in seq.
: min-max-cut ( min,max pairs -- seq )
    [ first2 ] dip right-cut-x left-cut-x ;

: clip-by-x ( min,max pairs -- pairs' )
    2dup x-in-bounds? [
        [ dup first ] dip [ search-first? not ] keep
        adjusted-tail-slice
        [ dup second ] dip [ search-first? not ] keep
        adjusted-head-slice
        dup length 1 > [ min-max-cut ] [ nip ] if
        dup slice? [ dup like ] when
    ] [
        2drop { }
    ] if ;

: between<=> ( value min max -- <=> )
    3dup between? [ 3drop +eq+ ] [ nip > +gt+ +lt+ ? ] if ;

: calc-point-y ( slope y point -- xy ) over [ calc-x ] dip 2array ;

: xyy>chunk ( x y1 y2 -- chunk )
    overd 2array [ 2array ] dip 2array ;

:: 2-point-chunk ( left right ymin ymax -- chunk )
    left last :> left-point
    right first :> right-point
    left-point x right-point x = [
        left-point x ymin ymax xyy>chunk
    ] [
        left-point right-point calc-line-slope :> slope
        slope ymin left-point calc-point-y
        slope ymax left-point calc-point-y
        left-point y right-point y > [ swap ] when 2array
    ] if ;

:: fix-left-chunk ( left right ymin ymax -- left' )
    left last :> left-point
    right first :> right-point
    left-point y right-point y {
        [ { [ drop ymin = ] [ > ] } 2&& ]
        [ { [ drop ymax = ] [ < ] } 2&& ]
    } 2|| [
        left
    ] [
        left-point y right-point y > ymin ymax ? :> y-coord
        left-point x right-point x = [
            left-point x y-coord 2array
        ] [
            left-point right-point calc-line-slope
            y-coord left-point calc-point-y
        ] if
        left swap suffix
    ] if ;

:: fix-right-chunk ( left right ymin ymax -- right' )
    left last :> left-point
    right first :> right-point
    left-point y right-point y {
        [ { [ ymin = nip ] [ < ] } 2&& ]
        [ { [ ymax = nip ] [ > ] } 2&& ]
    } 2|| [
        right
    ] [
        left-point y right-point y < ymin ymax ? :> y-coord
        left-point x right-point x = [
            right-point x y-coord 2array
        ] [
            left-point right-point calc-line-slope
            y-coord left-point calc-point-y
        ] if
        right swap prefix
    ] if ;

: first-point ( chunks -- first-point ) first first ;

: last-point ( chunks -- last-point ) last last ;

:: (make-pair) ( prev next min max -- next' )
    prev next min max
    prev next [ first y min max between<=> ] bi@ 2array
    {
        { { +gt+ +eq+ } [ fix-right-chunk       ] }
        { { +lt+ +eq+ } [ fix-right-chunk       ] }
        { { +eq+ +gt+ } [ fix-left-chunk , next ] }
        { { +eq+ +lt+ } [ fix-left-chunk , next ] }
        { { +gt+ +lt+ } [ 2-point-chunk  , next ] }
        { { +lt+ +gt+ } [ 2-point-chunk  , next ] }
        [ drop "same values - can't happen" throw ]
    } case ;

! Drop chunks that are out of bounds, add extra points where needed.
:: (drawable-chunks) ( chunks min max -- chunks' )
    chunks length {
        { 0 [ chunks ] }
        { 1 [
                chunks first-point y min max between?
                chunks { } ?
            ]
        }
        [
            drop [
                chunks [ ] [ min max (make-pair) ] map-reduce
                dup first y min max between? [ , ] [ drop ] if
            ] { } make
        ]
    } case ;

! Split data into chunks to be drawn within the [ymin,ymax] limits.
! Return the (empty?) sequence of chunks, possibly with some new
! points at ymin and ymax at the gap bounds.
: drawable-chunks ( data ymin,ymax -- chunks )
    first2 [
        '[ [ y _ _ between<=> ] bi@ = ]
        monotonic-split-slice
    ] 2keep (drawable-chunks) ;

: flip-y-axis ( chunks ymin,ymax -- chunks )
    first2 + '[ [ _ swap - ] assoc-map ] map ;

! Return quotation that can be used in map operation.
: scale-mapper ( width min,max -- quot: ( value -- value' ) )
    first2 swap '[ _ swap _ _ scale ] ; inline

! Sometimes no scaling is needed.
! : scale-mapper ( width min,max -- quot: ( value -- value' ) )
!    first2 swap 3dup - = [
!        3drop [ ]
!    ] [
!        '[ _ swap _ _ scale ]
!    ] if ; inline

: scale-chunks ( chunks xwidth xmin,xmax yheight ymin,ymax -- chunks' )
    [ scale-mapper ] 2bi@ '[ [ _ _ bi* ] assoc-map ] map ;

PRIVATE>

: draw-line ( seq -- )
    dup [ but-last-slice ] over length odd? [ dip ] [ call ] if
    rest-slice append
    [ (line-vertices) ] keep length gl-draw-lines ;

! bounds: { { xmin xmax } { ymin ymax } }
: clip-data ( bounds data -- data' )
    dup empty? [ nip ] [
        dupd [ first ] dip clip-by-x
        dup empty? [ nip ] [
            [ second ] dip [ y-in-bounds? ] 1check
            [ drop { } ] unless
        ] if
    ] if ;

M: line draw-gadget*
    dup parent>> dup chart? [| line chart |
        chart chart-axes
        COLOR: black line [ default-color ] [ data>> ] bi
        dupd clip-data swap second [ drawable-chunks ] keep
        flip-y-axis
        chart chart-dim first2 [ chart chart-axes first2 ] dip swap
        scale-chunks
        [ draw-line ] each
    ] [ 2drop ] if ;
