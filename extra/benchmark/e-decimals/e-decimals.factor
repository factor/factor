! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: decimals kernel math ranges sequences ;
IN: benchmark.e-decimals

: D-factorial ( n -- D! )
    <iota> DECIMAL: 1 [ 0 <decimal> DECIMAL: 1 D+ D* ] reduce ; inline

:: calculate-e-decimals ( n -- e )
    n [1..b] DECIMAL: 1
    [ D-factorial DECIMAL: 1 swap n D/ D+ ] reduce ;

: e-decimals-benchmark ( -- )
    5 [ 800 calculate-e-decimals drop ] times ;

MAIN: e-decimals-benchmark
