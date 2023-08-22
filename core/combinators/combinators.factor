! Copyright (C) 2006, 2010 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel kernel.private math
math.order math.private quotations sequences sequences.private
sets sorting words ;
IN: combinators

! Most of these combinators have compile-time expansions in
! the optimizing compiler. See stack-checker.transforms and
! compiler.tree.propagation.call-effect

<PRIVATE

: call-effect-unsafe ( quot effect -- ) drop call ;

: execute-effect-unsafe ( word effect -- ) drop execute ;

M: object throw
    ERROR-HANDLER-QUOT special-object [ die ] or
    ( error -- * ) call-effect-unsafe ;

PRIVATE>

ERROR: wrong-values quot call-site ;

! We can't USE: effects here so we forward reference slots instead
SLOT: in
SLOT: out
SLOT: terminated?

: call-effect ( quot effect -- )
    ! Don't use fancy combinators here, since this word always
    ! runs unoptimized
    2dup [
        [ [ get-datastack ] dip dip ] dip
        dup terminated?>> [ 2drop f ] [
            dup in>> length swap out>> length
            check-datastack
        ] if
    ] 2dip rot
    [ 2drop ] [ wrong-values ] if ;

: execute-effect ( word effect -- )
    [ [ execute ] curry ] dip call-effect ;

! cleave
: cleave ( x seq -- )
    [ call ] with each ;

: cleave>quot ( seq -- quot )
    [ [ keep ] curry ] map concat
    [ drop ] [ ] append-as ;

! 2cleave
: 2cleave ( x y seq -- )
    [ 2keep ] each 2drop ;

: 2cleave>quot ( seq -- quot )
    [ [ 2keep ] curry ] map concat
    [ 2drop ] [ ] append-as ;

! 3cleave
: 3cleave ( x y z seq -- )
    [ 3keep ] each 3drop ;

: 3cleave>quot ( seq -- quot )
    [ [ 3keep ] curry ] map concat
    [ 3drop ] [ ] append-as ;

! 4cleave
: 4cleave ( w x y z seq -- )
    [ 4keep ] each 4drop ;

: 4cleave>quot ( seq -- quot )
    [ [ 4keep ] curry ] map concat
    [ 4drop ] [ ] append-as ;

! spread
: shallow-spread>quot ( seq -- quot )
    [ ] [ [ dup empty? [ [ dip ] curry ] unless ] dip append ] reduce ;

: deep-spread>quot ( seq -- quot )
    [ ] [ [ [ dip ] curry ] dip append ] reduce ;

: spread ( objs... seq -- )
    deep-spread>quot call ;

! cond
ERROR: no-cond ;

: cond ( assoc -- )
    [ dup callable? [ drop t ] [ first call ] if ] find nip
    [ dup callable? [ call ] [ second call ] if ]
    [ no-cond ] if* ;

: alist>quot ( default assoc -- quot )
    [ rot \ if 3array [ ] append-as ] assoc-each ;

: cond>quot ( assoc -- quot )
    [ dup pair? [ [ t ] swap 2array ] unless ] map
    reverse! [ no-cond ] swap alist>quot ;

! case
ERROR: no-case object ;

: case-find ( obj assoc -- obj' )
    [
        dup array? [
            dupd first dup word? [
                execute
            ] [
                dup wrapper? [ wrapped>> ] when
            ] if =
        ] [ callable? ] if
    ] find nip ;

\ case-find t "no-compile" set-word-prop

: case ( obj assoc -- )
    case-find {
        { [ dup array? ] [ nip second call ] }
        { [ dup callable? ] [ call ] }
        { [ dup not ] [ drop no-case ] }
    } cond ;

: linear-case-quot ( default assoc -- quot )
    [
        [ 1quotation \ dup prefix \ = suffix ]
        [ \ drop prefix ] bi*
    ] assoc-map reverse! alist>quot ;

<PRIVATE

: (distribute-buckets) ( buckets pair keys -- )
    dup t eq? [
        drop [ swap adjoin ] curry each
    ] [
        [
            [ 2dup ] dip hashcode pick length rem rot nth adjoin
        ] each 2drop
    ] if ;

: <buckets> ( initial length -- array )
    next-power-of-2 <iota> swap [ nip clone ] curry map ;

: distribute-buckets ( alist initial quot -- buckets )
    swapd [ [ dup first ] dip call 2array ] curry map
    [ length <buckets> dup ] keep
    [ first2 (distribute-buckets) ] with each ; inline

: hash-case-table ( default assoc -- array )
    V{ } [ 1array ] distribute-buckets [
        [ [ literalize ] dip ] assoc-map linear-case-quot
    ] with map ;

: hash-dispatch-quot ( table -- quot )
    [ length 1 - [ fixnum-bitand ] curry ] keep
    [ dispatch ] curry append ;

: hash-case-quot ( default assoc -- quot )
    hash-case-table hash-dispatch-quot
    [ dup hashcode >fixnum ] prepend ;

: contiguous-range? ( keys -- ? )
    dup [ fixnum? ] all? [
        dup all-unique? [
            [ length ] [ supremum ] [ infimum ] tri - - 1 =
        ] [ drop f ] if
    ] [ drop f ] if ;

: dispatch-case-quot ( default assoc -- quot )
    swap [
        [ keys [ infimum ] [ supremum ] bi over ]
        [ sort-keys values [ >quotation ] map ] bi
    ] dip dup '[
        dup integer? [
            integer>fixnum-strict dup _ _ between? [
                _ - _ dispatch
            ] _ if
        ] _ if
    ] ;

PRIVATE>

: case>quot ( default assoc -- quot )
    dup keys {
        { [ dup empty? ] [ 2drop ] }
        { [ dup [ length 4 <= ] [ [ word? ] any? ] bi or ] [ drop linear-case-quot ] }
        { [ dup contiguous-range? ] [ drop dispatch-case-quot ] }
        { [ dup [ wrapper? ] none? ] [ drop hash-case-quot ] }
        { [ dup [ wrapper? ] all? ] [ drop [ [ wrapped>> ] dip ] assoc-map hash-case-quot ] }
        [ drop linear-case-quot ]
    } cond ;

: to-fixed-point ( ... object quot: ( ... object(n) -- ... object(n+1) ) -- ... object(n) )
    [ keep over = ] keep [ to-fixed-point ] curry unless ; inline recursive
