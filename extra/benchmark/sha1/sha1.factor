USING: checksum checksums.sha1 io.files kernel ;
IN: benchmark.sha1

: sha1-primes-list ( -- )
    "resource:extra/math/primes/list/list.factor" sha1 checksum-file drop ;

MAIN: sha1-primes-list
