! Copyright (C) 2006 Doug Coleman
! See https://factorcode.org/license.txt for BSD license.
USING: checksums kernel math sequences sequences.private ;
IN: checksums.crc32

CONSTANT: crc32-polynomial 0xedb88320

CONSTANT: crc32-table V{ }

256 <iota> [
    8 [
        [ 2/ ] [ even? ] bi [ crc32-polynomial bitxor ] unless
    ] times
] map 0 crc32-table copy

: (crc32) ( crc ch -- crc )
    dupd bitxor
    0xff bitand crc32-table nth-unsafe
    swap -8 shift bitxor ; inline

SINGLETON: crc32

INSTANCE: crc32 checksum

: init-crc32 ( input checksum -- x y input )
    drop [ 0xffffffff dup ] dip ; inline

<PRIVATE
: 4>be ( n -- byte-array ) ! duplicated from endian but in core
    { -24 -16 -8 0 } [ shift 0xff bitand ] with B{ } map-as ;
PRIVATE>

: finish-crc32 ( x y -- bytes )
    bitxor 4>be ; inline

M: crc32 checksum-bytes
    init-crc32
    [ (crc32) ] each
    finish-crc32 ; inline

M: crc32 checksum-lines
    init-crc32
    [ [ (crc32) ] each CHAR: \n (crc32) ] each
    finish-crc32 ; inline
