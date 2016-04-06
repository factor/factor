! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays byte-vectors io io.backend io.files
kernel math math.parser sequences ;
IN: checksums

MIXIN: checksum

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

: add-checksum-bytes ( checksum-state data -- checksum-state )
    over bytes>> [ push-all ] keep
    [ dup length pick block-size>> >= ]
    [
        over block-size>> cut-slice [
            over checksum-block
            [ block-size>> ] keep [ + ] change-bytes-read
        ] dip
    ] while
    >byte-vector
    [ >>bytes ] [ length [ + ] curry change-bytes-read ] bi ;

: add-checksum-stream ( checksum-state stream -- checksum-state )
    [ [ add-checksum-bytes ] each-block ] with-input-stream ;

: add-checksum-file ( checksum-state path -- checksum-state )
    normalize-path (file-reader) add-checksum-stream ;

GENERIC: checksum-bytes ( bytes checksum -- value )

GENERIC: checksum-stream ( stream checksum -- value )

GENERIC: checksum-lines ( lines checksum -- value )

M: checksum checksum-stream
    [ stream-contents ] dip checksum-bytes ;

M: checksum checksum-lines
    [ B{ CHAR: \n } join ] dip checksum-bytes ;

: checksum-file ( path checksum -- value )
    ! normalize-path (file-reader) is equivalent to
    ! binary <file-reader>. We use the lower-level form
    ! so that we can move io.encodings.binary to basis/.
    [ normalize-path (file-reader) ] dip checksum-stream ;
