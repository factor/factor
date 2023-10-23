! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel io math math.functions math.parser math.vectors
math.vectors.simd sequences specialized-arrays ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: float-4
IN: benchmark.simd-1

: <point> ( n -- float-4 )
    >float [ sin ] [ cos 3 * ] [ sin sq 2 / ] tri
    0.0 float-4-boa ; inline

: make-points ( len -- points )
    <iota> [ <point> ] float-4-array{ } map-as ; inline

: normalize-points ( points -- )
    [ normalize ] map! drop ; inline

: print-point ( point -- )
    [ number>string ] { } map-as ", " join print ; inline

: simd-benchmark ( len -- )
    >fixnum make-points [ normalize-points ] [ vmaximum ] bi print-point ;

: simd-1-benchmark ( -- )
    10 [ 500000 simd-benchmark ] times ;

MAIN: simd-1-benchmark
