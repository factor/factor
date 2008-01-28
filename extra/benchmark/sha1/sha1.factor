USING: crypto.sha1 io.files kernel ;
IN: benchmark.sha1

: sha1-primes-list ( -- )
    "extra/math/primes/list/list.factor" resource-path file>sha1 drop ;

MAIN: sha1-primes-list
