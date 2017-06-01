! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.parser sequences wrap wrap.strings ;
IN: benchmark.wrap

: wrap-benchmark ( -- )
    1,000 <iota> [ number>string ] map " " join
    100 [ dup 80 wrap-string drop ] times drop ;

MAIN: wrap-benchmark
