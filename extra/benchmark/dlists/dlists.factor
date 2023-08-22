! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: deques dlists kernel math sequences ;
IN: benchmark.dlists

: dlists-benchmark ( -- )
    5,000 <iota> [
        [ <iota> 0 swap >dlist [ + ] slurp-deque ]
        [ dup 1 - * 2 / ] bi assert=
    ] each ;

MAIN: dlists-benchmark
