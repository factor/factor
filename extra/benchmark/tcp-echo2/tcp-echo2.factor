! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: benchmark.tcp-echo0 io ;
IN: benchmark.tcp-echo2

: tcp-echo-benchmark2 ( -- )
    20,000 20 tcp-echo-benchmark ;

MAIN: tcp-echo-benchmark2
