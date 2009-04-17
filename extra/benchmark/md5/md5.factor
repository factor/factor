USING: checksums checksums.md5 sequences byte-arrays kernel ;
IN: benchmark.md5

: md5-file ( -- )
    2000000 iota >byte-array md5 checksum-bytes drop ;

MAIN: md5-file
