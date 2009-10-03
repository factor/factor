! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays combinators fry sequences
compiler.tree.propagation.info cpu.architecture kernel words math
math.intervals math.vectors.simd.intrinsics ;
IN: compiler.tree.propagation.simd

{
    (simd-v+)
    (simd-v-)
    (simd-v+-)
    (simd-v*)
    (simd-v/)
    (simd-vmin)
    (simd-vmax)
    (simd-sum)
    (simd-vabs)
    (simd-vsqrt)
    (simd-vbitand)
    (simd-vbitandn)
    (simd-vbitor)
    (simd-vbitxor)
    (simd-vbitnot)
    (simd-vand)
    (simd-vandn)
    (simd-vor)
    (simd-vxor)
    (simd-vnot)
    (simd-vlshift)
    (simd-vrshift)
    (simd-hlshift)
    (simd-hrshift)
    (simd-vshuffle)
    (simd-v=)
    (simd-with)
    (simd-gather-2)
    (simd-gather-4)
    alien-vector
} [ { byte-array } "default-output-classes" set-word-prop ] each

: scalar-output-class ( rep -- class )
    dup literal?>> [
        literal>> scalar-rep-of {
            { float-rep [ float ] }
            { double-rep [ float ] }
            [ drop integer ]
        } case
    ] [ drop real ] if
    <class-info> ;

\ (simd-sum) [ nip scalar-output-class ] "outputs" set-word-prop

\ (simd-v.) [ 2nip scalar-output-class ] "outputs" set-word-prop

{
    (simd-vany?)
    (simd-vall?)
    (simd-vnone?)
} [ { boolean } "default-output-classes" set-word-prop ] each

\ (simd-select) [ 2nip scalar-output-class ] "outputs" set-word-prop

\ assert-positive [
    real [0,inf] <class/interval-info> value-info-intersect
] "outputs" set-word-prop

! If SIMD is not available, inline alien-vector and set-alien-vector
! to get a speedup
: inline-unless-intrinsic ( word -- )
    dup '[ drop _ dup "intrinsic" word-prop [ drop f ] [ def>> ] if ]
    "custom-inlining" set-word-prop ;

\ alien-vector inline-unless-intrinsic

\ set-alien-vector inline-unless-intrinsic
