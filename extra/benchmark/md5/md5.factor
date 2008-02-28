USING: crypto.md5 io.files kernel ;
IN: benchmark.md5

: md5-primes-list ( -- )
    "extra/math/primes/list/list.factor" resource-path file>md5 drop ;

MAIN: md5-primes-list
