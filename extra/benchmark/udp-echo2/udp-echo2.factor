! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: benchmark.udp-echo0 ;
IN: benchmark.udp-echo2

: udp-echo2-benchmark ( -- ) 10,000 1450 udp-echo ;

MAIN: udp-echo2-benchmark
