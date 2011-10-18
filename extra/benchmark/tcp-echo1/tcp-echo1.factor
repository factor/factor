! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: benchmark.tcp-echo0 io ;
IN: benchmark.tcp-echo1

: tcp-echo-benchmark1 ( -- )
    5,000 64 tcp-echo-benchmark ;

MAIN: tcp-echo-benchmark1
