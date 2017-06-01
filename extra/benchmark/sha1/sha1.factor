USING: checksums checksums.sha sequences byte-arrays kernel ;
IN: benchmark.sha1

: sha1-benchmark ( -- )
    2000000 <iota> >byte-array sha1 checksum-bytes drop ;

: sha224-benchmark ( -- )
    2000000 <iota> >byte-array sha-224 checksum-bytes drop ;

: sha256-benchmark ( -- )
    2000000 <iota> >byte-array sha-256 checksum-bytes drop ;

USE: checksums.openssl

: openssl-sha1-benchmark ( -- )
    2000000 <iota> >byte-array openssl-sha1 checksum-bytes drop ;

MAIN: sha1-benchmark
