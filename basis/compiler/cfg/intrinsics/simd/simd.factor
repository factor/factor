! Copyright (C) 2009 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs byte-arrays
combinators combinators.short-circuit compiler.cfg.comparisons
compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.intrinsics compiler.cfg.intrinsics.alien
compiler.cfg.intrinsics.simd.backend compiler.cfg.stacks
cpu.architecture kernel layouts math math.vectors
math.vectors.simd.intrinsics sequences specialized-arrays ;
FROM: alien.c-types => heap-size char short int longlong float double ;
SPECIALIZED-ARRAYS: char uchar short ushort int uint longlong ulonglong float double ;
IN: compiler.cfg.intrinsics.simd

! compound vector ops

CONSTANT: rep>bit-mask {
    {
        char-16-rep uchar-array{
            0x80 0x80 0x80 0x80
            0x80 0x80 0x80 0x80
            0x80 0x80 0x80 0x80
            0x80 0x80 0x80 0x80
        }
    }
    {
        short-8-rep ushort-array{
            0x8000 0x8000 0x8000 0x8000
            0x8000 0x8000 0x8000 0x8000
        }
    }
    {
        int-4-rep uint-array{
            0x8000,0000 0x8000,0000
            0x8000,0000 0x8000,0000
        }
    }
    {
        longlong-2-rep ulonglong-array{
            0x8000,0000,0000,0000
            0x8000,0000,0000,0000
        }
    }
}

: sign-bit-mask ( rep -- byte-array )
    signed-rep rep>bit-mask at underlying>> ;

CONSTANT: rep>neg-zero {
    { float-4-rep float-array{ -0.0 -0.0 -0.0 -0.0 } }
    { double-2-rep double-array{ -0.0 -0.0 } }
}

: ^load-neg-zero-vector ( rep -- dst )
    rep>neg-zero at underlying>> ^^load-literal ;

CONSTANT: rep>add-sub {
    { float-4-rep float-array{ -0.0  0.0 -0.0  0.0 } }
    { double-2-rep double-array{ -0.0  0.0 } }
    { char-16-rep char-array{ -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 } }
    { short-8-rep short-array{ -1 0 -1 0 -1 0 -1 0 } }
    { int-4-rep int-array{ -1 0 -1 0 } }
    { longlong-2-rep longlong-array{ -1 0 } }
}

: ^load-add-sub-vector ( rep -- dst )
    signed-rep rep>add-sub at underlying>> ^^load-literal ;

CONSTANT: rep>half {
    { float-4-rep float-array{  0.5 0.5 0.5 0.5 } }
    { double-2-rep double-array{ 0.5 0.5 } }
}

: ^load-half-vector ( rep -- dst )
    rep>half at underlying>> ^^load-literal ;

