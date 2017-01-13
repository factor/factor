! Copyright (C) 2016-2017 Alexander Ilin.

USING: accessors arrays binary-search charts
combinators.short-circuit fry kernel locals math math.order
math.statistics math.vectors opengl opengl.gl sequences
specialized-arrays.instances.alien.c-types.float
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

! Drop chunks that are out of bounds, add extra points where needed.
: (drawable-chunks) ( chunks min max -- chunks )
    '[ first second _ _ between? ] filter harvest ;

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
        dupd clip-data swap second drawable-chunks
        [ [ draw-line ] each ] unless-empty
    ] [ 2drop ] if ;
