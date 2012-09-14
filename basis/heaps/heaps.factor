! Copyright (C) 2007, 2008 Ryan Murphy, Doug Coleman,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences arrays assocs sequences.private
growable accessors math.order summary vectors fry combinators ;
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
    [ V{ } clone ] dip boa ; inline

TUPLE: entry value key heap index ;

: <entry> ( value key heap -- entry ) f entry boa ; inline

PRIVATE>

TUPLE: min-heap < heap ;

: <min-heap> ( -- min-heap ) min-heap <heap> ;

TUPLE: max-heap < heap ;

: <max-heap> ( -- max-heap ) max-heap <heap> ;

M: heap heap-empty? ( heap -- ? )
    data>> empty? ; inline

M: heap heap-size ( heap -- n )
    data>> length ;

<PRIVATE

: left ( n -- m ) 1 shift 1 + ; inline

: right ( n -- m ) 1 shift 2 + ; inline

: up ( n -- m ) 1 - 2/ ; inline

: data-nth ( n heap -- entry )
    data>> nth-unsafe ; inline

: left-value ( n heap -- entry )
    [ left ] dip data-nth ; inline

: right-value ( n heap -- entry )
    [ right ] dip data-nth ; inline

: data-set-nth ( entry n heap -- )
    [ [ >>index drop ] [ ] 2bi ] dip
    data>> set-nth-unsafe ; inline

: data-push ( entry heap -- n )
    dup heap-size [
        swap 2dup data>> ensure 2drop data-set-nth
    ] [
    ] bi ; inline

: data-first ( heap -- entry )
    data>> first ; inline

: data-exchange ( m n heap -- )
    [ '[ _ data-nth ] bi@ ]
    [ '[ _ data-set-nth ] bi@ ] 3bi ; inline

GENERIC: heap-compare ( entry1 entry2 heap -- ? )

: (heap-compare) ( entry1 entry2 heap -- <=> )
    drop [ key>> ] compare ; inline

M: min-heap heap-compare (heap-compare) +gt+ eq? ;

M: max-heap heap-compare (heap-compare) +lt+ eq? ;

: heap-bounds-check? ( m heap -- ? )
    heap-size >= ; inline

: left-bounds-check? ( m heap -- ? )
    [ left ] dip heap-bounds-check? ; inline

: right-bounds-check? ( m heap -- ? )
    [ right ] dip heap-bounds-check? ; inline

: continue? ( m n heap -- ? )
    [ data-nth nip ]
    [ nip data-nth ]
    [ 2nip ] 3tri heap-compare ; inline

DEFER: up-heap

: (up-heap) ( n heap -- )
    [ dup up ] dip
    3dup continue? [
        [ data-exchange ] [ up-heap ] 2bi
    ] [
        3drop
    ] if ; inline recursive

: up-heap ( n heap -- )
    over 0 > [ (up-heap) ] [ 2drop ] if ; inline recursive

: (child) ( m heap -- n )
    { [ drop ] [ left-value ] [ right-value ] [ nip ] } 2cleave
    heap-compare [ right ] [ left ] if ; inline

: child ( m heap -- n )
    2dup right-bounds-check?
    [ drop left ] [ (child) ] if ; inline

DEFER: down-heap

: (down-heap) ( m heap -- )
    [ drop ] [ child ] [ nip ] 2tri
    3dup continue? [
        3drop
    ] [
        [ data-exchange ] [ down-heap ] 2bi
    ] if ; inline recursive

: down-heap ( m heap -- )
    2dup left-bounds-check? [ 2drop ] [ (down-heap) ] if ; inline recursive

PRIVATE>

M: heap heap-push* ( value key heap -- entry )
    [ <entry> dup ] [ data-push ] [ ] tri up-heap ;

: heap-push ( value key heap -- ) heap-push* drop ;

: heap-push-all ( assoc heap -- )
    '[ swap _ heap-push ] assoc-each ;

: >entry< ( entry -- value key )
    [ value>> ] [ key>> ] bi ; inline

M: heap heap-peek ( heap -- value key )
    data-first >entry< ;

ERROR: bad-heap-delete ;

M: bad-heap-delete summary 
    drop "Invalid entry passed to heap-delete" ;

: entry>index ( entry heap -- n )
    over heap>> eq? [ bad-heap-delete ] unless
    index>> ;

M: heap heap-delete ( entry heap -- )
    [ entry>index ] [ ] bi
    2dup heap-size 1 - = [
        nip data>> pop*
    ] [
        [ nip data>> pop ]
        [ data-set-nth ]
        [ ] 2tri
        down-heap
    ] if ;

M: heap heap-pop* ( heap -- )
    [ data-first ] keep heap-delete ;

M: heap heap-pop ( heap -- value key )
    [ data-first ] keep
    [ heap-delete ] [ drop ] 2bi >entry< ;

: heap-pop-all ( heap -- alist )
    [ dup heap-empty? not ]
    [ dup heap-pop swap 2array ]
    produce nip ;

: slurp-heap ( heap quot: ( elt -- ) -- )
    over heap-empty? [ 2drop ] [
        [ [ heap-pop drop ] dip call ] [ slurp-heap ] 2bi
    ] if ; inline recursive
