! Copyright (C) 2006, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays byte-vectors checksums destructors
grouping io io.backend io.binary io.encodings.binary io.files
kernel make math sequences locals ;
IN: checksums.common

: calculate-pad-length ( length -- length' )
    [ 56 < 55 119 ? ] keep - ;

: pad-last-block ( bytes big-endian? length -- blocks )
    [
        [ % ] 2dip 0x80 ,
        [ 0x3f bitand calculate-pad-length <byte-array> % ]
        [ 3 shift 8 rot [ >be ] [ >le ] if % ] bi
    ] B{ } make 64 group ;

MIXIN: block-checksum

INSTANCE: block-checksum checksum

TUPLE: block-checksum-state < checksum-state
    { bytes-read integer }
    { block-size integer } ;

M: block-checksum-state dispose drop ;

GENERIC: checksum-block ( bytes checksum-state -- )

! Update the bytes-read before calculating checksum in case
! checksum uses this in the calculation.
M:: block-checksum-state add-checksum-bytes ( state data -- state )
    state block-size>> :> block-size
    state bytes>> length :> initial-len
    initial-len data length + block-size /mod :> ( n extra )
    data state bytes>> [ push-all ] keep :> all-bytes
    all-bytes block-size <groups>
    extra zero? [ f ] [ unclip-last-slice ] if :> ( blocks remain )

    state [ initial-len - ] change-bytes-read drop

    blocks [
        state [ block-size + ] change-bytes-read
        checksum-block
    ] each

    state [ extra + ] change-bytes-read
    remain [ >byte-vector ] [ BV{ } clone ] if* >>bytes ;

M: block-checksum checksum-bytes
    initialize-checksum-state [
        swap add-checksum-bytes get-checksum
    ] with-disposal ;

M: block-checksum checksum-stream
    initialize-checksum-state [
        swap add-checksum-stream get-checksum
    ] with-disposal ;
