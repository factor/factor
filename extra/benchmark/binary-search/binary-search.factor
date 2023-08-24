! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: binary-search kernel literals math.primes ranges
sequences ;
IN: benchmark.binary-search

! Force computation of the primes list before benchmarking the binary search
CONSTANT: primes-under-million $[ 1,000,000 primes-upto ]

: binary-search-benchmark ( -- )
    1,000,000 [1..b] [ primes-under-million sorted-member? ] map
    length 1,000,000 assert= ;

MAIN: binary-search-benchmark
