USING: accessors alien.c-types arrays byte-arrays compiler.cfg.intrinsics.simd
compiler.cfg.instructions compiler.cfg.value-numbering.folding
compiler.cfg.value-numbering.simd compiler.test cpu.architecture
kernel math math.vectors.simd.integer-only
math.vectors.simd.intrinsics math.vectors.simd.intrinsics.private
sequences specialized-arrays tools.test ;
SPECIALIZED-ARRAYS: int uint ;
IN: math.vectors.simd.integer-only.tests

! Integer vector execution and lowering are available in both VM modes.
{ { 2 4 6 8 } } [
    int-array{ 1 2 3 4 } underlying>> dup int-4-rep (simd-v+)
    int-4-rep byte>rep-array >array
] unit-test
{ { 2 4 6 8 } } [
    [ int-array{ 1 2 3 4 } underlying>> dup int-4-rep (simd-v+)
      int-4-rep byte>rep-array >array ] compile-call
] unit-test
{ t } [ int-4-rep representation-node \ (simd-v+) simd-intrinsic-allowed? ] unit-test

! Float representation bitwise execution remains an integer storage operation.
{ B{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 } } [
    B{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 }
    dup float-4-rep (simd-vbitxor)
] unit-test

floating-point-supported? [
    { t } [ float-4-rep representation-node \ (simd-v+) simd-intrinsic-allowed? ] unit-test
    { { 0x40000000 0x40000000 0x40000000 0x40000000 } } [
        uint-array{ 0x3f800000 0x3f800000 0x3f800000 0x3f800000 } underlying>>
        dup float-4-rep (simd-v+) uint-4-rep byte>rep-array >array
    ] unit-test
] [
    { f } [ float-4-rep representation-node \ (simd-v+) simd-intrinsic-allowed? ] unit-test
    { f } [ half-8-rep representation-node \ (simd-v+) simd-intrinsic-allowed? ] unit-test
    { f } [ int-4-rep representation-node \ (simd-v>float) simd-intrinsic-allowed? ] unit-test
    { f } [ opaque-one-reference float-4-rep scalar-literal? ] unit-test
    { f } [ T{ ##integer>float { dst 1 } { src 0 } } unary-constant-fold? ] unit-test
    [ B{ } B{ } float-4-rep (simd-v+) ] [ floating-point-unsupported? ] must-fail-with
    [ B{ } B{ } half-8-rep (simd-v+) ] [ floating-point-unsupported? ] must-fail-with
    [ B{ } B{ } bfloat-8-rep (simd-v+) ] [ floating-point-unsupported? ] must-fail-with
    [ B{ } B{ } double-2-rep (simd-v=) ] [ floating-point-unsupported? ] must-fail-with
    [ B{ } int-4-rep (simd-v>float) ] [ floating-point-unsupported? ] must-fail-with
    [ B{ } float-4-rep (simd-v>integer) ] [ floating-point-unsupported? ] must-fail-with
    [ B{ } "round" float-4-rep (simd-unary) ] [ floating-point-unsupported? ] must-fail-with
    [ B{ } B{ } B{ } float-4-rep (simd-vfma) ] [ floating-point-unsupported? ] must-fail-with
    [ [ B{ } B{ } float-4-rep (simd-v+) ] compile-call ]
    [ floating-point-unsupported? ] must-fail-with
    [ [ B{ } int-4-rep (simd-v>float) ] compile-call ]
    [ floating-point-unsupported? ] must-fail-with
] if
