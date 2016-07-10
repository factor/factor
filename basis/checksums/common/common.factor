! Copyright (C) 2006, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays byte-vectors checksums grouping io
io.backend io.binary io.encodings.binary io.files kernel make
math sequences locals ;
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

TUPLE: checksum-state
{ bytes-read integer }
{ block-size integer }
{ bytes byte-vector } ;

: new-checksum-state ( class -- checksum-state )
    new
        BV{ } clone >>bytes ; inline

M: checksum-state clone
    call-next-method
    [ clone ] change-bytes ;

GENERIC: initialize-checksum-state ( checksum -- checksum-state )

GENERIC: checksum-block ( bytes checksum-state -- )

GENERIC: get-checksum ( checksum-state -- value )

! Update the bytes-read before calculating checksum in case
! checksum uses this in the calculation.
:: add-checksum-bytes ( checksum-state data -- checksum-state' )
    checksum-state block-size>> :> block-size
    checksum-state bytes>> length :> initial-len
    initial-len data length + block-size /mod :> ( n extra )
    data checksum-state bytes>> [ push-all ] keep :> all-bytes
    all-bytes block-size <groups>
    extra zero? [ f ] [ unclip-last-slice ] if :> ( blocks remain )

    checksum-state [ initial-len - ] change-bytes-read drop

    blocks [
        checksum-state [ block-size + ] change-bytes-read
        checksum-block
    ] each

    checksum-state [ extra + ] change-bytes-read
    remain [ >byte-vector ] [ BV{ } clone ] if* >>bytes ;

: add-checksum-stream ( checksum-state stream -- checksum-state )
    [ [ add-checksum-bytes ] each-block ] with-input-stream ;

: add-checksum-file ( checksum-state path -- checksum-state )
    binary <file-reader> add-checksum-stream ;

M: block-checksum checksum-bytes
    initialize-checksum-state
    swap add-checksum-bytes get-checksum ;

M: block-checksum checksum-stream
    initialize-checksum-state
    swap add-checksum-stream get-checksum ;
