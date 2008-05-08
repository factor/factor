USING: checksums checksums.md5 io.files kernel ;
IN: benchmark.md5

: md5-primes-list ( -- )
    "resource:extra/math/primes/list/list.factor" md5 checksum-file drop ;

MAIN: md5-primes-list
