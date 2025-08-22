! Copyright (C) 2006, 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors byte-arrays checksums endian grouping kernel
math math.order sequences ;

IN: checksums.common

: calculate-pad-length ( length -- length' )
    [ 56 < 55 119 ? ] keep - ;

: pad-last-block ( bytes big-endian? length -- blocks )
    [ 0x80 suffix! ] 2dip
    [ 0x3f bitand calculate-pad-length <byte-array> nip append! ]
    [ 3 shift 8 rot [ >be ] [ >le ] if append! ] 2bi 64 <groups> ;

MIXIN: block-checksum

INSTANCE: block-checksum checksum

TUPLE: block-checksum-state < checksum-state
    { bytes-read integer }
    { block-size integer } ;

GENERIC: checksum-block ( bytes checksum-state -- )

! Update the bytes-read before calculating checksum in case
! checksum uses this in the calculation.
M:: block-checksum-state add-checksum-bytes ( state data -- state )
    state bytes>> :> bytes
    state block-size>> :> block-size
    bytes [ data ] [
        length :> initial-len
        block-size initial-len - :> needed
        needed 0 > t assert=
        data dup length needed min cut-slice [
            state over length '[ _ + ] change-bytes-read drop
            bytes push-all
            bytes length block-size = [
                bytes state checksum-block
                bytes delete-all
            ] when
        ] dip
    ] if-empty dup length block-size mod cut-slice* [
        block-size <groups> [
            bytes push-all
            bytes state [ block-size + ] change-bytes-read checksum-block
            bytes delete-all
        ] each
    ] [
        [ bytes push-all ]
        [ state swap length '[ _ + ] change-bytes-read ] bi
    ] bi* ;

M: block-checksum checksum-bytes
    [ swap add-checksum-bytes get-checksum ] with-checksum-state ;

M: block-checksum checksum-stream
    [ swap add-checksum-stream get-checksum ] with-checksum-state ;
