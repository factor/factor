USING: checksums checksums.md5 io.files kernel ;
IN: benchmark.md5

: md5-file ( -- )
    "resource:basis/mime/multipart/multipart-tests.factor" md5 checksum-file drop ;

MAIN: md5-file
