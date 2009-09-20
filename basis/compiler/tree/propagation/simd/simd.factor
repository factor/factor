! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays combinators fry
compiler.tree.propagation.info cpu.architecture kernel words math
math.intervals math.vectors.simd.intrinsics ;
IN: compiler.tree.propagation.simd

\ (simd-v+) { byte-array } "default-output-classes" set-word-prop

\ (simd-v-) { byte-array } "default-output-classes" set-word-prop

\ (simd-v*) { byte-array } "default-output-classes" set-word-prop

\ (simd-v/) { byte-array } "default-output-classes" set-word-prop

\ (simd-vmin) { byte-array } "default-output-classes" set-word-prop

\ (simd-vmax) { byte-array } "default-output-classes" set-word-prop

\ (simd-vsqrt) { byte-array } "default-output-classes" set-word-prop

\ (simd-sum) [
    nip dup literal?>> [
        literal>> scalar-rep-of {
            { float-rep [ float ] }
            { double-rep [ float ] }
            { int-rep [ integer ] }
        } case
    ] [ drop real ] if
    <class-info>
] "outputs" set-word-prop

\ (simd-broadcast) { byte-array } "default-output-classes" set-word-prop

\ (simd-gather-2) { byte-array } "default-output-classes" set-word-prop

\ (simd-gather-4) { byte-array } "default-output-classes" set-word-prop

\ assert-positive [
    real [0,inf] <class/interval-info> value-info-intersect
] "outputs" set-word-prop

\ alien-vector { byte-array } "default-output-classes" set-word-prop

! If SIMD is not available, inline alien-vector and set-alien-vector
! to get a speedup
: inline-unless-intrinsic ( word -- )
    dup '[ drop _ dup "intrinsic" word-prop [ drop f ] [ def>> ] if ]
    "custom-inlining" set-word-prop ;

\ alien-vector inline-unless-intrinsic

\ set-alien-vector inline-unless-intrinsic
