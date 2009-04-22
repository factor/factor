USING: checksums checksums.sha1 sequences byte-arrays kernel ;
IN: benchmark.sha1

: sha1-file ( -- )
    2000000 iota >byte-array sha1 checksum-bytes drop ;

MAIN: sha1-file
