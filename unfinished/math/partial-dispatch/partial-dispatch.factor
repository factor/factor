! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel kernel.private math math.private words
sequences parser namespaces assocs quotations arrays
generic generic.math hashtables effects compiler.units ;
IN: math.partial-dispatch

! Partial dispatch.

! This code will be overhauled and generalized when
! multi-methods go into the core.
PREDICATE: math-partial < word
    "derived-from" word-prop >boolean ;

: fixnum-integer-op ( a b fix-word big-word -- c )
    pick tag 0 eq? [
        drop execute
    ] [
        >r drop >r fixnum>bignum r> r> execute
    ] if ; inline

: integer-fixnum-op ( a b fix-word big-word -- c )
    >r pick tag 0 eq? [
        r> drop execute
    ] [
        drop fixnum>bignum r> execute
    ] if ; inline

: integer-integer-op ( a b fix-word big-word -- c )
    pick tag 0 eq? [
        integer-fixnum-op
    ] [
        >r drop over tag 0 eq? [
            >r fixnum>bignum r> r> execute
        ] [
            r> execute
        ] if
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
    >r >r integer-op-triples r> r>
    [ define-integer-op-words ]
    [ 2drop [ dup integer-op-word ] { } map>assoc % ]
    3bi ;

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
    [ >r 3drop r> 1quotation ] [ drop math-method ] if ;

: math-both-known? ( word left right -- ? )
    3dup math-op
    [ 2drop 2drop t ]
    [ drop math-class-max swap specific-method >boolean ] if ;

: (derived-ops) ( word assoc -- words )
    swap [ rot first eq? nip ] curry assoc-filter values ;

: derived-ops ( word -- words )
    [ 1array ]
    [ math-ops get (derived-ops) ]
    bi append ;

: fast-derived-ops ( word -- words )
    fast-math-ops get (derived-ops) ;

: all-derived-ops ( word -- words )
    [ derived-ops ] [ fast-derived-ops ] bi append ;

: each-derived-op ( word quot -- )
    >r derived-ops r> each ; inline

: each-fast-derived-op ( word quot -- )
    >r fast-derived-ops r> each ; inline

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
