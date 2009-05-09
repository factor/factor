! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math math.partial-dispatch namespaces sequences sets
accessors assocs words kernel memoize fry combinators
combinators.short-circuit
compiler.tree
compiler.tree.combinators
compiler.tree.def-use
compiler.tree.def-use.simplified
compiler.tree.late-optimizations ;
IN: compiler.tree.modular-arithmetic

! This is a late-stage optimization.
! See the comment in compiler.tree.late-optimizations.

! Modular arithmetic optimization pass.
!
! { integer integer } declare + >fixnum
!    ==>
!        [ >fixnum ] bi@ fixnum+fast

{ + - * bitand bitor bitxor } [
    [
        t "modular-arithmetic" set-word-prop
    ] each-integer-derived-op
] each

{ bitand bitor bitxor bitnot }
[ t "modular-arithmetic" set-word-prop ] each

SYMBOL: modularize-values

: modular-value? ( value -- ? )
    modularize-values get key? ;

: modularize-value ( value -- ) modularize-values get conjoin ;

GENERIC: maybe-modularize* ( value node -- )

: maybe-modularize ( value -- )
    actually-defined-by [ value>> ] [ node>> ] bi
    over actually-used-by length 1 = [
        maybe-modularize*
    ] [ 2drop ] if ;

M: #call maybe-modularize*
    dup word>> "modular-arithmetic" word-prop [
        [ modularize-value ]
        [ in-d>> [ maybe-modularize ] each ] bi*
    ] [ 2drop ] if ;

M: node maybe-modularize* 2drop ;

GENERIC: compute-modularized-values* ( node -- )

M: #call compute-modularized-values*
    dup word>> \ >fixnum eq?
    [ in-d>> first maybe-modularize ] [ drop ] if ;

M: node compute-modularized-values* drop ;

: compute-modularized-values ( nodes -- )
    [ compute-modularized-values* ] each-node ;

GENERIC: optimize-modular-arithmetic* ( node -- nodes )

: redundant->fixnum? ( #call -- ? )
    in-d>> first actually-defined-by value>> modular-value? ;

: optimize->fixnum ( #call -- nodes )
    dup redundant->fixnum? [ drop f ] when ;

: optimize->integer ( #call -- nodes )
    dup out-d>> first actually-used-by dup length 1 = [
        first node>> { [ #call? ] [ word>> \ >fixnum eq? ] } 1&&
        [ drop { } ] when
    ] [ drop ] if ;

MEMO: fixnum-coercion ( flags -- nodes )
    [ [ ] [ >fixnum ] ? ] map '[ _ spread ] splice-quot ;

: optimize-modular-op ( #call -- nodes )
    dup out-d>> first modular-value? [
        [ in-d>> ] [ word>> integer-op-input-classes ] [ ] tri
        [
            [
                [ actually-defined-by value>> modular-value? ]
                [ fixnum eq? ]
                bi* or
            ] 2map fixnum-coercion
        ] [ [ modular-variant ] change-word ] bi* suffix
    ] when ;

M: #call optimize-modular-arithmetic*
    dup word>> {
        { [ dup \ >fixnum eq? ] [ drop optimize->fixnum ] }
        { [ dup \ >integer eq? ] [ drop optimize->integer ] }
        { [ dup "modular-arithmetic" word-prop ] [ drop optimize-modular-op ] }
        [ drop ]
    } cond ;

M: node optimize-modular-arithmetic* ;

: optimize-modular-arithmetic ( nodes -- nodes' )
    H{ } clone modularize-values set
    dup compute-modularized-values
    [ optimize-modular-arithmetic* ] map-nodes ;
