! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences sequences.private math.private
kernel kernel.private math assocs quotations vectors
hashtables sorting words sets math.order ;
IN: combinators

: cleave ( x seq -- )
    [ call ] with each ;

: cleave>quot ( seq -- quot )
    [ [ keep ] curry ] map concat [ drop ] append [ ] like ;

: 2cleave ( x seq -- )
    [ 2keep ] each 2drop ;

: 2cleave>quot ( seq -- quot )
    [ [ 2keep ] curry ] map concat [ 2drop ] append [ ] like ;

: 3cleave ( x seq -- )
    [ 3keep ] each 3drop ;

: 3cleave>quot ( seq -- quot )
    [ [ 3keep ] curry ] map concat [ 3drop ] append [ ] like ;

: spread>quot ( seq -- quot )
    [ length [ >r ] <repetition> concat ]
    [ [ [ r> ] prepend ] map concat ] bi
    append [ ] like ;

: spread ( objs... seq -- )
    spread>quot call ;

ERROR: no-cond ;

: cond ( assoc -- )
    [ dup callable? [ drop t ] [ first call ] if ] find nip
    [ dup callable? [ call ] [ second call ] if ]
    [ no-cond ] if* ;

ERROR: no-case ;
: case-find ( obj assoc -- obj' )
    [
        dup array? [
            dupd first dup word? [
                execute
            ] [
                dup wrapper? [ wrapped ] when
            ] if =
        ] [ quotation? ] if
    ] find nip ;

: case ( obj assoc -- )
    case-find {
        { [ dup array? ] [ nip second call ] }
        { [ dup quotation? ] [ call ] }
        { [ dup not ] [ no-case ] }
    } cond ;

: with-datastack ( stack quot -- newstack )
    datastack >r
    >r >array set-datastack r> call
    datastack r> swap suffix set-datastack 2nip ; inline

: recursive-hashcode ( n obj quot -- code )
    pick 0 <= [ 3drop 0 ] [ rot 1- -rot call ] if ; inline

! These go here, not in sequences and hashtables, since those
! two depend on combinators
M: sequence hashcode*
    [ sequence-hashcode ] recursive-hashcode ;

M: reversed hashcode* [ sequence-hashcode ] recursive-hashcode ;

M: slice hashcode* [ sequence-hashcode ] recursive-hashcode ;

M: hashtable hashcode*
    [
        dup assoc-size 1 number=
        [ assoc-hashcode ] [ nip assoc-size ] if
    ] recursive-hashcode ;

: alist>quot ( default assoc -- quot )
    [ rot \ if 3array append [ ] like ] assoc-each ;

: cond>quot ( assoc -- quot )
    [ dup callable? [ [ t ] swap 2array ] when ] map
    reverse [ no-cond ] swap alist>quot ;

: linear-case-quot ( default assoc -- quot )
    [
        [ 1quotation \ dup prefix \ = suffix ]
        [ \ drop prefix ] bi*
    ] assoc-map alist>quot ;

: (distribute-buckets) ( buckets pair keys -- )
    dup t eq? [
        drop [ swap adjoin ] curry each
    ] [
        [
            >r 2dup r> hashcode pick length rem rot nth adjoin
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
        dup length 4 <=
        over keys [ [ word? ] [ wrapper? ] bi or ] contains? or
        [
            linear-case-quot
        ] [
            dup keys contiguous-range? [
                dispatch-case-quot
            ] [
                2drop hash-case-quot
            ] if
        ] if
    ] if ;
