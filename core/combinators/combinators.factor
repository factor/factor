! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: combinators
USING: arrays sequences sequences.private math.private
kernel kernel.private math assocs quotations vectors ;

<PRIVATE

: dispatch ( n array -- ) array-nth (call) ;

PRIVATE>

TUPLE: no-cond ;

: no-cond ( -- * ) \ no-cond construct-empty throw ;

: cond ( assoc -- )
    [ first call ] find nip dup [ second call ] [ no-cond ] if ;

TUPLE: no-case ;

: no-case ( -- * ) \ no-case construct-empty throw ;

: case ( obj assoc -- )
    [ dup array? [ dupd first = ] [ quotation? ] if ] find nip
    {
        { [ dup array? ] [ nip second call ] }
        { [ dup quotation? ] [ call ] }
        { [ dup not ] [ no-case ] }
    } cond ;

: with-datastack ( stack quot -- newstack )
    datastack >r
    >r >array set-datastack r> call
    datastack r> swap add set-datastack 2nip ; inline

: recursive-hashcode ( n obj quot -- code )
    pick 0 <= [ 3drop 0 ] [ rot 1- -rot call ] if ; inline

M: sequence hashcode*
    [
        0 -rot [ hashcode* bitxor ] curry* each
    ] recursive-hashcode ;

: alist>quot ( default assoc -- quot )
    [ rot \ if 3array append [ ] like ] assoc-each ;

: cond>quot ( assoc -- quot )
    reverse [ no-cond ] swap alist>quot ;

: case>quot ( default assoc -- quot )
    [ >r [ dupd = ] curry r> \ drop add* ] assoc-map
    alist>quot ;

: (distribute-buckets) ( buckets pair keys -- )
    dup t eq? [
        drop [ swap push-new ] curry each
    ] [
        [
            >r 2dup r> hashcode pick length rem rot nth push-new
        ] each 2drop
    ] if ;

: <buckets> ( initial length -- array )
    next-power-of-2 swap [ nip clone ] curry map ;

: distribute-buckets ( assoc initial quot -- buckets )
    swap rot [ length <buckets> ] keep
    [ >r 2dup r> dup first roll call (distribute-buckets) ] each
    nip ; inline

: hash-case-table ( default assoc -- array )
    V{ } [ 1array ] distribute-buckets
    [ case>quot ] curry* map ;

: hash-dispatch-quot ( table -- quot )
    [ length 1- [ fixnum-bitand ] curry ] keep
    [ dispatch ] curry append ;

: hash-case>quot ( default assoc -- quot )
    dup empty? [
        drop
    ] [
        hash-case-table hash-dispatch-quot
        [ dup hashcode >fixnum ] swap append
    ] if ;
