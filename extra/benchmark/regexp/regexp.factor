! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.parser regexp sequences strings ;
IN: benchmark.regexp

: regexp-benchmark ( -- )
    200
    20,000 <iota> [ number>string ] map
    200 <iota> [ 1 + CHAR: a <string> ] map
    '[
        _ R/ \d+/ [ matches? ] curry all? t assert=
        _ R/ [a]+/ [ matches? ] curry all? t assert=
    ] times ;

MAIN: regexp-benchmark
