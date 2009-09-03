! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays combinators
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
            { single-float-rep [ float ] }
            { double-float-rep [ float ] }
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
