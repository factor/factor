! Copyright (C) 2007 Ryan Murphy, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences arrays assocs ;
IN: heaps

MIXIN: priority-queue

GENERIC: heap-push ( value key heap -- )
GENERIC: heap-peek ( heap -- value key )
GENERIC: heap-pop* ( heap -- )
GENERIC: heap-pop ( heap -- value key )
GENERIC: heap-delete ( key heap -- )
GENERIC: heap-delete* ( key heap -- old ? )
GENERIC: heap-empty? ( heap -- ? )
GENERIC: heap-size ( heap -- n )

<PRIVATE

TUPLE: heap data ;

: <heap> ( class -- heap )
    >r V{ } clone heap construct-boa r>
    construct-delegate ; inline

TUPLE: entry value key index ;

: <entry> f entry construct-boa ;

PRIVATE>

TUPLE: min-heap ;

: <min-heap> ( -- min-heap ) min-heap <heap> ;

TUPLE: max-heap ;

: <max-heap> ( -- max-heap ) max-heap <heap> ;

INSTANCE: min-heap priority-queue
INSTANCE: max-heap priority-queue

M: priority-queue heap-empty? ( heap -- ? )
    heap-data empty? ;

M: priority-queue heap-size ( heap -- n )
    heap-data length ;

<PRIVATE

: left ( n -- m ) 1 shift 1+ ; inline

: right ( n -- m ) 1 shift 2 + ; inline

: up ( n -- m ) 1- 2/ ; inline

: data-nth ( n heap -- obj )
    heap-data nth ; inline

: up-value ( n heap -- obj )
    >r up r> data-nth ; inline

: left-value ( n heap -- obj )
    >r left r> data-nth ; inline

: right-value ( n heap -- obj )
    >r right r> data-nth ; inline

: data-push ( obj heap -- )
    heap-data push ; inline

: data-pop ( heap -- obj )
    heap-data pop ; inline

: data-pop* ( heap -- obj )
    heap-data pop* ; inline

: data-peek ( heap -- obj )
    heap-data peek ; inline

: data-first ( heap -- obj )
    heap-data first ; inline

: data-set-first ( obj heap -- )
    heap-data set-first ; inline

: data-exchange ( m n heap -- )
    heap-data exchange ; inline

GENERIC: heap-compare ( pair1 pair2 heap -- ? )

: (heap-compare) drop [ entry-key ] compare 0 ; inline

M: min-heap heap-compare (heap-compare) > ;

M: max-heap heap-compare (heap-compare) < ;

: heap-bounds-check? ( m heap -- ? )
    heap-size >= ; inline

: left-bounds-check? ( m heap -- ? )
    >r left r> heap-bounds-check? ; inline

: right-bounds-check? ( m heap -- ? )
    >r right r> heap-bounds-check? ; inline

: up-heap-continue? ( m up[m] heap -- ? )
    [ data-nth swap ] keep [ data-nth ] keep
    heap-compare ; inline

: up-heap ( n heap -- )
    >r dup up r>
    3dup up-heap-continue? [
        [ data-exchange ] 2keep up-heap
    ] [
        2drop
    ] if ;

: (child) ( m heap -- n )
    2dup right-value
    >r 2dup left-value r>
    rot heap-compare
    [ right ] [ left ] if ;

: child ( m heap -- n )
    2dup right-bounds-check? [ drop left ] [ (child) ] if ;

: swap-down ( m heap -- )
    [ child ] 2keep data-exchange ;

DEFER: down-heap

: (down-heap) ( m heap -- )
    2dup [ data-nth ] 2keep child pick
    dupd [ data-nth swapd ] keep heap-compare [
        -rot [ swap-down ] keep down-heap
    ] [
        3drop
    ] if ;

: down-heap ( m heap -- )
    2dup left-bounds-check? [ 2drop ] [ (down-heap) ] if ;

PRIVATE>

M: priority-queue heap-push ( value key heap -- )
    [ >r <heap-entry> r> data-push ] keep up-heap ;

: heap-push-all ( assoc heap -- )
    [ swapd heap-push ] curry assoc-each ;

M: priority-queue heap-peek ( heap -- value key )
    data-first { entry-value entry-key } get-slots ;

M: priority-queue heap-pop* ( heap -- )
    dup heap-size 1 > [
        [ heap-pop ] keep
        [ set-data-first ] keep
        0 swap down-heap
    ] [
        data-pop*
    ] if ;

M: priority-queue heap-pop ( heap -- value key )
    dup heap-peek rot heap-pop* ;
