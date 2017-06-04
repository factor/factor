! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: decimals kernel locals math math.combinatorics math.ranges
sequences ;
IN: benchmark.e-decimals

: D-factorial ( n -- D! )
    <iota> decimal: 1 [ 0 <decimal> decimal: 1 D+ D* ] reduce ; inline

:: calculate-e-decimals ( n -- e )
    n [1,b] decimal: 1
    [ D-factorial decimal: 1 swap n D/ D+ ] reduce ;

: e-decimals-benchmark ( -- )
    5 [ 800 calculate-e-decimals drop ] times ;

MAIN: e-decimals-benchmark
