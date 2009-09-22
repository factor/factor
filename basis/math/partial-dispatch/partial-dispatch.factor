! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel kernel.private math math.private words
sequences parser namespaces make assocs quotations arrays
generic generic.math hashtables effects compiler.units
classes.algebra fry combinators ;
IN: math.partial-dispatch

PREDICATE: math-partial < word
    "derived-from" word-prop >boolean ;

GENERIC: integer-op-input-classes ( word -- classes )

M: math-partial integer-op-input-classes
    "derived-from" word-prop rest ;

ERROR: bad-integer-op word ;

M: word integer-op-input-classes
    dup "input-classes" word-prop
    [ ] [ bad-integer-op ] ?if ;

: generic-variant ( op -- generic-op/f )
    dup "derived-from" word-prop [ first ] [ ] ?if ;

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
    } at swap or ;

: bignum-fixnum-op-quot ( big-word -- quot )
    '[ fixnum>bignum _ execute ] ;

: fixnum-bignum-op-quot ( big-word -- quot )
    '[ [ fixnum>bignum ] dip _ execute ] ;

: integer-fixnum-op-quot ( fix-word big-word -- quot )
    [
        [ over fixnum? ] %
        [ '[ _ execute ] , ] [ bignum-fixnum-op-quot , ] bi* \ if ,
    ] [ ] make ;

: fixnum-integer-op-quot ( fix-word big-word -- quot )
    [
        [ dup fixnum? ] %
        [ '[ _ execute ] , ] [ fixnum-bignum-op-quot , ] bi* \ if ,
    ] [ ] make ;

: integer-bignum-op-quot ( big-word -- quot )
    [
        [ over fixnum? ] %
        [ fixnum-bignum-op-quot , ] [ '[ _ execute ] , ] bi \ if ,
    ] [ ] make ;

: integer-integer-op-quot ( fix-word big-word -- quot )
    [
        [ 2dup both-fixnums? ] %
        [ '[ _ execute ] , ]
        [
            [
                [ dup fixnum? ] %
                [ bignum-fixnum-op-quot , ]
                [ integer-bignum-op-quot , ] bi \ if ,
            ] [ ] make ,
        ] bi* \ if ,
    ] [ ] make ;

: integer-op-word ( triple -- word )
    [ name>> ] map "-" join "math.partial-dispatch" create ;

: integer-op-quot ( fix-word big-word triple -- quot )
    [ second ] [ third ] bi 2array {
        { { fixnum integer } [ fixnum-integer-op-quot ] }
        { { integer fixnum } [ integer-fixnum-op-quot ] }
        { { integer integer } [ integer-integer-op-quot ] }
    } case ;

: define-integer-op-word ( fix-word big-word triple -- )
    [
        [ 2nip integer-op-word dup make-foldable ] [ integer-op-quot ] 3bi
        (( x y -- z )) define-declared
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
        [ 2drop [ dup integer-op-word ] { } map>assoc % ]
        3bi
    ] 3bi ;

: define-math-ops ( op -- )
    { fixnum bignum float }
    [ [ dup 3array ] [ swap method ] 2bi ] with { } map>assoc
    [ nip ] assoc-filter
    [ def>> ] assoc-map
    [ nip length 1 = ] assoc-filter
    [ first ] assoc-map % ;

SYMBOL: math-ops

SYMBOL: fast-math-ops

: math-op ( word left right -- word' ? )
    3array math-ops get at* ;

: math-method* ( word left right -- quot )
    3dup math-op
    [ [ 3drop ] dip 1quotation ] [ drop math-method ] if ;

: math-both-known? ( word left right -- ? )
    3dup math-op
    [ 2drop 2drop t ]
    [ drop math-class-max swap method-for-class >boolean ] if ;

: (derived-ops) ( word assoc -- words )
    swap '[ swap first _ eq? nip ] assoc-filter ;

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
            drop
            [ second integer class<= ]
            [ third integer class<= ]
            bi and
        ] assoc-filter values
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
