! Copyright (C) 2007 Ryan Murphy, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: heaps

<PRIVATE
TUPLE: heap data ;

: <heap> ( class -- obj )
    >r V{ } clone heap construct-boa r>
    construct-delegate ; inline
PRIVATE>

TUPLE: min-heap ;

: <min-heap> ( -- min-heap ) min-heap <heap> ;

TUPLE: max-heap ;

: <max-heap> ( -- max-heap ) max-heap <heap> ;

<PRIVATE
: left ( n -- m ) 2 * 1+ ; inline
: right ( n -- m ) 2 * 2 + ; inline
: up ( n -- m ) 1- 2 /i ; inline
: left-value ( n heap -- obj ) >r left r> nth ; inline
: right-value ( n heap -- obj ) >r right r> nth ; inline
: up-value ( n vec -- obj ) >r up r> nth ; inline
: swap-up ( n vec -- ) >r dup up r> exchange ; inline
: last-index ( vec -- n ) length 1- ; inline

GENERIC: heap-compare ( obj1 obj2 heap -- ? )
M: min-heap heap-compare drop <=> 0 > ;
M: max-heap heap-compare drop <=> 0 < ;

: heap-bounds-check? ( m heap -- ? )
    heap-data length >= ; inline
    
: left-bounds-check? ( m heap -- ? )
    >r left r> heap-bounds-check? ; inline

: right-bounds-check? ( m heap -- ? )
    >r right r> heap-bounds-check? ; inline

: up-heap-continue? ( vec heap -- ? )
    >r [ last-index ] keep [ up-value ] keep peek r>
    heap-compare ; inline

: up-heap ( vec heap -- )
    2dup up-heap-continue?  [
        >r dup last-index [ over swap-up ] keep
        up 1+ head-slice r> up-heap
    ] [
        2drop
    ] if ;

: (child) ( m heap -- n )
    dupd
    [ heap-data left-value ] 2keep
    [ heap-data right-value ] keep heap-compare
    [ right ] [ left ] if ;

: child ( m heap -- n )
    2dup right-bounds-check? [ drop left ] [ (child) ] if ;

: swap-down ( m heap -- )
    [ child ] 2keep heap-data exchange ;

DEFER: down-heap

: down-heap-continue? ( heap m heap -- m heap ? )
    [ heap-data nth ] 2keep child pick
    dupd [ heap-data nth swapd ] keep heap-compare ;
    
: (down-heap) ( m heap -- )
    2dup down-heap-continue? [
        -rot [ swap-down ] keep down-heap
    ] [
        3drop
    ] if ;

: down-heap ( m heap -- )
    2dup left-bounds-check? [ 2drop ] [ (down-heap) ] if ;

PRIVATE>

: heap-push ( obj heap -- )
    tuck heap-data push [ heap-data ] keep up-heap ;

: heap-push-all ( seq heap -- ) [ heap-push ] curry each ;

: heap-peek ( heap -- obj ) heap-data first ;

: heap-pop* ( heap -- )
    dup heap-data length 1 > [
        [ heap-data pop ] keep
        [ heap-data set-first ] keep
        0 swap down-heap
    ] [
        heap-data pop*
    ] if ;

: heap-pop ( heap -- obj ) [ heap-data first ] keep heap-pop* ;
: heap-empty? ( heap -- ? ) heap-data empty? ;
