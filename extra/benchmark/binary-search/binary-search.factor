! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: binary-search kernel math.primes.list math.ranges sequences
prettyprint ;
IN: benchmark.binary-search

: binary-search-benchmark ( -- )
    1 1000000 [a,b] [ primes-under-million sorted-member? ] map length . ;

! Force computation of the primes list before benchmarking the binary search
primes-under-million drop

MAIN: binary-search-benchmark
