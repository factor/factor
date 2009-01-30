! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays sequences sequences.private math.private
kernel kernel.private math assocs quotations vectors
hashtables sorting words sets math.order make ;
IN: combinators

! cleave
: cleave ( x seq -- )
    [ call ] with each ;

: cleave>quot ( seq -- quot )
    [ [ keep ] curry ] map concat [ drop ] append [ ] like ;

! 2cleave
: 2cleave ( x y seq -- )
    [ 2keep ] each 2drop ;

: 2cleave>quot ( seq -- quot )
    [ [ 2keep ] curry ] map concat [ 2drop ] append [ ] like ;

! 3cleave
: 3cleave ( x y z seq -- )
    [ 3keep ] each 3drop ;

: 3cleave>quot ( seq -- quot )
    [ [ 3keep ] curry ] map concat [ 3drop ] append [ ] like ;

! spread
: spread>quot ( seq -- quot )
    [ ] [ [ dup empty? [ [ dip ] curry ] unless ] dip append ] reduce ;

: spread ( objs... seq -- )
    spread>quot call ;

! cond
ERROR: no-cond ;

: cond ( assoc -- )
    [ dup callable? [ drop t ] [ first call ] if ] find nip
    [ dup callable? [ call ] [ second call ] if ]
    [ no-cond ] if* ;

: alist>quot ( default assoc -- quot )
    [ rot \ if 3array append [ ] like ] assoc-each ;

: cond>quot ( assoc -- quot )
    [ dup pair? [ [ t ] swap 2array ] unless ] map
    reverse [ no-cond ] swap alist>quot ;

! case
ERROR: no-case ;

: case-find ( obj assoc -- obj' )
    [
        dup array? [
            dupd first dup word? [
                execute
            ] [
                dup wrapper? [ wrapped>> ] when
            ] if =
        ] [ quotation? ] if
    ] find nip ;

: case ( obj assoc -- )
    case-find {
        { [ dup array? ] [ nip second call ] }
        { [ dup quotation? ] [ call ] }
        { [ dup not ] [ no-case ] }
    } cond ;

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
            [ 2dup ] dip hashcode pick length rem rot nth adjoin
        ] each 2drop
    ] if ;

: <buckets> ( initial length -- array )
    next-power-of-2 swap [ nip clone ] curry map ;

: distribute-buckets ( alist initial quot -- buckets )
    swapd [ [ dup first ] dip call 2array ] curry map
    [ length <buckets> dup ] keep
    [ first2 (distribute-buckets) ] with each ; inline

: hash-case-table ( default assoc -- array )
    V{ } [ 1array ] distribute-buckets
    [ [ [ literalize ] dip ] assoc-map linear-case-quot ] with map ;

: hash-dispatch-quot ( table -- quot )
    [ length 1- [ fixnum-bitand ] curry ] keep
    [ dispatch ] curry append ;

: hash-case-quot ( default assoc -- quot )
    hash-case-table hash-dispatch-quot
    [ dup hashcode >fixnum ] prepend ;

: contiguous-range? ( keys -- ? )
    dup [ fixnum? ] all? [
        dup all-unique? [
            [ prune length ]
            [ [ supremum ] [ infimum ] bi - ]
            bi - 1 =
        ] [ drop f ] if
    ] [ drop f ] if ;

: dispatch-case-quot ( default assoc -- quot )
    [
        \ dup ,
        dup keys [ infimum , ] [ supremum , ] bi \ between? ,
        [
            dup keys infimum , [ - >fixnum ] %
            sort-keys values [ >quotation ] map ,
            \ dispatch ,
        ] [ ] make , , \ if ,
    ] [ ] make ;

: case>quot ( default assoc -- quot )
    dup keys {
        { [ dup empty? ] [ 2drop ] }
        { [ dup [ length 4 <= ] [ [ word? ] any? ] bi or ] [ drop linear-case-quot ] }
        { [ dup contiguous-range? ] [ drop dispatch-case-quot ] }
        { [ dup [ wrapper? ] any? not ] [ drop hash-case-quot ] }
        { [ dup [ wrapper? ] all? ] [ drop [ [ wrapped>> ] dip ] assoc-map hash-case-quot ] }
        [ drop linear-case-quot ]
    } cond ;

! recursive-hashcode
: recursive-hashcode ( n obj quot -- code )
    pick 0 <= [ 3drop 0 ] [ [ 1- ] 2dip call ] if ; inline

! These go here, not in sequences and hashtables, since those
! two cannot depend on us
M: sequence hashcode* [ sequence-hashcode ] recursive-hashcode ;

M: reversed hashcode* [ sequence-hashcode ] recursive-hashcode ;

M: slice hashcode* [ sequence-hashcode ] recursive-hashcode ;

M: hashtable hashcode*
    [
        dup assoc-size 1 eq?
        [ assoc-hashcode ] [ nip assoc-size ] if
    ] recursive-hashcode ;
