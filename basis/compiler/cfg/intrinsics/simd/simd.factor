! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien byte-arrays fry classes.algebra
cpu.architecture kernel math sequences math.vectors
math.vectors.simd.intrinsics macros generalizations combinators
combinators.short-circuit arrays locals
compiler.tree.propagation.info compiler.cfg.builder.blocks
compiler.cfg.comparisons
compiler.cfg.stacks compiler.cfg.stacks.local compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.intrinsics.alien
specialized-arrays ;
FROM: alien.c-types => heap-size uchar ushort uint ulonglong float double ;
SPECIALIZED-ARRAYS: uchar ushort uint ulonglong float double ;
IN: compiler.cfg.intrinsics.simd

MACRO: check-elements ( quots -- )
    [ length '[ _ firstn ] ]
    [ '[ _ spread ] ]
    [ length 1 - \ and <repetition> [ ] like ]
    tri 3append ;

MACRO: if-literals-match ( quots -- )
    [ length ] [ ] [ length ] tri
    ! n quots n
    '[
        ! node quot
        [
            dup node-input-infos
            _ tail-slice* [ literal>> ] map
            dup _ check-elements
        ] dip
        swap [
            ! node literals quot
            [ _ firstn ] dip call
            drop
        ] [ 2drop emit-primitive ] if
    ] ;

: emit-vector-op ( node quot: ( rep -- ) -- )
    { [ representation? ] } if-literals-match ; inline

: [binary] ( quot -- quot' )
    '[ [ ds-drop 2inputs ] dip @ ds-push ] ; inline

: emit-binary-vector-op ( node quot -- )
    [binary] emit-vector-op ; inline

: [unary] ( quot -- quot' )
    '[ [ ds-drop ds-pop ] dip @ ds-push ] ; inline

: emit-unary-vector-op ( node quot -- )
    [unary] emit-vector-op ; inline

: [unary/param] ( quot -- quot' )
    '[ [ -2 inc-d ds-pop ] 2dip @ ds-push ] ; inline

: emit-horizontal-shift ( node quot -- )
    [unary/param]
    { [ integer? ] [ representation? ] } if-literals-match ; inline

: emit-gather-vector-2 ( node -- )
    [ ^^gather-vector-2 ] emit-binary-vector-op ;

: emit-gather-vector-4 ( node -- )
    [
        ds-drop
        [
            D 3 peek-loc
            D 2 peek-loc
            D 1 peek-loc
            D 0 peek-loc
            -4 inc-d
        ] dip
        ^^gather-vector-4
        ds-push
    ] emit-vector-op ;

: shuffle? ( obj -- ? ) { [ array? ] [ [ integer? ] all? ] } 1&& ;

: >variable-shuffle ( shuffle rep -- shuffle' )
    rep-component-type heap-size
    [ dup <repetition> >byte-array ]
    [ iota >byte-array ] bi
    '[ _ n*v _ v+ ] map concat ;

: generate-shuffle-vector-imm ( src shuffle rep -- dst )
    dup %shuffle-vector-imm-reps member?
    [ ^^shuffle-vector-imm ]
    [
        [ >variable-shuffle ^^load-constant ] keep
        ^^shuffle-vector
    ] if ;

: emit-shuffle-vector-imm ( node -- )
    ! Pad the permutation with zeroes if it's too short, since we
    ! can't throw an error at this point.
    [ [ rep-components 0 pad-tail ] keep generate-shuffle-vector-imm ] [unary/param]
    { [ shuffle? ] [ representation? ] } if-literals-match ;

: emit-shuffle-vector-var ( node -- )
    [ ^^shuffle-vector ] [binary]
    { [ %shuffle-vector-reps member? ] } if-literals-match ;

: emit-shuffle-vector ( node -- )
    dup node-input-infos {
        [ length 3 = ]
        [ first  class>> byte-array class<= ]
        [ second class>> byte-array class<= ]
        [ third  literal>> representation?  ]
    } 1&& [ emit-shuffle-vector-var ] [ emit-shuffle-vector-imm ] if ;

: ^^broadcast-vector ( src n rep -- dst )
    [ rep-components swap <array> ] keep
    generate-shuffle-vector-imm ;

: emit-broadcast-vector ( node -- )
    [ ^^broadcast-vector ] [unary/param]
    { [ integer? ] [ representation? ] } if-literals-match ;

: ^^with-vector ( src rep -- dst )
    [ ^^scalar>vector ] keep [ 0 ] dip ^^broadcast-vector ;

: ^^select-vector ( src n rep -- dst )
    [ ^^broadcast-vector ] keep ^^vector>scalar ;

: emit-select-vector ( node -- )
    [ ^^select-vector ] [unary/param]
    { [ integer? ] [ representation? ] } if-literals-match ; inline

: emit-alien-vector-op ( node quot: ( rep -- ) -- )
    { [ %alien-vector-reps member? ] } if-literals-match ; inline

: emit-alien-vector ( node -- )
    dup [
        '[
            ds-drop prepare-alien-getter
            _ ^^alien-vector ds-push
        ]
        [ inline-alien-getter? ] inline-alien
    ] with emit-alien-vector-op ;

: emit-set-alien-vector ( node -- )
    dup [
        '[
            ds-drop prepare-alien-setter ds-pop
            _ ##set-alien-vector
        ]
        [ byte-array inline-alien-setter? ]
        inline-alien
    ] with emit-alien-vector-op ;

: generate-not-vector ( src rep -- dst )
    dup %not-vector-reps member?
    [ ^^not-vector ]
    [ [ ^^fill-vector ] [ ^^xor-vector ] bi ] if ;

:: ((generate-compare-vector)) ( src1 src2 rep {cc,swap} -- dst )
    {cc,swap} first2 :> swap? :> cc
    swap?
    [ src2 src1 rep cc ^^compare-vector ]
    [ src1 src2 rep cc ^^compare-vector ] if ;

:: (generate-compare-vector) ( src1 src2 rep orig-cc -- dst )
    rep orig-cc %compare-vector-ccs :> not? :> ccs

    ccs empty?
    [ rep not? [ ^^fill-vector ] [ ^^zero-vector ] if ]
    [
        ccs unclip :> first-cc :> rest-ccs
        src1 src2 rep first-cc ((generate-compare-vector)) :> first-dst

        rest-ccs first-dst
        [ [ src1 src2 rep ] dip ((generate-compare-vector)) rep ^^or-vector ]
        reduce

        not? [ rep generate-not-vector ] when
    ] if ;

: sign-bit-mask ( rep -- byte-array )
    unsign-rep {
        { char-16-rep [ uchar-array{
            HEX: 80 HEX: 80 HEX: 80 HEX: 80
            HEX: 80 HEX: 80 HEX: 80 HEX: 80
            HEX: 80 HEX: 80 HEX: 80 HEX: 80
            HEX: 80 HEX: 80 HEX: 80 HEX: 80
        } underlying>> ] }
        { short-8-rep [ ushort-array{
            HEX: 8000 HEX: 8000 HEX: 8000 HEX: 8000
            HEX: 8000 HEX: 8000 HEX: 8000 HEX: 8000
        } underlying>> ] }
        { int-4-rep [ uint-array{
            HEX: 8000,0000 HEX: 8000,0000
            HEX: 8000,0000 HEX: 8000,0000
        } underlying>> ] }
        { longlong-2-rep [ ulonglong-array{
            HEX: 8000,0000,0000,0000
            HEX: 8000,0000,0000,0000
        } underlying>> ] }
    } case ;

:: (generate-minmax-compare-vector) ( src1 src2 rep orig-cc -- dst )
    orig-cc order-cc {
        { cc<  [ src1 src2 rep ^^max-vector src1 rep cc/= (generate-compare-vector) ] }
        { cc<= [ src1 src2 rep ^^min-vector src1 rep cc=  (generate-compare-vector) ] }
        { cc>  [ src1 src2 rep ^^min-vector src1 rep cc/= (generate-compare-vector) ] }
        { cc>= [ src1 src2 rep ^^max-vector src1 rep cc=  (generate-compare-vector) ] }
    } case ;

:: generate-compare-vector ( src1 src2 rep orig-cc -- dst )
    {
        {
            [ rep orig-cc %compare-vector-reps member? ]
            [ src1 src2 rep orig-cc (generate-compare-vector) ]
        }
        {
            [ rep %min-vector-reps member? ]
            [ src1 src2 rep orig-cc (generate-minmax-compare-vector) ]
        }
        {
            [ rep unsign-rep orig-cc %compare-vector-reps member? ]
            [ 
                rep sign-bit-mask ^^load-constant :> sign-bits
                src1 sign-bits rep ^^xor-vector
                src2 sign-bits rep ^^xor-vector
                rep unsign-rep orig-cc (generate-compare-vector)
            ]
        }
    } cond ;

:: generate-unpack-vector-head ( src rep -- dst )
    {
        {
            [ rep %unpack-vector-head-reps member? ]
            [ src rep ^^unpack-vector-head ]
        }
        {
            [ rep unsigned-int-vector-rep? ]
            [
                rep ^^zero-vector :> zero
                src zero rep ^^merge-vector-head
            ]
        }
        [
            rep ^^zero-vector :> zero
            zero src rep cc> ^^compare-vector :> sign
            src sign rep ^^merge-vector-head
        ] 
    } cond ;

:: generate-unpack-vector-tail ( src rep -- dst )
    {
        {
            [ rep %unpack-vector-tail-reps member? ]
            [ src rep ^^unpack-vector-tail ]
        }
        {
            [ rep %unpack-vector-head-reps member? ]
            [
                src rep ^^tail>head-vector :> tail
                tail rep ^^unpack-vector-head
            ]
        }
        {
            [ rep unsigned-int-vector-rep? ]
            [
                rep ^^zero-vector :> zero
                src zero rep ^^merge-vector-tail
            ]
        }
        [
            rep ^^zero-vector :> zero
            zero src rep cc> ^^compare-vector :> sign
            src sign rep ^^merge-vector-tail
        ] 
    } cond ;

:: generate-load-neg-zero-vector ( rep -- dst )
    rep {
        { float-4-rep [ float-array{ -0.0 -0.0 -0.0 -0.0 } underlying>> ^^load-constant ] }
        { double-2-rep [ double-array{ -0.0 -0.0 } underlying>> ^^load-constant ] }
        [ drop rep ^^zero-vector ]
    } case ;

:: generate-neg-vector ( src rep -- dst )
    rep generate-load-neg-zero-vector
    src rep ^^sub-vector ;

:: generate-blend-vector ( mask true false rep -- dst )
    mask true rep ^^and-vector
    mask false rep ^^andn-vector
    rep ^^or-vector ;

:: generate-abs-vector ( src rep -- dst )
    {
        {
            [ rep unsigned-int-vector-rep? ]
            [ src ]
        }
        {
            [ rep %abs-vector-reps member? ]
            [ src rep ^^abs-vector ]
        }
        {
            [ rep float-vector-rep? ]
            [
                rep generate-load-neg-zero-vector
                src rep ^^andn-vector
            ]
        }
        [ 
            rep ^^zero-vector :> zero
            zero src rep ^^sub-vector :> -src
            zero src rep cc> ^^compare-vector :> sign 
            sign -src src rep generate-blend-vector
        ]
    } cond ;

: generate-min-vector ( src1 src2 rep -- dst )
    dup %min-vector-reps member?
    [ ^^min-vector ] [
        [ cc< generate-compare-vector ]
        [ generate-blend-vector ] 3bi
    ] if ;

: generate-max-vector ( src1 src2 rep -- dst )
    dup %max-vector-reps member?
    [ ^^max-vector ] [
        [ cc> generate-compare-vector ]
        [ generate-blend-vector ] 3bi
    ] if ;

