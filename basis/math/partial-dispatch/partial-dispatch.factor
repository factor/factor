! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel kernel.private math math.private words
sequences parser namespaces make assocs quotations arrays locals
generic generic.math hashtables effects compiler.units
classes.algebra ;
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

:: fixnum-integer-op ( a b fix-word big-word -- c )
    b tag 0 eq? [
        a b fix-word execute
    ] [
       a fixnum>bignum b big-word execute
    ] if ; inline

:: integer-fixnum-op ( a b fix-word big-word -- c )
    a tag 0 eq? [
        a b fix-word execute
    ] [
        a b fixnum>bignum big-word execute
    ] if ; inline

:: integer-integer-op ( a b fix-word big-word -- c )
    b tag 0 eq? [
        a b fix-word big-word integer-fixnum-op
    ] [
        a dup tag 0 eq? [ fixnum>bignum ] when
        b big-word execute
    ] if ; inline

: integer-op-combinator ( triple -- word )
    [
        [ second name>> % "-" % ]
        [ third name>> % "-op" % ]
        bi
    ] "" make "math.partial-dispatch" lookup ;

: integer-op-word ( triple -- word )
    [ name>> ] map "-" join "math.partial-dispatch" create ;

: integer-op-quot ( triple fix-word big-word -- quot )
    rot integer-op-combinator 1quotation 2curry ;

: define-integer-op-word ( triple fix-word big-word -- )
    [
        [ 2drop integer-op-word ] [ integer-op-quot ] 3bi
        (( x y -- z )) define-declared
    ] [
        2drop
        [ integer-op-word ] keep
        "derived-from" set-word-prop
    ] 3bi ;

: define-integer-op-words ( triples fix-word big-word -- )
    [ define-integer-op-word ] 2curry each ;

: integer-op-triples ( word -- triples )
    {
        { fixnum integer }
        { integer fixnum }
        { integer integer }
    } swap [ prefix ] curry map ;

: define-integer-ops ( word fix-word big-word -- )
    [
        rot tuck
        [ fixnum fixnum 3array "derived-from" set-word-prop ]
        [ bignum bignum 3array "derived-from" set-word-prop ]
        2bi*
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
    [ def>> peek ] assoc-map % ;

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
    [ drop math-class-max swap specific-method >boolean ] if ;

: (derived-ops) ( word assoc -- words )
    swap [ rot first eq? nip ] curry assoc-filter ;

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
        \ shift   define-math-ops
        \ mod     define-math-ops
        \ /i      define-math-ops

        \ bitand  define-math-ops
        \ bitor   define-math-ops
        \ bitxor  define-math-ops

        \ <       define-math-ops
        \ <=      define-math-ops
        \ >       define-math-ops
        \ >=      define-math-ops
        \ number= define-math-ops

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
