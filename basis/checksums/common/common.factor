! Copyright (C) 2006, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays byte-vectors checksums grouping io
io.backend io.binary io.encodings.binary io.files kernel make
math sequences ;
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

: add-checksum-bytes ( checksum-state data -- checksum-state' )
    [
        over bytes>> [ push-all ] keep
        [ dup length pick block-size>> >= ]
        [
            over block-size>> cut-slice [
                over checksum-block
                [ block-size>> ] keep [ + ] change-bytes-read
            ] dip
        ] while
        >byte-vector >>bytes
    ] keep
    length [ + ] curry change-bytes-read ;

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
