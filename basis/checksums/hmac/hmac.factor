! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays checksums io.encodings.binary io.files
io.streams.byte-array kernel math math.vectors sequences ;
IN: checksums.hmac

SLOT: block-size

<PRIVATE

: opad ( checksum-state -- seq ) block-size>> 0x5c <array> ;

: ipad ( checksum-state -- seq ) block-size>> 0x36 <array> ;

:: init-key ( checksum key checksum-state -- o i )
    checksum-state block-size>> key length <
    [ key checksum checksum-bytes ] [ key ] if
    checksum-state block-size>> 0 pad-tail
    [ checksum-state opad vbitxor ]
    [ checksum-state ipad vbitxor ] bi ;

PRIVATE>

:: hmac-stream ( stream key checksum -- value )
    checksum initialize-checksum-state :> checksum-state
    checksum key checksum-state init-key :> ( Ko Ki )
    checksum-state Ki add-checksum-bytes
    stream add-checksum-stream get-checksum
    checksum initialize-checksum-state
    Ko add-checksum-bytes swap add-checksum-bytes
    get-checksum ;

: hmac-file ( path key checksum -- value )
    [ binary <file-reader> ] 2dip hmac-stream ;

: hmac-bytes ( seq key checksum -- value )
    [ binary <byte-reader> ] 2dip hmac-stream ;
