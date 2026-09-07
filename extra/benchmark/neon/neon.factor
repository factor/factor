! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.arm.64.features io kernel math math.vectors math.vectors.simd
namespaces prettyprint sequences tools.time ;
IN: benchmark.neon

: dot-loop ( n -- result )
    0 int-4-with swap [
        char-16{ 1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8 }
        char-16{ 8 7 6 5 4 3 2 1 8 7 6 5 4 3 2 1 }
        rot vdot4+
    ] times ;
: matrix-loop ( n -- result )
    0 int-4-with swap [
        1 char-16-with 2 char-16-with rot vmatmul2x8+
    ] times ;
: half-loop ( n -- result )
    1 half-8-with swap [
        0.5 half-8-with 0.5 half-8-with vfma
    ] times ;
: bfloat-loop ( n -- result )
    0 float-4-with swap [
        1 bfloat-8-with 0.5 bfloat-8-with rot vbdot2+
    ] times ;

: measure-neon ( -- )
    "dot4" print [ 10000 dot-loop . ] time
    "integer matrix" print [ 10000 matrix-loop . ] time
    "half FMA" print [ 10000 half-loop . ] time
    "BF16 dot2" print [ 10000 bfloat-loop . ] time ;

: neon-benchmark ( -- )
    "Available ARM64 extensions:" print arm64-features .
    "Runtime dispatch:" print measure-neon
    "Optional extensions disabled:" print
    optional-arm64-features disabled-arm64-features [ measure-neon ] with-variable ;

MAIN: neon-benchmark
