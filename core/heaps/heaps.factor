! Copyright (C) 2007 Ryan Murphy, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences arrays assocs ;
IN: heaps

MIXIN: priority-queue

GENERIC: heap-push ( value key heap -- )
GENERIC: heap-push-all ( assoc heap -- )
GENERIC: heap-peek ( heap -- value key )
GENERIC: heap-pop* ( heap -- )
GENERIC: heap-pop ( heap -- value key )
GENERIC: heap-delete ( key heap -- )
GENERIC: heap-delete* ( key heap -- old ? )
GENERIC: heap-empty? ( heap -- ? )
GENERIC: heap-length ( heap -- n )
GENERIC# heap-pop-while 2 ( heap pred quot -- )

<PRIVATE
TUPLE: heap data ;

: <heap> ( class -- heap )
    >r V{ } clone heap construct-boa r>
    construct-delegate ; inline
PRIVATE>

TUPLE: min-heap ;

: <min-heap> ( -- min-heap ) min-heap <heap> ;

TUPLE: max-heap ;

: <max-heap> ( -- max-heap ) max-heap <heap> ;

INSTANCE: min-heap priority-queue
INSTANCE: max-heap priority-queue

<PRIVATE
: left ( n -- m ) 2 * 1+ ; inline
: right ( n -- m ) 2 * 2 + ; inline
: up ( n -- m ) 1- 2 /i ; inline
: left-value ( n heap -- obj ) >r left r> nth ; inline
: right-value ( n heap -- obj ) >r right r> nth ; inline
: up-value ( n vec -- obj ) >r up r> nth ; inline
: swap-up ( n vec -- ) >r dup up r> exchange ; inline
: last-index ( vec -- n ) length 1- ; inline

GENERIC: heap-compare ( pair1 pair2 heap -- ? )
: (heap-compare) drop [ first ] compare 0 ; inline
M: min-heap heap-compare (heap-compare) > ;
M: max-heap heap-compare (heap-compare) < ;

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

M: priority-queue heap-push ( value key heap -- )
    >r swap 2array r>
    [ heap-data push ] keep
    [ heap-data ] keep
    up-heap ;

M: priority-queue heap-push-all ( assoc heap -- )
    [ swapd heap-push ] curry assoc-each ;

M: priority-queue heap-peek ( heap -- value key )
    heap-data first first2 swap ;

M: priority-queue heap-pop* ( heap -- )
    dup heap-data length 1 > [
        [ heap-data pop ] keep
        [ heap-data set-first ] keep
        0 swap down-heap
    ] [
        heap-data pop*
    ] if ;

M: priority-queue heap-pop ( heap -- value key ) dup heap-peek rot heap-pop* ;

M: priority-queue heap-empty? ( heap -- ? ) heap-data empty? ;

M: priority-queue heap-length ( heap -- n ) heap-data length ;

: (heap-pop-while) ( heap pred quot -- )
    pick heap-empty? [
        3drop
    ] [
        [ >r >r dup heap-peek r> call r> [ drop f ] if ] 3keep
        roll [ (heap-pop-while) ] [ 3drop ] if
    ] if ;

M: priority-queue heap-pop-while ( heap pred quot -- )
    [ heap-pop ] swap [ t ] 3compose (heap-pop-while) ;
