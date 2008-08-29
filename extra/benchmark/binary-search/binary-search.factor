! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: binary-search math.primes.list math.ranges sequences
prettyprint ;
IN: benchmark.binary-search

: binary-search-benchmark ( -- )
    1 1000000 [a,b] [ primes-under-million sorted-member? ] map length . ;

MAIN: binary-search-benchmark
