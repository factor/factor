! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: decimals kernel locals math math.combinatorics math.ranges
sequences ;
IN: benchmark.e-decimals

: D-factorial ( n -- D! )
    D: 1 [ 0 <decimal> D: 1 D+ D* ] reduce ; inline

:: calculate-e-decimals ( n -- e )
    n [1,b] D: 1
    [ D-factorial D: 1 swap n D/ D+ ] reduce ;

: calculate-e-decimals-benchmark ( -- )
    5 [ 800 calculate-e-decimals drop ] times ;

MAIN: calculate-e-decimals-benchmark
