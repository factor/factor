! Copyright (C) 2016-2017 Alexander Ilin.

USING: accessors arrays binary-search charts combinators
combinators.short-circuit fry kernel locals make math math.order
math.statistics math.vectors namespaces opengl opengl.gl
sequences specialized-arrays.instances.alien.c-types.float
splitting.monotonic ui.gadgets ui.render ;
IN: charts.lines

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

: calc-line-slope ( point1 point2 -- slope ) v- first2 swap / ;
: calc-y ( slope x point -- y ) first2 [ - * ] dip + ;
: calc-x ( slope y point -- x ) first2 swap [ - swap / ] dip + ;
: y-at ( x point1 point2 -- y ) dupd calc-line-slope -rot calc-y ;
: last2 ( seq -- penultimate ultimate ) 2 tail* first2 ;

! Due to the way adjusted-tail-slice works, the first element of
! pairs is <= min, and if the first is < min, then the second is
! > min. Otherwise the first one would be = min.
: left-cut ( min pairs -- seq )
    2dup first first < [
        [ dupd first2 y-at 2array ] keep rest-slice swap prefix
    ] [
        nip
    ] if ;

! Due to the way adjusted-head-slice works, the last element of
! pairs is >= max, and if the last is > max, then the second to
! last is < max. Otherwise the last one would be = max.
: right-cut ( max pairs -- seq )
    2dup last first < [
        [ dupd last2 y-at 2array ] keep but-last-slice swap suffix
    ] [
        nip
    ] if ;

! If the line spans beyond min or max, make sure there are points
! with x = min and x = max in seq.
: min-max-cut ( min,max pairs -- seq )
    [ first2 ] dip right-cut left-cut ;

: clip-by-first ( min,max pairs -- pairs' )
    2dup first-in-bounds? [
        [ dup first  ] dip [ search-first? not ] keep
        adjusted-tail-slice
        [ dup second ] dip [ search-first? not ] keep
        adjusted-head-slice
        dup length 1 > [ min-max-cut ] [ nip ] if
        dup slice? [ dup like ] when
    ] [
        2drop { } clone
    ] if ;

: between<=> ( value min max -- <=> )
    3dup between? [ 3drop +eq+ ] [ nip > +gt+ +lt+ ? ] if ;


: calc-point-y ( slope y point -- xy ) over [ calc-x ] dip 2array ;

: xyy>chunk ( x y1 y2 -- chunk )
    [ over ] dip 2array [ 2array ] dip 2array ;

:: 2-point-chunk ( left right ymin ymax -- chunk )
    left last :> left-point right first :> right-point
    left-point x right-point x = [
        left-point x ymin ymax xyy>chunk
    ] [
        left-point right-point calc-line-slope :> slope
        slope ymin left-point calc-point-y
        slope ymax left-point calc-point-y
        left-point y right-point y > [ swap ] when 2array
    ] if ;

:: fix-left-chunk ( left right ymin ymax -- left' )
    left last :> left-point right first :> right-point
    left-point y { [ ymin = ] [ ymax = ] } 1|| [
        left
    ] [
        left-point y right-point y < ymin ymax ? :> y-coord
        left-point x right-point x = [
            left-point x y-coord 2array
        ] [
            left-point right-point calc-line-slope
            y-coord left-point calc-point-y
        ] if
        left but-last-slice swap suffix
    ] if ;

:: fix-right-chunk ( left right ymin ymax -- right' )
    left last :> left-point right first :> right-point
    right-point y { [ ymin = ] [ ymax = ] } 1|| [
        right
    ] [
        left-point y right-point y < ymin ymax ? :> y-coord
        left-point x right-point x = [
            right-point x y-coord 2array
        ] [
            left-point right-point calc-line-slope
            y-coord left-point calc-point-y
        ] if
        right rest-slice swap suffix
    ] if ;

: first-point ( chunks -- first-point ) first first ;
: last-point ( chunks -- last-point ) last last ;

SYMBOL: elt

: each2* ( seq quot: ( prev next -- next' ) -- last )
    [ unclip-slice elt ] dip '[
        [ elt get swap @ elt set ] each elt get
    ] with-variable ; inline

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
                chunks dup first-point y min max between?
                [ drop { } clone ] unless
            ]
        }
        [
            drop [
                chunks [ min max (make-pair) ] each2*
                dup first y min max between? [ , ] [ drop ] if
            ] { } make
        ]
    } case ;

! Split data into chunks to be drawn within the [ymin,ymax] limits.
! Return the (empty?) sequence of chunks, possibly with some new
! points at ymin and ymax at the gap bounds.
: drawable-chunks ( data ymin,ymax -- chunks )
    first2 [
        '[ [ second _ _ between<=> ] bi@ = ]
        monotonic-split-slice
    ] 2keep (drawable-chunks) ;

PRIVATE>

: draw-line ( seq -- )
    dup [ 1 head-slice* ] over length odd? [ dip ] [ call ] if
    1 tail-slice append
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
        dupd clip-data swap second drawable-chunks
        [ [ draw-line ] each ] unless-empty
    ] [ 2drop ] if ;
