! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.algebra combinators
compiler.units fry generic generic.math hashtables kernel make
math math.private namespaces quotations sequences words ;
IN: math.partial-dispatch

PREDICATE: math-partial < word
    "derived-from" word-prop >boolean ;

GENERIC: integer-op-input-classes ( word -- classes )

M: math-partial integer-op-input-classes
    "derived-from" word-prop rest ;

ERROR: bad-integer-op word ;

M: word integer-op-input-classes
    [ "input-classes" word-prop ]
    [ bad-integer-op ] ?unless ;

: generic-variant ( op -- generic-op/f )
    [ "derived-from" word-prop ] [ first ] ?when ;

: no-overflow-variant ( op -- fast-op )
    H{
        { fixnum+ fixnum+fast }
        { fixnum- fixnum-fast }
        { fixnum* fixnum*fast }
        { fixnum-shift fixnum-shift-fast }
        { fixnum/i fixnum/i-fast }
        { fixnum/mod fixnum/mod-fast }
    } at ;

: modular-variant ( op -- fast-op )
    generic-variant dup H{
        { + fixnum+fast }
        { - fixnum-fast }
        { * fixnum*fast }
        { shift fixnum-shift-fast }
        { bitand fixnum-bitand }
        { bitor fixnum-bitor }
        { bitxor fixnum-bitxor }
        { bitnot fixnum-bitnot }
    } at or* ;

: bignum-fixnum-op-quot ( big-word -- quot )
    '[ fixnum>bignum _ execute ] ;

: fixnum-bignum-op-quot ( big-word -- quot )
    '[ [ fixnum>bignum ] dip _ execute ] ;

: integer-fixnum-op-quot ( fix-word big-word -- quot )
    bignum-fixnum-op-quot '[ over fixnum? [ _ execute ] _ if ] ;

: fixnum-integer-op-quot ( fix-word big-word -- quot )
    fixnum-bignum-op-quot '[ dup fixnum? [ _ execute ] _ if ] ;

: integer-bignum-op-quot ( big-word -- quot )
    [ fixnum-bignum-op-quot ] keep
    '[ over fixnum? _ [ _ execute ] if ] ;

: integer-integer-op-quot ( fix-word big-word -- quot )
    [ bignum-fixnum-op-quot ] [ integer-bignum-op-quot ] bi
    '[
        2dup both-fixnums?
        [ _ execute ] [ dup fixnum? _ _ if ] if
    ] ;

: integer-op-word ( triple -- word )
    [ name>> ] map "-" join "math.partial-dispatch" create-word ;

: integer-op-quot ( fix-word big-word triple -- quot )
    [ second ] [ third ] bi 2array {
        { { fixnum integer } [ fixnum-integer-op-quot ] }
        { { integer fixnum } [ integer-fixnum-op-quot ] }
        { { integer integer } [ integer-integer-op-quot ] }
    } case ;

: define-integer-op-word ( fix-word big-word triple -- )
    [
        [ 2nip integer-op-word dup make-foldable ] [ integer-op-quot ] 3bi
        ( x y -- z ) define-declared
    ] [
        2nip
        [ integer-op-word ] keep
        "derived-from" set-word-prop
    ] 3bi ;

: define-integer-op-words ( triples fix-word big-word -- )
    '[ [ _ _ ] dip define-integer-op-word ] each ;

: integer-op-triples ( word -- triples )
    {
        { fixnum integer }
        { integer fixnum }
        { integer integer }
    } swap '[ _ prefix ] map ;

: define-integer-ops ( word fix-word big-word -- )
    [
        rot
        [ fixnum fixnum 3array "derived-from" set-word-prop ]
        [ bignum bignum 3array "derived-from" set-word-prop ]
        bi-curry bi*
    ] [
        [ integer-op-triples ] 2dip
        [ define-integer-op-words ]
        [ 2drop [ dup integer-op-word ] map>alist % ]
        3bi
    ] 3bi ;

