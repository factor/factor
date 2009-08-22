! Copyright (C) 2008, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math math.intervals math.private math.partial-dispatch
namespaces sequences sets accessors assocs words kernel memoize fry
combinators combinators.short-circuit layouts alien.accessors
compiler.tree
compiler.tree.combinators
compiler.tree.propagation.info
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

! Words where the low-order bits of the output only depends on the
! low-order bits of the input. If the output is only used for its
! low-order bits, then the word can be converted into a form that is
! cheaper to compute.
{ + - * bitand bitor bitxor } [
    [
        t "modular-arithmetic" set-word-prop
    ] each-integer-derived-op
] each

{ bitand bitor bitxor bitnot >integer >bignum fixnum>bignum }
[ t "modular-arithmetic" set-word-prop ] each

! Words that only use the low-order bits of their input. If the input
! is a modular arithmetic word, then the input can be converted into
! a form that is cheaper to compute.
{
    >fixnum bignum>fixnum float>fixnum
    set-alien-unsigned-1 set-alien-signed-1
    set-alien-unsigned-2 set-alien-signed-2
}
cell 8 = [
    { set-alien-unsigned-4 set-alien-signed-4 } append
] when
[ t "low-order" set-word-prop ] each

! Values which only have their low-order bits used. This set starts out
! big and is gradually refined.
SYMBOL: modular-values

: modular-value? ( value -- ? )
    modular-values get key? ;

: modular-value ( value -- )
    modular-values get conjoin ;

! Values which are known to be fixnums.
SYMBOL: fixnum-values

: fixnum-value? ( value -- ? )
    fixnum-values get key? ;

: fixnum-value ( value -- )
    fixnum-values get conjoin ;

GENERIC: compute-modular-candidates* ( node -- )

M: #push compute-modular-candidates*
    [ out-d>> first ] [ literal>> ] bi
    real? [ [ modular-value ] [ fixnum-value ] bi ] [ drop ] if ;

: small-shift? ( interval -- ? )
    0 cell-bits tag-bits get - 1 - [a,b] interval-subset? ;

: modular-word? ( #call -- ? )
    dup word>> { shift fixnum-shift bignum-shift } memq?
    [ node-input-infos second interval>> small-shift? ]
    [ word>> "modular-arithmetic" word-prop ]
    if ;

: output-candidate ( #call -- )
    out-d>> first [ modular-value ] [ fixnum-value ] bi ;

: low-order-word? ( #call -- ? )
    word>> "low-order" word-prop ;

: input-candidiate ( #call -- )
    in-d>> first modular-value ;

M: #call compute-modular-candidates*
    {
        { [ dup modular-word? ] [ output-candidate ] }
        { [ dup low-order-word? ] [ input-candidiate ] }
        [ drop ]
    } cond ;

M: node compute-modular-candidates*
    drop ;

: compute-modular-candidates ( nodes -- )
    H{ } clone modular-values set
    H{ } clone fixnum-values set
    [ compute-modular-candidates* ] each-node ;

GENERIC: only-reads-low-order? ( node -- ? )

: output-modular? ( #call -- ? )
    out-d>> first modular-values get key? ;

M: #call only-reads-low-order?
    {
        [ low-order-word? ]
        [ { [ modular-word? ] [ output-modular? ] } 1&& ]
    } 1|| ;

M: node only-reads-low-order? drop f ;

SYMBOL: changed?

: only-used-as-low-order? ( value -- ? )
    actually-used-by [ node>> only-reads-low-order? ] all? ;

: (compute-modular-values) ( -- )
    modular-values get keys [
        dup only-used-as-low-order?
        [ drop ] [ modular-values get delete-at changed? on ] if
    ] each ;

: compute-modular-values ( -- )
    [ changed? off (compute-modular-values) changed? get ] loop ;

GENERIC: optimize-modular-arithmetic* ( node -- nodes )

M: #push optimize-modular-arithmetic*
    dup [ out-d>> first modular-value? ] [ literal>> real? ] bi and
    [ [ >fixnum ] change-literal ] when ;

: redundant->fixnum? ( #call -- ? )
    in-d>> first actually-defined-by
    [ value>> { [ modular-value? ] [ fixnum-value? ] } 1&& ] all? ;

: optimize->fixnum ( #call -- nodes )
    dup redundant->fixnum? [ drop f ] when ;

: should-be->fixnum? ( #call -- ? )
    out-d>> first modular-value? ;

: optimize->integer ( #call -- nodes )
    dup should-be->fixnum? [ \ >fixnum >>word ] when ;

MEMO: fixnum-coercion ( flags -- nodes )
    ! flags indicate which input parameters are already known to be fixnums,
    ! and don't need a coercion as a result.
    [ [ ] [ >fixnum ] ? ] map '[ _ spread ] splice-quot ;

: modular-value-info ( #call -- alist )
    [ in-d>> ] [ out-d>> ] bi append
    fixnum <class-info> '[ _ ] { } map>assoc ;

: optimize-modular-op ( #call -- nodes )
    dup out-d>> first modular-value? [
        [ in-d>> ] [ word>> integer-op-input-classes ] [ ] tri
        [
            [
                [ actually-defined-by [ value>> modular-value? ] all? ]
                [ fixnum eq? ]
                bi* or
            ] 2map fixnum-coercion
        ] [ [ modular-variant ] change-word ] bi* suffix
    ] when ;

: optimize-low-order-op ( #call -- nodes )
    dup in-d>> first actually-defined-by [ value>> fixnum-value? ] all? [
        [ ] [ in-d>> first ] [ info>> ] tri
        [ drop fixnum <class-info> ] change-at
    ] when ;

: like->fixnum? ( #call -- ? )
    word>> { >fixnum bignum>fixnum float>fixnum } memq? ;

: like->integer? ( #call -- ? )
    word>> { >integer >bignum fixnum>bignum } memq? ;

M: #call optimize-modular-arithmetic*
    {
        { [ dup like->fixnum? ] [ optimize->fixnum ] }
        { [ dup like->integer? ] [ optimize->integer ] }
        { [ dup modular-word? ] [ optimize-modular-op ] }
        { [ dup low-order-word? ] [ optimize-low-order-op ] }
        [ ]
    } cond ;

M: node optimize-modular-arithmetic* ;

: optimize-modular-arithmetic ( nodes -- nodes' )
    dup compute-modular-candidates compute-modular-values
    modular-values get assoc-empty? [
        [ optimize-modular-arithmetic* ] map-nodes
    ] unless ;
