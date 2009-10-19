! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data assocs combinators
cpu.architecture compiler.cfg.comparisons fry generalizations
kernel libc macros math
math.vectors.conversion.backend
sequences sets effects accessors namespaces
lexer parser vocabs.parser words arrays math.vectors ;
IN: math.vectors.simd.intrinsics

ERROR: bad-simd-call word ;

<<

: simd-effect ( word -- effect )
    stack-effect [ in>> "rep" suffix ] [ out>> ] bi <effect> ;
: simd-conversion-effect ( word -- effect )
    stack-effect [ in>> but-last "rep" suffix ] [ out>> ] bi <effect> ;

SYMBOL: simd-ops

V{ } clone simd-ops set-global

: (SIMD-OP:) ( accum quot -- accum )
    [
        scan-word dup name>> "(simd-" ")" surround create-in
        [ nip dup '[ _ bad-simd-call ] define ]
    ] dip
    '[ _ dip set-stack-effect ]
    [ 2array simd-ops get push ]
    2tri ; inline

SYNTAX: SIMD-OP:
    [ simd-effect ] (SIMD-OP:) ;

SYNTAX: SIMD-CONVERSION-OP:
    [ simd-conversion-effect ] (SIMD-OP:) ;

>>

SIMD-OP: v+
SIMD-OP: v-
SIMD-OP: vneg
SIMD-OP: v+-
SIMD-OP: vs+
SIMD-OP: vs-
SIMD-OP: vs*
SIMD-OP: v*
SIMD-OP: v/
SIMD-OP: vmin
SIMD-OP: vmax
SIMD-OP: v.
SIMD-OP: vsqrt
SIMD-OP: sum
SIMD-OP: vabs
SIMD-OP: vbitand
SIMD-OP: vbitandn
SIMD-OP: vbitor
SIMD-OP: vbitxor
SIMD-OP: vbitnot
SIMD-OP: vand
SIMD-OP: vandn
SIMD-OP: vor
SIMD-OP: vxor
SIMD-OP: vnot
SIMD-OP: vlshift
SIMD-OP: vrshift
SIMD-OP: hlshift
SIMD-OP: hrshift
SIMD-OP: vshuffle-elements
SIMD-OP: vshuffle-bytes
SIMD-OP: (vmerge-head)
SIMD-OP: (vmerge-tail)
SIMD-OP: v<=
SIMD-OP: v<
SIMD-OP: v=
SIMD-OP: v>
SIMD-OP: v>=
SIMD-OP: vunordered?
SIMD-OP: vany?
SIMD-OP: vall?
SIMD-OP: vnone?

SIMD-CONVERSION-OP: (v>float)
SIMD-CONVERSION-OP: (v>integer)
SIMD-CONVERSION-OP: (vpack-signed)
SIMD-CONVERSION-OP: (vpack-unsigned)
SIMD-CONVERSION-OP: (vunpack-head)
SIMD-CONVERSION-OP: (vunpack-tail)

: (simd-with) ( x rep -- v ) bad-simd-call ;
: (simd-gather-2) ( a b rep -- v ) bad-simd-call ;
: (simd-gather-4) ( a b c d rep -- v ) bad-simd-call ;
: (simd-select) ( v n rep -- x ) bad-simd-call ;

: assert-positive ( x -- y ) ;

: alien-vector ( c-ptr n rep -- value )
    ! Inefficient version for when intrinsics are missing
    [ swap <displaced-alien> ] dip rep-size memory>byte-array ;

: set-alien-vector ( value c-ptr n rep -- )
    ! Inefficient version for when intrinsics are missing
    [ swap <displaced-alien> swap ] dip rep-size memcpy ;

<<

: rep-components ( rep -- n )
    16 swap rep-component-type heap-size /i ; foldable

: rep-coercer ( rep -- quot )
    {
        { [ dup int-vector-rep? ] [ [ >fixnum ] ] }
        { [ dup float-vector-rep? ] [ [ >float ] ] }
    } cond nip ; foldable

: rep-coerce ( value rep -- value' )
    rep-coercer call( value -- value' ) ; inline

CONSTANT: rep-gather-words
    {
        { 2 (simd-gather-2) }
        { 4 (simd-gather-4) }
    }

: rep-gather-word ( rep -- word )
    rep-components rep-gather-words at ;

>>

MACRO: (simd-boa) ( rep -- quot )
    {
        [ rep-coercer ]
        [ rep-components ]
        [ ]
        [ rep-gather-word ]
    } cleave
    '[ _ _ napply _ _ execute ] ;

GENERIC# supported-simd-op? 1 ( rep intrinsic -- ? )

: (%unpack-reps) ( -- reps )
    %merge-vector-reps [ int-vector-rep? ] filter
    %unpack-vector-head-reps union ;

: (%abs-reps) ( -- reps )
    cc> %compare-vector-reps [ int-vector-rep? ] filter
    %xor-vector-reps [ float-vector-rep? ] filter
    union
    [ { } ] [ { uchar-16-rep ushort-8-rep uint-4-rep ulonglong-2-rep } union ] if-empty ;

: (%shuffle-imm-reps) ( -- reps )
    %shuffle-vector-reps %shuffle-vector-imm-reps union ;

M: vector-rep supported-simd-op?
    {
        { \ (simd-v+)            [ %add-vector-reps            ] }
        { \ (simd-vs+)           [ %saturated-add-vector-reps  ] }
        { \ (simd-v+-)           [ %add-sub-vector-reps        ] }
        { \ (simd-v-)            [ %sub-vector-reps            ] }
        { \ (simd-vs-)           [ %saturated-sub-vector-reps  ] }
        { \ (simd-vneg)          [ %sub-vector-reps            ] }
        { \ (simd-v*)            [ %mul-vector-reps            ] }
        { \ (simd-vs*)           [ %saturated-mul-vector-reps  ] }
        { \ (simd-v/)            [ %div-vector-reps            ] }
        { \ (simd-vmin)          [ %min-vector-reps            ] }
        { \ (simd-vmax)          [ %max-vector-reps            ] }
        { \ (simd-v.)            [ %dot-vector-reps            ] }
        { \ (simd-vsqrt)         [ %sqrt-vector-reps           ] }
        { \ (simd-sum)           [ %horizontal-add-vector-reps ] }
        { \ (simd-vabs)          [ (%abs-reps)                 ] }
        { \ (simd-vbitand)       [ %and-vector-reps            ] }
        { \ (simd-vbitandn)      [ %andn-vector-reps           ] }
        { \ (simd-vbitor)        [ %or-vector-reps             ] }
        { \ (simd-vbitxor)       [ %xor-vector-reps            ] }
        { \ (simd-vbitnot)       [ %xor-vector-reps            ] }
        { \ (simd-vand)          [ %and-vector-reps            ] }
        { \ (simd-vandn)         [ %andn-vector-reps           ] }
        { \ (simd-vor)           [ %or-vector-reps             ] }
        { \ (simd-vxor)          [ %xor-vector-reps            ] }
        { \ (simd-vnot)          [ %xor-vector-reps            ] }
        { \ (simd-vlshift)       [ %shl-vector-reps            ] }
        { \ (simd-vrshift)       [ %shr-vector-reps            ] }
        { \ (simd-hlshift)       [ %horizontal-shl-vector-reps ] }
        { \ (simd-hrshift)       [ %horizontal-shr-vector-reps ] }
        { \ (simd-vshuffle-elements) [ (%shuffle-imm-reps)         ] }
        { \ (simd-vshuffle-bytes)    [ %shuffle-vector-reps        ] }
        { \ (simd-(vmerge-head)) [ %merge-vector-reps          ] }
        { \ (simd-(vmerge-tail)) [ %merge-vector-reps          ] }
        { \ (simd-(v>float))        [ %integer>float-vector-reps ] }
        { \ (simd-(v>integer))      [ %float>integer-vector-reps ] }
        { \ (simd-(vpack-signed))   [ %signed-pack-vector-reps   ] }
        { \ (simd-(vpack-unsigned)) [ %unsigned-pack-vector-reps ] }
        { \ (simd-(vunpack-head))   [ (%unpack-reps)             ] }
        { \ (simd-(vunpack-tail))   [ (%unpack-reps)             ] }
        { \ (simd-v<=)           [ cc<= %compare-vector-reps   ] }
        { \ (simd-v<)            [ cc< %compare-vector-reps    ] }
        { \ (simd-v=)            [ cc= %compare-vector-reps    ] }
        { \ (simd-v>)            [ cc> %compare-vector-reps    ] }
        { \ (simd-v>=)           [ cc>= %compare-vector-reps   ] }
        { \ (simd-vunordered?)   [ cc/<>= %compare-vector-reps ] }
        { \ (simd-gather-2)      [ %gather-vector-2-reps       ] }
        { \ (simd-gather-4)      [ %gather-vector-4-reps       ] }
        { \ (simd-vany?)         [ %test-vector-reps           ] }
        { \ (simd-vall?)         [ %test-vector-reps           ] }
        { \ (simd-vnone?)        [ %test-vector-reps           ] }
    } case member? ;
