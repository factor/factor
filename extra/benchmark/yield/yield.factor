! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.
USING: math threads ;
IN: benchmark.yield

: yield-benchmark ( -- )
    100,000 [ yield ] times ;

MAIN: yield-benchmark
