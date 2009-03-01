! Copyright (C) 2007, 2008 Ryan Murphy, Doug Coleman,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences arrays assocs sequences.private
growable accessors math.order summary ;
IN: heaps

GENERIC: heap-push* ( value key heap -- entry )
GENERIC: heap-peek ( heap -- value key )
GENERIC: heap-pop* ( heap -- )
GENERIC: heap-pop ( heap -- value key )
GENERIC: heap-delete ( entry heap -- )
GENERIC: heap-empty? ( heap -- ? )
GENERIC: heap-size ( heap -- n )

<PRIVATE

TUPLE: heap data ;

: <heap> ( class -- heap )
    [ V{ } clone ] dip boa ; inline

TUPLE: entry value key heap index ;

: <entry> ( value key heap -- entry ) f entry boa ;

PRIVATE>

TUPLE: min-heap < heap ;

: <min-heap> ( -- min-heap ) min-heap <heap> ;

TUPLE: max-heap < heap ;

: <max-heap> ( -- max-heap ) max-heap <heap> ;

M: heap heap-empty? ( heap -- ? )
    data>> empty? ;

M: heap heap-size ( heap -- n )
    data>> length ;

<PRIVATE

: left ( n -- m ) 1 shift 1 + ; inline

: right ( n -- m ) 1 shift 2 + ; inline

: up ( n -- m ) 1- 2/ ; inline

: data-nth ( n heap -- entry )
    data>> nth-unsafe ; inline

: up-value ( n heap -- entry )
    [ up ] dip data-nth ; inline

: left-value ( n heap -- entry )
    [ left ] dip data-nth ; inline

: right-value ( n heap -- entry )
    [ right ] dip data-nth ; inline

: data-set-nth ( entry n heap -- )
    [ [ >>index drop ] 2keep ] dip
    data>> set-nth-unsafe ; inline

: data-push ( entry heap -- n )
    dup heap-size [
        swap 2dup data>> ensure 2drop data-set-nth
    ] keep ; inline

: data-pop ( heap -- entry )
    data>> pop ; inline

: data-pop* ( heap -- )
    data>> pop* ; inline

: data-peek ( heap -- entry )
    data>> peek ; inline

: data-first ( heap -- entry )
    data>> first ; inline

: data-exchange ( m n heap -- )
    [ tuck data-nth [ data-nth ] dip ] 3keep
    tuck [ data-set-nth ] 2dip data-set-nth ; inline

GENERIC: heap-compare ( pair1 pair2 heap -- ? )

: (heap-compare) ( pair1 pair2 heap -- <=> )
    drop [ key>> ] compare ; inline

M: min-heap heap-compare (heap-compare) +gt+ eq? ;

M: max-heap heap-compare (heap-compare) +lt+ eq? ;

: heap-bounds-check? ( m heap -- ? )
    heap-size >= ; inline

: left-bounds-check? ( m heap -- ? )
    [ left ] dip heap-bounds-check? ; inline

: right-bounds-check? ( m heap -- ? )
    [ right ] dip heap-bounds-check? ; inline

: continue? ( m up[m] heap -- ? )
    [ data-nth swap ] keep [ data-nth ] keep
    heap-compare ; inline

DEFER: up-heap

: (up-heap) ( n heap -- )
    [ dup up ] dip
    3dup continue? [
        [ data-exchange ] 2keep up-heap
    ] [
        3drop
    ] if ;

: up-heap ( n heap -- )
    over 0 > [ (up-heap) ] [ 2drop ] if ;

: (child) ( m heap -- n )
    2dup right-value
    [ 2dup left-value ] dip
    rot heap-compare
    [ right ] [ left ] if ;

: child ( m heap -- n )
    2dup right-bounds-check?
    [ drop left ] [ (child) ] if ;

: swap-down ( m heap -- )
    [ child ] 2keep data-exchange ;

DEFER: down-heap

: (down-heap) ( m heap -- )
    [ child ] 2keep swapd
    3dup continue? [
        3drop
    ] [
        [ data-exchange ] 2keep down-heap
    ] if ;

: down-heap ( m heap -- )
    2dup left-bounds-check? [ 2drop ] [ (down-heap) ] if ;

PRIVATE>

M: heap heap-push* ( value key heap -- entry )
    [ <entry> dup ] keep [ data-push ] keep up-heap ;

: heap-push ( value key heap -- ) heap-push* drop ;

: heap-push-all ( assoc heap -- )
    [ swapd heap-push ] curry assoc-each ;

: >entry< ( entry -- key value )
    [ value>> ] [ key>> ] bi ;

M: heap heap-peek ( heap -- value key )
    data-first >entry< ;

ERROR: bad-heap-delete ;

M: bad-heap-delete summary 
    drop "Invalid entry passed to heap-delete" ;
    
: entry>index ( entry heap -- n )
    over heap>> eq? [ bad-heap-delete ] unless
    index>> ;

M: heap heap-delete ( entry heap -- )
    [ entry>index ] keep
    2dup heap-size 1- = [
        nip data-pop*
    ] [
        [ nip data-pop ] 2keep
        [ data-set-nth ] 2keep
        down-heap
    ] if ;

M: heap heap-pop* ( heap -- )
    dup data-first swap heap-delete ;

M: heap heap-pop ( heap -- value key )
    dup data-first [ swap heap-delete ] keep >entry< ;

: heap-pop-all ( heap -- alist )
    [ dup heap-empty? not ]
    [ dup heap-pop swap 2array ]
    produce nip ;

: slurp-heap ( heap quot: ( elt -- ) -- )
    over heap-empty? [ 2drop ] [
        [ [ heap-pop drop ] dip call ] [ slurp-heap ] 2bi
    ] if ; inline recursive