: define-math-ops ( op -- )
    { fixnum bignum float }
    [ [ dup 3array ] [ swap ?lookup-method ] 2bi ] with map>alist
    sift-values
    [ def>> ] assoc-map
    [ length 1 = ] filter-values
    [ first ] assoc-map % ;

SYMBOL: math-ops

SYMBOL: fast-math-ops

: math-op ( word left right -- word' ? )
    3array math-ops get at* ;

: math-method* ( word left right -- quot )
    3dup math-op
    [ 3nip 1quotation ] [ drop math-method ] if ;

: math-both-known? ( word left right -- ? )
    3dup math-op
    [ 4drop t ]
    [ drop math-class-max swap method-for-class >boolean ] if ;

: (derived-ops) ( word assoc -- words )
    swap '[ first _ eq? ] filter-keys ;

: derived-ops ( word -- words )
    [ 1array ] [ math-ops get (derived-ops) values ] bi append ;

: fast-derived-ops ( word -- words )
    fast-math-ops get (derived-ops) values ;

: all-derived-ops ( word -- words )
    [ derived-ops ] [ fast-derived-ops ] bi append ;

: integer-derived-ops ( word -- words )
    [ math-ops get (derived-ops) ] [ fast-math-ops get (derived-ops) ] bi
    [
        [
            [ second integer class<= ]
            [ third integer class<= ]
            bi and
        ] filter-keys values
    ] bi@ append ;

: each-derived-op ( word quot -- )
    [ derived-ops ] dip each ; inline

: each-fast-derived-op ( word quot -- )
    [ fast-derived-ops ] dip each ; inline

: each-integer-derived-op ( word quot -- )
    [ integer-derived-ops ] dip each ; inline

[
    [
        \ +       define-math-ops
        \ -       define-math-ops
        \ *       define-math-ops
        \ mod     define-math-ops
        \ /i      define-math-ops

        \ bitand  define-math-ops
        \ bitor   define-math-ops
        \ bitxor  define-math-ops

        \ <       define-math-ops
        \ <=      define-math-ops
        \ >       define-math-ops
        \ >=      define-math-ops

        \ u<      define-math-ops
        \ u<=     define-math-ops
        \ u>      define-math-ops
        \ u>=     define-math-ops

        \ number= define-math-ops

        { { shift bignum bignum } bignum-shift } ,
        { { shift fixnum fixnum } fixnum-shift } ,

        \ + \ fixnum+ \ bignum+ define-integer-ops
        \ - \ fixnum- \ bignum- define-integer-ops
        \ * \ fixnum* \ bignum* define-integer-ops
        \ shift \ fixnum-shift \ bignum-shift define-integer-ops
        \ mod \ fixnum-mod \ bignum-mod define-integer-ops
        \ /i \ fixnum/i \ bignum/i define-integer-ops

        \ simple-gcd \ fixnum-gcd \ bignum-gcd define-integer-ops

        \ bitand \ fixnum-bitand \ bignum-bitand define-integer-ops
        \ bitor \ fixnum-bitor \ bignum-bitor define-integer-ops
        \ bitxor \ fixnum-bitxor \ bignum-bitxor define-integer-ops

        \ < \ fixnum< \ bignum< define-integer-ops
        \ <= \ fixnum<= \ bignum<= define-integer-ops
        \ > \ fixnum> \ bignum> define-integer-ops
        \ >= \ fixnum>= \ bignum>= define-integer-ops
        \ number= \ eq? \ bignum= define-integer-ops
    ] { } make >hashtable math-ops set-global

    H{
        { { + fixnum fixnum } fixnum+fast }
        { { - fixnum fixnum } fixnum-fast }
        { { * fixnum fixnum } fixnum*fast }
        { { shift fixnum fixnum } fixnum-shift-fast }
    } fast-math-ops set-global
] with-compilation-unit
