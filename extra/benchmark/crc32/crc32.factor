USING: checksums checksums.crc32 io.encodings.ascii io.files kernel math ;
IN: benchmark.crc32

: crc32-file ( -- )
    10 [
        "vocab:mime/multipart/multipart-tests.factor"
        crc32 checksum-file drop
    ] times ;

MAIN: crc32-file
