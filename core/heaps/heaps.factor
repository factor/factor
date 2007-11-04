! Copyright (C) 2007 Ryan Murphy, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: heaps

<PRIVATE
TUPLE: heap data ;

: <heap> ( -- obj )
    V{ } clone heap construct-boa ;
PRIVATE>

TUPLE: min-heap ;

: <min-heap> ( -- obj )
    <heap> min-heap construct-delegate ;

TUPLE: max-heap ;

: <max-heap> ( -- obj )
    <heap> max-heap construct-delegate ;

<PRIVATE
: left ( n -- m ) 2 * 1+ ;
: right ( n -- m ) 2 * 2 + ;
: up ( n -- m ) 1- 2 /i ;
: left-value ( n heap -- obj ) >r left r> nth ;
: right-value ( n heap -- obj ) >r right r> nth ;
: up-value ( n vec -- obj ) >r up r> nth ;
: swap-up ( n vec -- ) >r dup up r> exchange ;
: last-index ( vec -- n ) length 1- ;

GENERIC: heap-compare ( obj1 obj2 heap -- ? )

M: min-heap heap-compare drop <=> 0 > ;
M: max-heap heap-compare drop <=> 0 < ;

: left-bounds-check? ( m heap -- ? )
    >r left r> heap-data length >= ;

: right-bounds-check? ( m heap -- ? )
    >r right r> heap-data length >= ;

: (up-heap) ( vec heap -- )
    [
        >r [ last-index ] keep [ up-value ] keep peek r> heap-compare
    ] 2keep rot [
        >r dup last-index
        [ over swap-up ] keep
        up 1+ head-slice
        r> (up-heap)
    ] [
        2drop
    ] if ;

: up-heap ( heap -- )
    [ heap-data ] keep (up-heap) ;

: child ( m heap -- n )
    2dup right-bounds-check? [
        drop left
    ] [
        dupd
        [ heap-data left-value ] 2keep
        [ heap-data right-value ] keep heap-compare [
            right
        ] [
            left
        ] if
    ] if ;

: swap-down ( m heap -- )
    [ child ] 2keep heap-data exchange ;

DEFER: down-heap

: (down-heap) ( m heap -- )
    2dup [ heap-data nth ] 2keep child pick
    dupd [ heap-data nth swapd ] keep
    heap-compare [
        -rot [ swap-down ] keep down-heap
    ] [
        3drop
    ] if ;

: down-heap ( m heap -- )
    2dup left-bounds-check? [ 2drop ] [ (down-heap) ] if ;

PRIVATE>

: push-heap ( obj heap -- )
    tuck heap-data push up-heap ;

: push-heap* ( seq heap -- )
    swap [ swap push-heap ] curry* each ;

: peek-heap ( heap -- obj )
    heap-data first ;

: pop-heap* ( heap -- )
    dup heap-data length 1 > [
        [ heap-data pop 0 ] keep
        [ heap-data set-nth ] keep
        >r 0 r> down-heap
    ] [
        heap-data pop*
    ] if ;

: pop-heap ( heap -- fist ) [ heap-data first ] keep pop-heap* ;

: heap-empty? ( heap -- ? )
    heap-data empty? ;
