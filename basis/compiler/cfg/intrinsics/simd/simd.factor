! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien byte-arrays fry classes.algebra
cpu.architecture kernel math sequences math.vectors
math.vectors.simd macros generalizations combinators
combinators.short-circuit arrays locals
compiler.tree.propagation.info compiler.cfg.builder.blocks
compiler.cfg.comparisons
compiler.cfg.stacks compiler.cfg.stacks.local compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.intrinsics.alien
specialized-arrays ;
FROM: alien.c-types => heap-size char short int longlong float double ;
SPECIALIZED-ARRAYS: char short int longlong float double ;
IN: compiler.cfg.intrinsics.simd

! compound vector ops

: ^load-neg-zero-vector ( rep -- dst )
    {
        { float-4-rep [ float-array{ -0.0 -0.0 -0.0 -0.0 } underlying>> ^^load-constant ] }
        { double-2-rep [ double-array{ -0.0 -0.0 } underlying>> ^^load-constant ] }
    } case ;

: ^load-add-sub-vector ( rep -- dst )
    unsign-rep {
        { float-4-rep    [ float-array{ -0.0  0.0 -0.0  0.0 } underlying>> ^^load-constant ] }
        { double-2-rep   [ double-array{ -0.0  0.0 } underlying>> ^^load-constant ] }
        { char-16-rep    [ char-array{ -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 } underlying>> ^^load-constant ] }
        { short-8-rep    [ short-array{ -1 0 -1 0 -1 0 -1 0 } underlying>> ^^load-constant ] }
        { int-4-rep      [ int-array{ -1 0 -1 0 } underlying>> ^^load-constant ] }
        { longlong-2-rep [ longlong-array{ -1 0 } underlying>> ^^load-constant ] }
    } case ;

