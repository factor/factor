! Copyright (C) 2016 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: checksums io.binary kernel math sequences
sequences.private ;
IN: checksums.crc16

CONSTANT: crc16-polynomial 0xa001

CONSTANT: crc16-table V{ }

256 <iota> [
    8 [
        [ 2/ ] [ even? ] bi [ crc16-polynomial bitxor ] unless
    ] times
] map 0 crc16-table copy

: (crc16) ( crc ch -- crc )
    dupd bitxor
    mask-byte crc16-table nth-unsafe
    swap -8 shift bitxor ; inline

SINGLETON: crc16

INSTANCE: crc16 checksum

: init-crc16 ( input checksum -- x input )
    drop [ 0xffff ] dip ; inline

: finish-crc16 ( x -- bytes )
    2 >le ; inline

M: crc16 checksum-bytes
    init-crc16
    [ (crc16) ] each
    finish-crc16 ; inline

M: crc16 checksum-lines
    init-crc16
    [ [ (crc16) ] each CHAR: \n (crc16) ] each
    finish-crc16 ; inline 
