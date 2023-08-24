! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel ranges math.parser sets sequences ;
IN: benchmark.beust1

: count-numbers ( max -- n )
    1 [a..b] [ number>string all-unique? ] count ; inline

: beust1-benchmark ( -- )
    2000000 count-numbers 229050 assert= ;

MAIN: beust1-benchmark
