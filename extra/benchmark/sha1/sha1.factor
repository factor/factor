USING: checksums checksums.sha1 io.files kernel ;
IN: benchmark.sha1

: sha1-file ( -- )
    "resource:basis/mime/multipart/multipart-tests.factor" sha1 checksum-file drop ;

MAIN: sha1-file
