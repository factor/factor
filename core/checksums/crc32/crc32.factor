! Copyright (C) 2006 Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences sequences.private namespaces
words io io.binary io.files io.streams.string quotations
definitions checksums ;
IN: checksums.crc32

: crc32-polynomial HEX: edb88320 ; inline

: crc32-table V{ } ; inline

256 [
    8 [
        dup even? >r 2/ r> [ crc32-polynomial bitxor ] unless
    ] times >bignum
] map 0 crc32-table copy

: (crc32) ( crc ch -- crc )
    >bignum dupd bitxor
    mask-byte crc32-table nth-unsafe >bignum
    swap -8 shift bitxor ; inline

SINGLETON: crc32

INSTANCE: crc32 checksum

: init-crc32 drop >r HEX: ffffffff dup r> ; inline

: finish-crc32 bitxor 4 >be ; inline

M: crc32 checksum-bytes
    init-crc32
    [ (crc32) ] each
    finish-crc32 ;

M: crc32 checksum-lines
    init-crc32
    [ [ (crc32) ] each CHAR: \n (crc32) ] each
    finish-crc32 ;