: >variable-shuffle ( shuffle rep -- shuffle' )
    rep-component-type heap-size
    [ dup <repetition> >byte-array ]
    [ <iota> >byte-array ] bi
    '[ _ n*v _ v+ ] map concat ;

: ^load-immediate-shuffle ( shuffle rep -- dst )
    >variable-shuffle ^^load-literal ;

:: ^blend-vector ( mask true false rep -- dst )
    true mask rep ^^and-vector
    mask false rep ^^andn-vector
    rep ^^or-vector ;

: ^not-vector ( src rep -- dst )
    {
        [ ^^not-vector ]
        [ [ ^^fill-vector ] [ ^^xor-vector ] bi ]
    } v-vector-op ;

:: ^swap-compare-vector ( src1 src2 rep {cc,swap} -- dst )
    {cc,swap} first2 :> ( cc swap? )
    swap?
    [ src2 src1 rep cc ^^compare-vector ]
    [ src1 src2 rep cc ^^compare-vector ] if ;

:: ^(compare-vector) ( src1 src2 rep orig-cc -- dst )
    rep orig-cc %compare-vector-ccs :> ( ccs not? )

    ccs empty?
    [ rep not? [ ^^fill-vector ] [ ^^zero-vector ] if ]
    [
        ccs unclip :> ( rest-ccs first-cc )
        src1 src2 rep first-cc ^swap-compare-vector :> first-dst

        rest-ccs first-dst
        [ [ src1 src2 rep ] dip ^swap-compare-vector rep ^^or-vector ]
        reduce

        not? [ rep ^not-vector ] when
    ] if ;

:: ^minmax-compare-vector ( src1 src2 rep cc -- dst )
    cc order-cc {
        { cc<  [ src1 src2 rep ^^max-vector src1 rep cc/= ^(compare-vector) ] }
        { cc<= [ src1 src2 rep ^^min-vector src1 rep cc=  ^(compare-vector) ] }
        { cc>  [ src1 src2 rep ^^min-vector src1 rep cc/= ^(compare-vector) ] }
        { cc>= [ src1 src2 rep ^^max-vector src1 rep cc=  ^(compare-vector) ] }
    } case ;

: ^compare-vector ( src1 src2 rep cc -- dst )
    {
        [ ^(compare-vector) ]
        [ ^minmax-compare-vector ]
        { unsigned-int-vector-rep [| src1 src2 rep cc |
            rep sign-bit-mask ^^load-literal :> sign-bits
            src1 sign-bits rep ^^xor-vector
            src2 sign-bits rep ^^xor-vector
            rep signed-rep cc ^(compare-vector)
        ] }
    } vv-cc-vector-op ;

: ^unpack-vector-head ( src rep -- dst )
    {
        [ ^^unpack-vector-head ]
        { unsigned-int-vector-rep [ [ ^^zero-vector ] [ ^^merge-vector-head ] bi ] }
        { signed-int-vector-rep [| src rep |
            src src rep ^^merge-vector-head :> merged
            rep rep-component-type heap-size 8 * :> bits
            merged bits rep widen-vector-rep ^^shr-vector-imm
        ] }
        { signed-int-vector-rep [| src rep |
            rep ^^zero-vector :> zero
            zero src rep cc> ^compare-vector :> sign
            src sign rep ^^merge-vector-head
        ] }
    } v-vector-op ;

: ^unpack-vector-tail ( src rep -- dst )
    {
        [ ^^unpack-vector-tail ]
        [ [ ^^tail>head-vector ] [ ^^unpack-vector-head ] bi ]
        { unsigned-int-vector-rep [ [ ^^zero-vector ] [ ^^merge-vector-tail ] bi ] }
        { signed-int-vector-rep [| src rep |
            src src rep ^^merge-vector-tail :> merged
            rep rep-component-type heap-size 8 * :> bits
            merged bits rep widen-vector-rep ^^shr-vector-imm
        ] }
        { signed-int-vector-rep [| src rep |
            rep ^^zero-vector :> zero
            zero src rep cc> ^compare-vector :> sign
            src sign rep ^^merge-vector-tail
        ] }
    } v-vector-op ;

PREDICATE: fixnum-vector-rep < int-vector-rep
    rep-component-type heap-size cell < ;

: ^(sum-vector-2) ( src rep -- dst )
    {
        [ dupd ^^horizontal-add-vector ]
        [| src rep |
            src src rep ^^merge-vector-head :> head
            src src rep ^^merge-vector-tail :> tail
            head tail rep ^^add-vector
        ]
    } v-vector-op ;

: ^(sum-vector-4) ( src rep -- dst )
    {
        [
            [ dupd ^^horizontal-add-vector ]
            [ dupd ^^horizontal-add-vector ] bi
        ]
        [| src rep |
            src src rep ^^merge-vector-head :> head
            src src rep ^^merge-vector-tail :> tail
            head tail rep ^^add-vector :> src'

            rep widen-vector-rep :> rep'
            src' src' rep' ^^merge-vector-head :> head'
            src' src' rep' ^^merge-vector-tail :> tail'
            head' tail' rep ^^add-vector
        ]
    } v-vector-op ;

: ^(sum-vector-8) ( src rep -- dst )
    {
        [
            [ dupd ^^horizontal-add-vector ]
            [ dupd ^^horizontal-add-vector ]
            [ dupd ^^horizontal-add-vector ] tri
        ]
        [| src rep |
            src src rep ^^merge-vector-head :> head
            src src rep ^^merge-vector-tail :> tail
            head tail rep ^^add-vector :> src'

            rep widen-vector-rep :> rep'
            src' src' rep' ^^merge-vector-head :> head'
            src' src' rep' ^^merge-vector-tail :> tail'
            head' tail' rep ^^add-vector :> src''

            rep' widen-vector-rep :> rep''
            src'' src'' rep'' ^^merge-vector-head :> head''
            src'' src'' rep'' ^^merge-vector-tail :> tail''
            head'' tail'' rep ^^add-vector
        ]
    } v-vector-op ;

: ^(sum-vector-16) ( src rep -- dst )
    {
        [
            {
                [ dupd ^^horizontal-add-vector ]
                [ dupd ^^horizontal-add-vector ]
                [ dupd ^^horizontal-add-vector ]
                [ dupd ^^horizontal-add-vector ]
            } cleave
        ]
        [| src rep |
            src src rep ^^merge-vector-head :> head
            src src rep ^^merge-vector-tail :> tail
            head tail rep ^^add-vector :> src'

            rep widen-vector-rep :> rep'
            src' src' rep' ^^merge-vector-head :> head'
            src' src' rep' ^^merge-vector-tail :> tail'
            head' tail' rep ^^add-vector :> src''

            rep' widen-vector-rep :> rep''
            src'' src'' rep'' ^^merge-vector-head :> head''
            src'' src'' rep'' ^^merge-vector-tail :> tail''
            head'' tail'' rep ^^add-vector :> src'''

            rep'' widen-vector-rep :> rep'''
            src''' src''' rep''' ^^merge-vector-head :> head'''
            src''' src''' rep''' ^^merge-vector-tail :> tail'''
            head''' tail''' rep ^^add-vector
        ]
    } v-vector-op ;

: ^(sum-vector) ( src rep -- dst )
    [
        dup rep-length {
            {  2 [ ^(sum-vector-2) ] }
            {  4 [ ^(sum-vector-4) ] }
            {  8 [ ^(sum-vector-8) ] }
            { 16 [ ^(sum-vector-16) ] }
        } case
    ] [ ^^vector>scalar ] bi ;

: ^sum-vector ( src rep -- dst )
    {
        { float-vector-rep [ ^(sum-vector) ] }
        { fixnum-vector-rep [| src rep |
            src rep ^unpack-vector-head :> head
            src rep ^unpack-vector-tail :> tail
            rep widen-vector-rep :> wide-rep
            head tail wide-rep ^^add-vector wide-rep
            ^(sum-vector)
        ] }
    } v-vector-op ;

: shuffle? ( obj -- ? ) { [ array? ] [ [ integer? ] all? ] } 1&& ;

: ^shuffle-vector-imm ( src1 shuffle rep -- dst )
    [ rep-length 0 pad-tail ] keep {
        [ ^^shuffle-vector-imm ]
        [ [ ^load-immediate-shuffle ] [ ^^shuffle-vector ] bi ]
    } vl-vector-op ;

: ^shuffle-2-vectors-imm ( src1 src2 shuffle rep -- dst )
    [ rep-length 0 pad-tail ] keep {
        { double-2-rep [| src1 src2 shuffle rep |
            shuffle first2 [ 4 mod ] bi@ :> ( i j )
            {
                { [ i j [ 2 < ] both? ] [
                    src1 shuffle rep ^shuffle-vector-imm
                ] }
                { [ i j [ 2 >= ] both? ] [
                    src2 shuffle [ 2 - ] map rep ^shuffle-vector-imm
                ] }
                { [ i 2 < ] [
                    src1 src2 i j 2 - 2array rep ^^shuffle-vector-halves-imm
                ] }
                ! [ j 2 < ]
                [ src2 src1 i 2 - j 2array rep ^^shuffle-vector-halves-imm ]
            } cond
        ] }
    } vvl-vector-op ;

: ^broadcast-vector ( src n rep -- dst )
    [ rep-length swap <array> ] keep
    ^shuffle-vector-imm ;

: ^with-vector ( src rep -- dst )
    [ ^^scalar>vector ] keep [ 0 ] dip ^broadcast-vector ;

: ^select-vector ( src n rep -- dst )
    {
        [ ^^select-vector ]
        [ [ ^broadcast-vector ] keep ^^vector>scalar ]
    } vl-vector-op ;

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
        { float-vector-rep [ [ ^load-neg-zero-vector swap ] [ ^^sub-vector ] bi ] }
        { int-vector-rep   [ [ ^^zero-vector         swap ] [ ^^sub-vector ] bi ] }
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

: emit-simd-v*high ( node -- )
    {
        [ ^^mul-high-vector ]
    } emit-vv-vector-op ;

: emit-simd-v*hs+ ( node -- )
    {
        [ ^^mul-horizontal-add-vector ]
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

: emit-simd-vavg ( node -- )
    {
        [ ^^avg-vector ]
        { float-vector-rep [| src1 src2 rep |
            src1 src2 rep ^^add-vector
            rep ^load-half-vector rep ^^mul-vector
        ] }
    } emit-vv-vector-op ;

: emit-simd-vdot ( node -- )
    {
        [ ^^dot-vector ]
        { float-vector-rep [ [ ^^mul-vector ] [ ^sum-vector ] bi ] }
    } emit-vv-vector-op ;

: emit-simd-vsad ( node -- )
    {
        [
            [ ^^sad-vector dup { 2 3 0 1 } int-4-rep ^^shuffle-vector-imm int-4-rep ^^add-vector ]
            [ widen-vector-rep ^^vector>scalar ] bi
        ]
    } emit-vv-vector-op ;

: emit-simd-vsqrt ( node -- )
    {
        [ ^^sqrt-vector ]
    } emit-v-vector-op ;

: emit-simd-sum ( node -- )
    {
        [ ^sum-vector ]
    } emit-v-vector-op ;

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
        [ ^not-vector ]
    } emit-v-vector-op ;

: emit-simd-vlshift ( node -- )
    {
        [ ^^shl-vector ]
    } {
        [ ^^shl-vector-imm ]
    } [ integer? ] emit-vv-or-vl-vector-op ;

: emit-simd-vrshift ( node -- )
    {
        [ ^^shr-vector ]
    } {
        [ ^^shr-vector-imm ]
    } [ integer? ] emit-vv-or-vl-vector-op ;

: emit-simd-hlshift ( node -- )
    {
        [ ^^horizontal-shl-vector-imm ]
    } [ integer? ] emit-vl-vector-op ;

: emit-simd-hrshift ( node -- )
    {
        [ ^^horizontal-shr-vector-imm ]
    } [ integer? ] emit-vl-vector-op ;

: emit-simd-vshuffle-elements ( node -- )
    {
        [ ^shuffle-vector-imm ]
    } [ shuffle? ] emit-vl-vector-op ;

: emit-simd-vshuffle2-elements ( node -- )
    {
        [ ^shuffle-2-vectors-imm ]
    } [ shuffle? ] emit-vvl-vector-op ;

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
    {
        [ cc<= ^compare-vector ]
    } emit-vv-vector-op ;
: emit-simd-v< ( node -- )
    {
        [ cc< ^compare-vector ]
    } emit-vv-vector-op ;
: emit-simd-v= ( node -- )
    {
        [ cc=  ^compare-vector ]
    } emit-vv-vector-op ;
: emit-simd-v> ( node -- )
    {
        [ cc>  ^compare-vector ]
    } emit-vv-vector-op ;
: emit-simd-v>= ( node -- )
    {
        [ cc>= ^compare-vector ]
    } emit-vv-vector-op ;
: emit-simd-vunordered? ( node -- )
    {
        [ cc/<>= ^compare-vector ]
    } emit-vv-vector-op ;

: emit-simd-vany? ( node -- )
    {
        [ vcc-any ^^test-vector ]
    } emit-v-vector-op ;
: emit-simd-vall? ( node -- )
    {
        [ vcc-all ^^test-vector ]
    } emit-v-vector-op ;
: emit-simd-vnone? ( node -- )
    {
        [ vcc-none ^^test-vector ]
    } emit-v-vector-op ;
: emit-simd-vgetmask ( node -- )
    {
        [ ^^move-vector-mask ]
    } emit-v-vector-op ;

: emit-simd-v>float ( node -- )
    {
        { float-vector-rep [ drop ] }
        { int-vector-rep [ ^^integer>float-vector ] }
    } emit-v-vector-op ;

: emit-simd-v>integer ( node -- )
    {
        { float-vector-rep [ ^^float>integer-vector ] }
        { int-vector-rep [ drop ] }
    } emit-v-vector-op ;

: emit-simd-vpack-signed ( node -- )
    {
        { double-2-rep [| src1 src2 rep |
            src1 double-2-rep ^^float-pack-vector :> dst-head
            src2 double-2-rep ^^float-pack-vector :> dst-tail
            dst-head dst-tail { 0 1 0 1 } float-4-rep ^^shuffle-vector-halves-imm
        ] }
        { int-vector-rep [ ^^signed-pack-vector ] }
    } emit-vv-vector-op ;

: emit-simd-vpack-unsigned ( node -- )
    {
        [ ^^unsigned-pack-vector ]
    } emit-vv-vector-op ;

: emit-simd-vunpack-head ( node -- )
    {
        [ ^unpack-vector-head ]
    } emit-v-vector-op ;

: emit-simd-vunpack-tail ( node -- )
    {
        [ ^unpack-vector-tail ]
    } emit-v-vector-op ;

: emit-simd-with ( node -- )
    {
        { fixnum-vector-rep [ ^with-vector ] }
        { float-vector-rep  [ ^with-vector ] }
    } emit-v-vector-op ;

: emit-simd-gather-2 ( node -- )
    {
        { fixnum-vector-rep [ ^^gather-int-vector-2 ] }
        { fixnum-vector-rep [ ^^gather-vector-2 ] }
        { float-vector-rep  [ ^^gather-vector-2 ] }
    } emit-vv-vector-op ;

: emit-simd-gather-4 ( node -- )
    {
        { fixnum-vector-rep [ ^^gather-int-vector-4 ] }
        { fixnum-vector-rep [ ^^gather-vector-4 ] }
        { float-vector-rep  [ ^^gather-vector-4 ] }
    } emit-vvvv-vector-op ;

: emit-simd-select ( node -- )
    {
        { fixnum-vector-rep [ ^select-vector ] }
        { float-vector-rep  [ ^select-vector ] }
    } [ integer? ] emit-vl-vector-op ;

: emit-alien-vector ( block node -- block' )
    dup [
        '[
            ds-drop prepare-load-memory
            _ f ^^load-memory-imm ds-push
        ]
        [ inline-load-memory? ] inline-accessor
    ] with { [ %alien-vector-reps member? ] } if-literals-match ;

: emit-set-alien-vector ( block node -- block' )
    dup [
        '[
            ds-drop prepare-store-memory
            _ f ##store-memory-imm,
        ]
        [ byte-array inline-store-memory? ] inline-accessor
    ] with { [ %alien-vector-reps member? ] } if-literals-match ;

: enable-simd ( -- )
    {
        { (simd-v+)                 [ emit-simd-v+                  ] }
        { (simd-v-)                 [ emit-simd-v-                  ] }
        { (simd-vneg)               [ emit-simd-vneg                ] }
        { (simd-v+-)                [ emit-simd-v+-                 ] }
        { (simd-vs+)                [ emit-simd-vs+                 ] }
        { (simd-vs-)                [ emit-simd-vs-                 ] }
        { (simd-vs*)                [ emit-simd-vs*                 ] }
        { (simd-v*)                 [ emit-simd-v*                  ] }
        { (simd-v*high)             [ emit-simd-v*high              ] }
        { (simd-v*hs+)              [ emit-simd-v*hs+               ] }
        { (simd-v/)                 [ emit-simd-v/                  ] }
        { (simd-vmin)               [ emit-simd-vmin                ] }
        { (simd-vmax)               [ emit-simd-vmax                ] }
        { (simd-vavg)               [ emit-simd-vavg                ] }
        { (simd-vdot)               [ emit-simd-vdot                ] }
        { (simd-vsad)               [ emit-simd-vsad                ] }
        { (simd-vsqrt)              [ emit-simd-vsqrt               ] }
        { (simd-sum)                [ emit-simd-sum                 ] }
        { (simd-vabs)               [ emit-simd-vabs                ] }
        { (simd-vbitand)            [ emit-simd-vand                ] }
        { (simd-vbitandn)           [ emit-simd-vandn               ] }
        { (simd-vbitor)             [ emit-simd-vor                 ] }
        { (simd-vbitxor)            [ emit-simd-vxor                ] }
        { (simd-vbitnot)            [ emit-simd-vnot                ] }
        { (simd-vand)               [ emit-simd-vand                ] }
        { (simd-vandn)              [ emit-simd-vandn               ] }
        { (simd-vor)                [ emit-simd-vor                 ] }
        { (simd-vxor)               [ emit-simd-vxor                ] }
        { (simd-vnot)               [ emit-simd-vnot                ] }
        { (simd-vlshift)            [ emit-simd-vlshift             ] }
        { (simd-vrshift)            [ emit-simd-vrshift             ] }
        { (simd-hlshift)            [ emit-simd-hlshift             ] }
        { (simd-hrshift)            [ emit-simd-hrshift             ] }
        { (simd-vshuffle-elements)  [ emit-simd-vshuffle-elements   ] }
        { (simd-vshuffle2-elements) [ emit-simd-vshuffle2-elements  ] }
        { (simd-vshuffle-bytes)     [ emit-simd-vshuffle-bytes      ] }
        { (simd-vmerge-head)        [ emit-simd-vmerge-head         ] }
        { (simd-vmerge-tail)        [ emit-simd-vmerge-tail         ] }
        { (simd-v<=)                [ emit-simd-v<=                 ] }
        { (simd-v<)                 [ emit-simd-v<                  ] }
        { (simd-v=)                 [ emit-simd-v=                  ] }
        { (simd-v>)                 [ emit-simd-v>                  ] }
        { (simd-v>=)                [ emit-simd-v>=                 ] }
        { (simd-vunordered?)        [ emit-simd-vunordered?         ] }
        { (simd-vany?)              [ emit-simd-vany?               ] }
        { (simd-vall?)              [ emit-simd-vall?               ] }
        { (simd-vnone?)             [ emit-simd-vnone?              ] }
        { (simd-v>float)            [ emit-simd-v>float             ] }
        { (simd-v>integer)          [ emit-simd-v>integer           ] }
        { (simd-vpack-signed)       [ emit-simd-vpack-signed        ] }
        { (simd-vpack-unsigned)     [ emit-simd-vpack-unsigned      ] }
        { (simd-vunpack-head)       [ emit-simd-vunpack-head        ] }
        { (simd-vunpack-tail)       [ emit-simd-vunpack-tail        ] }
        { (simd-with)               [ emit-simd-with                ] }
        { (simd-gather-2)           [ emit-simd-gather-2            ] }
        { (simd-gather-4)           [ emit-simd-gather-4            ] }
        { (simd-select)             [ emit-simd-select              ] }
        { alien-vector              [ emit-alien-vector             ] }
        { set-alien-vector          [ emit-set-alien-vector         ] }
        { (simd-positive)           [ drop                          ] }
        { (simd-vgetmask)           [ emit-simd-vgetmask            ] }
    } enable-intrinsics ;

enable-simd
