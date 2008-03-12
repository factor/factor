USING: io.crc32 io.encodings.ascii io.files kernel math ;
IN: benchmark.crc32

: crc32-primes-list ( -- )
    10 [
        "extra/math/primes/list/list.factor" resource-path
        ascii file-contents crc32 drop
    ] times ;

MAIN: crc32-primes-list
