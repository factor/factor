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

: next-level ( n size -- n' )
    2dup mod [ + ] [ - + ] if-zero ; inline

! Update the bytes-read before calculating checksum in case checksum uses
! this in the calculation.
:: add-checksum-bytes ( state data -- state' )
    state block-size>> :> block-size
    state bytes>> length :> initial-len
    data length :> data-len
    initial-len data-len + :> total-len
    total-len block-size /mod :> ( n extra )
    data state bytes>> [ push-all ] keep :> all-bytes
    n zero? [
        state [ data-len + ] change-bytes-read drop
    ] [
        all-bytes block-size <groups> [ length 64 = ] partition [
            [ state [ block-size next-level ] change-bytes-read drop state checksum-block ] each
            BV{ } clone state bytes<<
        ] [
            [
                first
                [ length state [ + ] change-bytes-read drop ]
                [ >byte-vector state bytes<< ] bi
            ] unless-empty
        ] bi*
    ] if state ;

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
