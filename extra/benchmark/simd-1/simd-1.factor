! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel io math math.functions math.parser math.vectors
math.vectors.simd sequences specialized-arrays ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: float-4
IN: benchmark.simd-1

: <point> ( n -- float-4 )
    >float [ sin ] [ cos 3 * ] [ sin sq 2 / ] tri
    0.0 float-4-boa ; inline

: make-points ( len -- points )
    iota [ <point> ] float-4-array{ } map-as ; inline

: normalize-points ( points -- )
    [ normalize ] map! drop ; inline

: max-points ( points -- point )
    [ ] [ vmax ] map-reduce ; inline

: print-point ( point -- )
    [ number>string ] { } map-as ", " join print ; inline

: simd-benchmark ( len -- )
    >fixnum make-points [ normalize-points ] [ max-points ] bi print-point ;

: main ( -- )
    10 [ 500000 simd-benchmark ] times ;

MAIN: main
