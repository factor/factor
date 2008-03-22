! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: combinators
USING: arrays sequences sequences.private math.private
kernel kernel.private math assocs quotations vectors
hashtables sorting ;

ERROR: no-cond ;

: cond ( assoc -- )
    [ first call ] find nip dup [ second call ] [ no-cond ] if ;

ERROR: no-case ;

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

! These go here, not in sequences and hashtables, since those
! two depend on combinators
M: sequence hashcode*
    [ sequence-hashcode ] recursive-hashcode ;

M: hashtable hashcode*
    [
        dup assoc-size 1 number=
        [ assoc-hashcode ] [ nip assoc-size ] if
    ] recursive-hashcode ;

: alist>quot ( default assoc -- quot )
    [ rot \ if 3array append [ ] like ] assoc-each ;

: cond>quot ( assoc -- quot )
    reverse [ no-cond ] swap alist>quot ;

: linear-case-quot ( default assoc -- quot )
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
    spin [ length <buckets> ] keep
    [ >r 2dup r> dup first roll call (distribute-buckets) ] each
    nip ; inline

: hash-case-table ( default assoc -- array )
    V{ } [ 1array ] distribute-buckets
    [ linear-case-quot ] with map ;

: hash-dispatch-quot ( table -- quot )
    [ length 1- [ fixnum-bitand ] curry ] keep
    [ dispatch ] curry append ;

: hash-case-quot ( default assoc -- quot )
    hash-case-table hash-dispatch-quot
    [ dup hashcode >fixnum ] prepend ;

: contiguous-range? ( keys -- from to ? )
    dup [ fixnum? ] all? [
        dup all-unique? [
            dup infimum over supremum
            [ - swap prune length + 1 = ] 2keep rot
        ] [
            drop f f f
        ] if
    ] [
        drop f f f
    ] if ;

: dispatch-case ( value from to default array -- )
    >r >r 3dup between? [
        drop - >fixnum r> drop r> dispatch
    ] [
        2drop r> call r> drop
    ] if ; inline

: dispatch-case-quot ( default assoc from to -- quot )
    -roll -roll sort-keys values [ >quotation ] map
    [ dispatch-case ] 2curry 2curry ;

: case>quot ( default assoc -- quot )
    dup empty? [
        drop
    ] [
        dup length 4 <= [
            linear-case-quot
        ] [
            dup keys contiguous-range? [
                dispatch-case-quot
            ] [
                2drop hash-case-quot
            ] if
        ] if
    ] if ;
