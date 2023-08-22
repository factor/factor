! Copyright (C) 2006, 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays byte-vectors checksums endian
grouping kernel make math sequences ;
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
    [ swap add-checksum-bytes get-checksum ] with-checksum-state ;

M: block-checksum checksum-stream
    [ swap add-checksum-stream get-checksum ] with-checksum-state ;
