! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: binary-search kernel math.primes math.ranges memoize
prettyprint sequences ;
IN: benchmark.binary-search

MEMO: primes-under-million ( -- seq ) 1000000 primes-upto ;

! Force computation of the primes list before benchmarking the binary search
primes-under-million drop

: binary-search-benchmark ( -- )
    1 1000000 [a,b] [ primes-under-million sorted-member? ] map
    length 1000000 assert= ;

MAIN: binary-search-benchmark
