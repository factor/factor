! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: benchmark.tcp-echo0 io ;
IN: benchmark.tcp-echo2

: tcp-echo2-benchmark ( -- )
    5,000 1450 tcp-echo-benchmark ;

MAIN: tcp-echo2-benchmark
