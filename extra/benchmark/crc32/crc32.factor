USING: checksums checksums.crc32 kernel math ;
IN: benchmark.crc32

: crc32-benchmark ( -- )
    1,000 [
        "vocab:mime/multipart/multipart-tests.factor"
        crc32 checksum-file drop
    ] times ;

MAIN: crc32-benchmark
