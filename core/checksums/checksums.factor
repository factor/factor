! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io io.backend io.files kernel math math.parser
sequences vectors quotations ;
IN: checksums

MIXIN: checksum

TUPLE: checksum-state bytes-read block-size bytes ;

: new-checksum-state ( class -- checksum-state )
    new
        0 >>bytes-read
        V{ } clone >>bytes ; inline

M: checksum-state clone
    call-next-method
    [ clone ] change-bytes ;

GENERIC: initialize-checksum-state ( class -- checksum-state )

GENERIC: checksum-block ( bytes checksum -- )

GENERIC: get-checksum ( checksum -- value )

: add-checksum-bytes ( checksum-state data -- checksum-state )
    over bytes>> [ push-all ] keep
    [ dup length pick block-size>> >= ]
    [
        64 cut-slice [
            over [ checksum-block ]
            [ [ 64 + ] change-bytes-read drop ] bi
        ] dip
    ] while >vector [ >>bytes ] [ length [ + ] curry change-bytes-read ] bi ;

: add-checksum-stream ( checksum-state stream -- checksum-state )
    [
        [ [ swap add-checksum-bytes drop ] curry each-block ] keep
    ] with-input-stream ;

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
    #! normalize-path (file-reader) is equivalen to
    #! binary <file-reader>. We use the lower-level form
    #! so that we can move io.encodings.binary to basis/.
    [ normalize-path (file-reader) ] dip checksum-stream ;

: hex-string ( seq -- str )
    [ >hex 2 CHAR: 0 pad-head ] { } map-as concat ;
