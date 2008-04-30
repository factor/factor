USING: checksums checksums.crc32 io.encodings.ascii io.files kernel math ;
IN: benchmark.crc32

: crc32-primes-list ( -- )
    10 [
        "resource:extra/math/primes/list/list.factor"
        crc32 checksum-file drop
    ] times ;

MAIN: crc32-primes-list
