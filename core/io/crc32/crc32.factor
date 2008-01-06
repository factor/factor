! Copyright (C) 2006 Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences sequences.private namespaces
words io io.binary io.files io.streams.string quotations
definitions ;
IN: io.crc32

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

: crc32 ( seq -- n )
    >r HEX: ffffffff dup r> [ (crc32) ] each bitxor ;

: file-crc32 ( path -- n ) file-contents crc32 ;
