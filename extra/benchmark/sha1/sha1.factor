USING: crypto.sha1 io.files kernel ;
IN: benchmark.sha1

: sha1-primes-list ( -- seq )
    "extra/math/primes/list/list.factor" resource-path file>sha1 ;

MAIN: sha1-primes-list
