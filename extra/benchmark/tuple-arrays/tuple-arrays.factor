! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions tuple-arrays accessors fry sequences
prettyprint ;
IN: benchmark.tuple-arrays

TUPLE: point { x float } { y float } { z float } ; final

TUPLE-ARRAY: point

: tuple-arrays-benchmark ( -- )
    100 iota [
        drop 5000 <point-array> [
            [ 1 + ] change-x
            [ 1 - ] change-y
            [ 1 + 2 / ] change-z
        ] map [ z>> ] map-sum
    ] map-sum . ;

MAIN: tuple-arrays-benchmark
