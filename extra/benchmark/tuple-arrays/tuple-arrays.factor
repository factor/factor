! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math sequences tuple-arrays ;
IN: benchmark.tuple-arrays

TUPLE: point { x float } { y float } { z float } ; final

TUPLE-ARRAY: point

: tuple-arrays-benchmark ( -- )
    1,000 <iota> [
        drop 5,000 <point-array> [
            [ 1 + ] change-x
            [ 1 - ] change-y
            [ 1 + 2 / ] change-z
        ] map [ z>> ] map-sum
    ] map-sum 0x1.312dp21 assert= ;

MAIN: tuple-arrays-benchmark
