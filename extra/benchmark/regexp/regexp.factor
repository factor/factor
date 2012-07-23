! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.
USING: arrays fry kernel math math.parser regexp sequences
strings ;
IN: benchmark.regexp

: regexp-benchmark ( -- )
    200
    10,000 iota [ number>string ] map
    200 iota [ 1 + CHAR: a <string> ] map
    '[
        _ R/ \d+/ [ matches? ] curry all? t assert=
        _ R/ [a]+/ [ matches? ] curry all? t assert=
    ] times ;

MAIN: regexp-benchmark
