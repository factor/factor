! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math.parser fry sequences kernel assocs hashtables ;
IN: benchmark.gc3

: gc3-benchmark ( -- )
    1000000 <iota>
    1000000 <hashtable>
    '[ [ number>string ] keep _ set-at ] each ;

MAIN: gc3-benchmark
