! Copyright (C) 2007, 2008 Ryan Murphy, Doug Coleman,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry kernel kernel.private locals
math math.order math.private sequences sequences.private summary
vectors ;
IN: heaps

GENERIC: heap-push* ( value key heap -- entry )
GENERIC: heap-peek ( heap -- value key )
GENERIC: heap-pop* ( heap -- )
GENERIC: heap-pop ( heap -- value key )
GENERIC: heap-delete ( entry heap -- )
GENERIC: heap-empty? ( heap -- ? )
GENERIC: heap-size ( heap -- n )

<PRIVATE

TUPLE: heap { data vector } ;

: <heap> ( class -- heap )
    V{ } clone swap boa ; inline

ERROR: not-a-heap object ;

: check-heap ( heap -- heap )
    dup heap? [ throw-not-a-heap ] unless ; inline

TUPLE: entry value key heap index ;

: <entry> ( value key heap -- entry )
    f entry boa ; inline

PRIVATE>

TUPLE: min-heap < heap ;

: <min-heap> ( -- min-heap ) min-heap <heap> ;

TUPLE: max-heap < heap ;

: <max-heap> ( -- max-heap ) max-heap <heap> ;

M: heap heap-empty? ( heap -- ? )
    data>> empty? ; inline

M: heap heap-size ( heap -- n )
    data>> length ; inline

<PRIVATE

: left ( n -- m )
    { fixnum } declare 1 fixnum-shift-fast 1 fixnum+fast ; inline

: right ( n -- m )
    { fixnum } declare 1 fixnum-shift-fast 2 fixnum+fast ; inline

: up ( n -- m )
    { fixnum } declare 1 fixnum-fast 2/ ; inline

: data-nth ( n heap -- entry )
    data>> nth-unsafe { entry } declare ; inline

: data-first ( heap -- entry )
    data>> first ; inline

: data-set-nth ( entry n heap -- )
    [ [ >>index ] keep ] dip data>> set-nth-unsafe ; inline

: data-push ( entry heap -- n )
    [ heap-size [ >>index ] keep ]
    [ data>> [ set-nth ] 2keep drop ] bi ; inline

GENERIC: heap-compare ( entry1 entry2 heap -- ? )

M: min-heap heap-compare
    drop { entry entry } declare [ key>> ] bi@ after? ; inline

M: max-heap heap-compare
    drop { entry entry } declare [ key>> ] bi@ before? ; inline

: data-compare ( m n heap -- ? )
    [ '[ _ data-nth ] bi@ ] [ heap-compare ] bi ; inline

PRIVATE>

: >entry< ( entry -- value key )
    [ value>> ] [ key>> ] bi ; inline

M: heap heap-peek ( heap -- value key )
    data-first >entry< ;

<PRIVATE

:: sift-down ( heap from to -- )
    to heap data-nth :> tmp

    to t [ over from > and ] [
        dup up
        dup heap data-nth
        dup tmp heap heap-compare [
            rot heap data-set-nth t
        ] [
            2drop f
        ] if
    ] while

    tmp swap heap data-set-nth ; inline

PRIVATE>

M: heap heap-push*
    [ <entry> dup ] [ data-push ] [ 0 rot sift-down ] tri ;

: heap-push ( value key heap -- )
    heap-push* drop ;

: heap-push-all ( assoc heap -- )
    '[ swap _ heap-push ] assoc-each ;

<PRIVATE

:: sift-up ( heap n -- )
    heap heap-size  :> end
    n heap data-nth :> tmp

    n dup left [ dup end < ] [
        dup 1 fixnum+fast
        dup end < [ 2dup heap data-compare ] [ f ] if
        [ nip ] [ drop ] if
        [ heap data-nth swap heap data-set-nth ]
        [ dup left ] bi
    ] while drop

    tmp over heap data-set-nth
    heap n rot sift-down ; inline

PRIVATE>

M: heap heap-pop*
    dup data>> dup length 1 > [
        [ pop ] [ set-first ] bi 0 sift-up
    ] [
        pop* drop
    ] if ; inline

M: heap heap-pop
    [ data-first >entry< ] [ heap-pop* ] bi ;

: slurp-heap ( ... heap quot: ( ... value key -- ... ) -- ... )
    [ check-heap ] dip
    [ drop '[ _ heap-empty? ] ]
    [ '[ _ heap-pop @ ] until ] 2bi ; inline

: heap-pop-all ( heap -- alist )
    [ heap-size <vector> ] keep
    [ swap 2array suffix! ] slurp-heap { } like ;

ERROR: bad-heap-delete ;

M: bad-heap-delete summary
    drop "Invalid entry passed to heap-delete" ;

<PRIVATE

: entry>index ( entry heap -- n )
    over heap>> eq? [ throw-bad-heap-delete ] unless
    index>> { fixnum } declare ; inline

PRIVATE>

M: heap heap-delete
    [ entry>index ] keep
    2dup heap-size 1 - = [
        nip data>> pop*
    ] [
        [ nip data>> pop ]
        [ data-set-nth ]
        [ swap sift-up ] 2tri
    ] if ;

: >min-heap ( assoc -- min-heap )
    dup assoc-size <vector> min-heap boa
    [ heap-push-all ] keep ;

: >max-heap ( assoc -- max-heap )
    dup assoc-size <vector> max-heap boa
    [ heap-push-all ] keep ;
