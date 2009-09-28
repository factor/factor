! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data assocs combinators
cpu.architecture fry generalizations kernel libc macros math
sequences effects accessors namespaces lexer parser vocabs.parser
words arrays math.vectors ;
IN: math.vectors.simd.intrinsics

ERROR: bad-simd-call ;

<<

: simd-effect ( word -- effect )
    stack-effect [ in>> "rep" suffix ] [ out>> ] bi <effect> ;

SYMBOL: simd-ops

V{ } clone simd-ops set-global

SYNTAX: SIMD-OP:
    scan-word dup name>> "(simd-" ")" surround create-in
    [ nip [ bad-simd-call ] define ]
    [ [ simd-effect ] dip set-stack-effect ]
    [ 2array simd-ops get push ]
    2tri ;

>>

SIMD-OP: v+
SIMD-OP: v-
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
SIMD-OP: vlshift
SIMD-OP: vrshift
SIMD-OP: hlshift
SIMD-OP: hrshift
SIMD-OP: vshuffle

: (simd-broadcast) ( x rep -- v ) bad-simd-call ;
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

M: vector-rep supported-simd-op?
    {
        { \ (simd-v+)        [ %add-vector-reps            ] }
        { \ (simd-vs+)       [ %saturated-add-vector-reps  ] }
        { \ (simd-v+-)       [ %add-sub-vector-reps        ] }
        { \ (simd-v-)        [ %sub-vector-reps            ] }
        { \ (simd-vs-)       [ %saturated-sub-vector-reps  ] }
        { \ (simd-v*)        [ %mul-vector-reps            ] }
        { \ (simd-vs*)       [ %saturated-mul-vector-reps  ] }
        { \ (simd-v/)        [ %div-vector-reps            ] }
        { \ (simd-vmin)      [ %min-vector-reps            ] }
        { \ (simd-vmax)      [ %max-vector-reps            ] }
        { \ (simd-v.)        [ %dot-vector-reps            ] }
        { \ (simd-vsqrt)     [ %sqrt-vector-reps           ] }
        { \ (simd-sum)       [ %horizontal-add-vector-reps ] }
        { \ (simd-vabs)      [ %abs-vector-reps            ] }
        { \ (simd-vbitand)   [ %and-vector-reps            ] }
        { \ (simd-vbitandn)  [ %andn-vector-reps           ] }
        { \ (simd-vbitor)    [ %or-vector-reps             ] }
        { \ (simd-vbitxor)   [ %xor-vector-reps            ] }
        { \ (simd-vlshift)   [ %shl-vector-reps            ] }
        { \ (simd-vrshift)   [ %shr-vector-reps            ] }
        { \ (simd-hlshift)   [ %horizontal-shl-vector-reps ] }
        { \ (simd-hrshift)   [ %horizontal-shr-vector-reps ] }
        { \ (simd-vshuffle)  [ %shuffle-vector-reps        ] }
        { \ (simd-broadcast) [ %broadcast-vector-reps      ] }
        { \ (simd-gather-2)  [ %gather-vector-2-reps       ] }
        { \ (simd-gather-4)  [ %gather-vector-4-reps       ] }
        { \ (simd-select)    [ %select-vector-reps         ] }
    } case member? ;