: >variable-shuffle ( shuffle rep -- shuffle' )
    rep-component-type heap-size
    [ dup <repetition> >byte-array ]
    [ iota >byte-array ] bi
    '[ _ n*v _ v+ ] map concat ;

: ^load-immediate-shuffle ( shuffle rep -- dst )
    >variable-shuffle ^^load-constant ;

:: ^blend-vector ( mask true false rep -- dst )
    true mask rep ^^and-vector
    mask false rep ^^andn-vector
    rep ^^or-vector ;

: ^compare-vector ( src1 src2 rep cc -- dst )
    ... ;

: ^widened-shr-vector-imm ( src shift rep -- dst )
    widen-vector-rep ^^shr-vector-imm ;

! intrinsic emitters

: emit-simd-v+ ( node -- )
    {
        [ ^^add-vector ]
    } emit-vv-vector-op ;

: emit-simd-v- ( node -- )
    {
        [ ^^sub-vector ]
    } emit-vv-vector-op ;

: emit-simd-vneg ( node -- )
    {
        { float-vector-rep [ [ ^load-neg-zero-vector ] [ ^^sub-vector ] bi ] }
        { int-vector-rep   [ [ ^^zero-vector         ] [ ^^sub-vector ] bi ] }
    } emit-v-vector-op ;

: emit-simd-v+- ( node -- )
    {
        [ ^^add-sub-vector ]
        { float-vector-rep [| src1 src2 rep |
            rep ^load-add-sub-vector :> signs
            src2 signs rep ^^xor-vector :> src2'
            src1 src2' rep ^^add-vector
        ] }
        { int-vector-rep   [| src1 src2 rep |
            rep ^load-add-sub-vector :> signs
            src2  signs rep ^^xor-vector :> src2'
            src2' signs rep ^^sub-vector :> src2''
            src1 src2'' rep ^^add-vector
        ] }
    } emit-vv-vector-op ;

: emit-simd-vs+ ( node -- )
    {
        { float-vector-rep [ ^^add-vector ] }
        { int-vector-rep [ ^^saturated-add-vector ] }
    } emit-vv-vector-op ;

: emit-simd-vs- ( node -- )
    {
        { float-vector-rep [ ^^sub-vector ] }
        { int-vector-rep [ ^^saturated-sub-vector ] }
    } emit-vv-vector-op ;

: emit-simd-vs* ( node -- )
    {
        { float-vector-rep [ ^^mul-vector ] }
        { int-vector-rep [ ^^saturated-mul-vector ] }
    } emit-vv-vector-op ;

: emit-simd-v* ( node -- )
    {
        [ ^^mul-vector ]
    } emit-vv-vector-op ;

: emit-simd-v/ ( node -- )
    {
        [ ^^div-vector ]
    } emit-vv-vector-op ;

: emit-simd-vmin ( node -- )
    {
        [ ^^min-vector ]
        [
            [ cc< ^compare-vector ]
            [ ^blend-vector ] 3bi
        ]
    } emit-vv-vector-op ;

: emit-simd-vmax ( node -- )
    {
        [ ^^max-vector ]
        [
            [ cc> ^compare-vector ]
            [ ^blend-vector ] 3bi
        ]
    } emit-vv-vector-op ;

: emit-simd-v. ( node -- )
    {
        [ ^^dot-vector ]
        { float-vector-rep [| src1 src2 rep |
            
        ] }
        { int-vector-rep [| src1 src2 rep |
            ...
        ] }
    } emit-vv-vector-op ;

: emit-simd-vsqrt ( node -- )
    {
        [ ^^sqrt-vector ]
    } emit-v-vector-op ;

: emit-simd-sum ( node -- )
    ... ;

: emit-simd-vabs ( node -- )
    {
        { unsigned-int-vector-rep [ drop ] }
        [ ^^abs-vector ]
        { float-vector-rep [ [ ^load-neg-zero-vector ] [ swapd ^^andn-vector ] bi ] }
        { int-vector-rep [| src rep |
            rep ^^zero-vector :> zero
            zero src rep ^^sub-vector :> -src
            zero src rep cc> ^compare-vector :> sign
            sign -src src rep ^blend-vector
        ] }
    } emit-v-vector-op ;

: emit-simd-vand ( node -- )
    {
        [ ^^and-vector ]
    } emit-vv-vector-op ;

: emit-simd-vandn ( node -- )
    {
        [ ^^andn-vector ]
    } emit-vv-vector-op ;

: emit-simd-vor ( node -- )
    {
        [ ^^or-vector ]
    } emit-vv-vector-op ;

: emit-simd-vxor ( node -- )
    {
        [ ^^xor-vector ]
    } emit-vv-vector-op ;

: emit-simd-vnot ( node -- )
    {
        [ ^^not-vector ]
        [ [ ^^fill-vector ] [ ^^xor-vector ] bi ]
    } emit-v-vector-op ;

: emit-simd-vlshift ( node -- )
    {
        [ ^^shl-vector ]
    } {
        [ ^^shl-vector-imm ]
    } emit-vn-or-vl-vector-op ;

: emit-simd-vrshift ( node -- )
    {
        [ ^^shr-vector ]
    } {
        [ ^^shr-vector-imm ]
    } emit-vn-or-vl-vector-op ;

: emit-simd-hlshift ( node -- )
    {
        [ ^^horizontal-shl-vector-imm ]
    } emit-vl-vector-op ;

: emit-simd-hrshift ( node -- )
    {
        [ ^^horizontal-shr-vector-imm ]
    } emit-vl-vector-op ;

: emit-simd-vshuffle-elements ( node -- )
    {
        [ ^^shuffle-vector-imm ]
        [ [ ^load-immediate-shuffle ] [ ^^shuffle-vector ] ]
    } emit-vl-vector-op ;

: emit-simd-vshuffle-bytes ( node -- )
    {
        [ ^^shuffle-vector ]
    } emit-vv-vector-op ;

: emit-simd-vmerge-head ( node -- )
    {
        [ ^^merge-vector-head ]
    } emit-vv-vector-op ;

: emit-simd-vmerge-tail ( node -- )
    {
        [ ^^merge-vector-tail ]
    } emit-vv-vector-op ;

: emit-simd-v<= ( node -- )
    [ cc<= ^compare-vector ] (emit-vv-vector-op) ;
: emit-simd-v< ( node -- )
    [ cc< ^compare-vector ] (emit-vv-vector-op) ;
: emit-simd-v= ( node -- )
    [ cc= ^compare-vector ] (emit-vv-vector-op) ;
: emit-simd-v> ( node -- )
    [ cc> ^compare-vector ] (emit-vv-vector-op) ;
: emit-simd-v>= ( node -- )
    [ cc>= ^compare-vector ] (emit-vv-vector-op) ;
: emit-simd-vunordered? ( node -- )
    [ cc/<>= ^compare-vector ] (emit-vv-vector-op) ;

: emit-simd-vany? ( node -- )
    [ vcc-any ^test-vector ] (emit-vv-vector-op) ;
: emit-simd-vall? ( node -- )
    [ vcc-all ^test-vector ] (emit-vv-vector-op) ;
: emit-simd-vnone? ( node -- )
    [ vcc-none ^test-vector ] (emit-vv-vector-op) ;

: emit-simd-v>float ( node -- )
    {
        { float-vector-rep [ drop ] }
        { int-vector-rep [ ^^integer>float-vector ] }
    } emit-vv-vector-op ;

: emit-simd-v>integer ( node -- )
    {
        { float-vector-rep [ ^^float>integer-vector ] }
        { int-vector-rep [ dup ] }
    } emit-vv-vector-op ;

: emit-simd-vpack-signed ( node -- )
    {
        [ ^^signed-pack-vector ]
    } emit-vv-vector-op ;

: emit-simd-vpack-unsigned ( node -- )
    {
        [ ^^unsigned-pack-vector ]
    } emit-vv-vector-op ;

! XXX shr vector rep is widened!
: emit-simd-vunpack-head ( node -- )
    {
        [ ^^unpack-vector-head ]
        { unsigned-int-vector-rep [ [ ^^zero-vector ] [ ^^merge-vector-head ] bi ] }
        { signed-int-vector-rep [| src rep |
            src src rep ^^merge-vector-head :> merged
            rep rep-component-type heap-size 8 * :> bits
            merged bits rep ^widened-shr-vector-imm
        ] }
        { signed-int-vector-rep [| src rep |
            rep ^^zero-vector :> zero
            zero src rep cc> ^compare-vector :> sign
            src sign rep ^^merge-vector-head
        ] }
    } emit-v-vector-op ;

: emit-simd-vunpack-tail ( node -- )
    {
        [ ^^unpack-vector-tail ]
        [ [ ^^tail>head-vector ] [ ^^unpack-vector-head ] bi ]
        { unsigned-int-vector-rep [ [ ^^zero-vector ] [ ^^merge-vector-tail ] bi ] }
        { signed-int-vector-rep [| src rep |
            src src rep ^^merge-vector-tail :> merged
            rep rep-component-type heap-size 8 * :> bits
            merged bits rep widen-vector-rep ^widened-shr-vector-imm
        ] }
        { signed-int-vector-rep [| src rep |
            rep ^^zero-vector :> zero
            zero src rep cc> ^compare-vector :> sign
            src sign rep ^^merge-vector-tail
        ] }
    } emit-v-vector-op ;

: emit-simd-with ( node -- )
: emit-simd-gather-2 ( node -- )
: emit-simd-gather-4 ( node -- )
: emit-simd-select ( node -- )
: emit-alien-vector ( node -- )
: emit-set-alien-vector ( node -- )
: emit-alien-vector-aligned ( node -- )
: emit-set-alien-vector-aligned ( node -- )

: enable-simd ( -- )
    {
        { (simd-v+)                [ emit-simd-v+                  ] }
        { (simd-v-)                [ emit-simd-v-                  ] }
        { (simd-vneg)              [ emit-simd-vneg                ] }
        { (simd-v+-)               [ emit-simd-v+-                 ] }
        { (simd-vs+)               [ emit-simd-vs+                 ] }
        { (simd-vs-)               [ emit-simd-vs-                 ] }
        { (simd-vs*)               [ emit-simd-vs*                 ] }
        { (simd-v*)                [ emit-simd-v*                  ] }
        { (simd-v/)                [ emit-simd-v/                  ] }
        { (simd-vmin)              [ emit-simd-vmin                ] }
        { (simd-vmax)              [ emit-simd-vmax                ] }
        { (simd-v.)                [ emit-simd-v.                  ] }
        { (simd-vsqrt)             [ emit-simd-vsqrt               ] }
        { (simd-sum)               [ emit-simd-sum                 ] }
        { (simd-vabs)              [ emit-simd-vabs                ] }
        { (simd-vbitand)           [ emit-simd-vand                ] }
        { (simd-vbitandn)          [ emit-simd-vandn               ] }
        { (simd-vbitor)            [ emit-simd-vor                 ] }
        { (simd-vbitxor)           [ emit-simd-vxor                ] }
        { (simd-vbitnot)           [ emit-simd-vnot                ] }
        { (simd-vand)              [ emit-simd-vand                ] }
        { (simd-vandn)             [ emit-simd-vandn               ] }
        { (simd-vor)               [ emit-simd-vor                 ] }
        { (simd-vxor)              [ emit-simd-vxor                ] }
        { (simd-vnot)              [ emit-simd-vnot                ] }
        { (simd-vlshift)           [ emit-simd-vlshift             ] }
        { (simd-vrshift)           [ emit-simd-vrshift             ] }
        { (simd-hlshift)           [ emit-simd-hlshift             ] }
        { (simd-hrshift)           [ emit-simd-hrshift             ] }
        { (simd-vshuffle-elements) [ emit-simd-vshuffle-elements   ] }
        { (simd-vshuffle-bytes)    [ emit-simd-vshuffle-bytes      ] }
        { (simd-vmerge-head)       [ emit-simd-vmerge-head         ] }
        { (simd-vmerge-tail)       [ emit-simd-vmerge-tail         ] }
        { (simd-v<=)               [ emit-simd-v<=                 ] }
        { (simd-v<)                [ emit-simd-v<                  ] }
        { (simd-v=)                [ emit-simd-v=                  ] }
        { (simd-v>)                [ emit-simd-v>                  ] }
        { (simd-v>=)               [ emit-simd-v>=                 ] }
        { (simd-vunordered?)       [ emit-simd-vunordered?         ] }
        { (simd-vany?)             [ emit-simd-vany?               ] }
        { (simd-vall?)             [ emit-simd-vall?               ] }
        { (simd-vnone?)            [ emit-simd-vnone?              ] }
        { (simd-v>float)           [ emit-simd-v>float             ] }
        { (simd-v>integer)         [ emit-simd-v>integer           ] }
        { (simd-vpack-signed)      [ emit-simd-vpack-signed        ] }
        { (simd-vpack-unsigned)    [ emit-simd-vpack-unsigned      ] }
        { (simd-vunpack-head)      [ emit-simd-vunpack-head        ] }
        { (simd-vunpack-tail)      [ emit-simd-vunpack-tail        ] }
        { (simd-with)              [ emit-simd-with                ] }
        { (simd-gather-2)          [ emit-simd-gather-2            ] }
        { (simd-gather-4)          [ emit-simd-gather-4            ] }
        { (simd-select)            [ emit-simd-select              ] }
        { alien-vector             [ emit-alien-vector             ] }
        { set-alien-vector         [ emit-set-alien-vector         ] }
        { alien-vector-aligned     [ emit-alien-vector             ] }
        { set-alien-vector-aligned [ emit-set-alien-vector         ] }
    } enable-intrinsics ;

enable-simd
