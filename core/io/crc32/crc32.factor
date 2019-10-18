! Copyright (C) 2006 Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences sequences.private namespaces
words io io.binary io.files io.streams.string quotations ;
IN: io.crc32

: crc32-polynomial HEX: edb88320 ; inline

! Generate the table at load time and define a new word with it,
! instead of using a variable, so that the compiler can inline
! the call to nth-unsafe
DEFER: crc32-table inline

\ crc32-table
256 [
    8 [
        dup even? >r 2/ r> [ crc32-polynomial bitxor ] unless
    ] times >bignum
] map
1quotation define-inline

: (crc32) ( crc ch -- crc )
    >bignum dupd bitxor
    mask-byte crc32-table nth-unsafe >bignum
    swap -8 shift bitxor ; inline

: crc32 ( seq -- n )
    >r HEX: ffffffff dup r> [ (crc32) ] each bitxor ;

: file-crc32 ( path -- n ) <file-reader> contents crc32 ;
