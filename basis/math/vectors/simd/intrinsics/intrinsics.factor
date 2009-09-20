! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data assocs combinators
cpu.architecture fry generalizations kernel libc macros math
sequences ;
IN: math.vectors.simd.intrinsics

ERROR: bad-simd-call ;

: (simd-v+) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-v+-) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-v-) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-v*) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-v/) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-vmin) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-vmax) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-vsqrt) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-sum) ( v1 rep -- v2 ) bad-simd-call ;
: (simd-broadcast) ( x rep -- v ) bad-simd-call ;
: (simd-gather-2) ( a b rep -- v ) bad-simd-call ;
: (simd-gather-4) ( a b c d rep -- v ) bad-simd-call ;
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
        { \ (simd-v+-)       [ %add-sub-vector-reps        ] }
        { \ (simd-v-)        [ %sub-vector-reps            ] }
        { \ (simd-v*)        [ %mul-vector-reps            ] }
        { \ (simd-v/)        [ %div-vector-reps            ] }
        { \ (simd-vmin)      [ %min-vector-reps            ] }
        { \ (simd-vmax)      [ %max-vector-reps            ] }
        { \ (simd-vsqrt)     [ %sqrt-vector-reps           ] }
        { \ (simd-sum)       [ %horizontal-add-vector-reps ] }
        { \ (simd-broadcast) [ %broadcast-vector-reps      ] }
        { \ (simd-gather-2)  [ %gather-vector-2-reps       ] }
        { \ (simd-gather-4)  [ %gather-vector-4-reps       ] }
    } case member? ;
