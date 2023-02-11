! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: math sequences kernel ;
IN: benchmark.gc1

: gc1-benchmark ( -- ) 600000 <iota> [ >bignum 1 + ] map drop ;

MAIN: gc1-benchmark
