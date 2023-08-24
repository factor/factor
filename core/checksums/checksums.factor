! Copyright (c) 2008 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-vectors destructors io io.encodings.binary
io.files io.streams.byte-array kernel sequences ;
IN: checksums

MIXIN: checksum

GENERIC: checksum-bytes ( bytes checksum -- value )
GENERIC: checksum-stream ( stream checksum -- value )
GENERIC: checksum-lines ( lines checksum -- value )

M: checksum checksum-bytes
    [ binary <byte-reader> ] dip checksum-stream ;

M: checksum checksum-stream
    [ stream-contents ] dip checksum-bytes ;

M: checksum checksum-lines
    [ B{ CHAR: \n } join ] dip checksum-bytes ;

: checksum-file ( path checksum -- value )
    [ binary <file-reader> ] dip checksum-stream ;

TUPLE: checksum-state < disposable
    checksum
    { bytes byte-vector } ;

M: checksum-state dispose* drop ;

M: checksum-state clone
    call-next-method
    [ clone ] change-bytes ;

: new-checksum-state ( class -- checksum-state )
    new-disposable BV{ } clone >>bytes ;

GENERIC: initialize-checksum-state ( checksum -- checksum-state )
GENERIC#: add-checksum-bytes 1 ( checksum-state data -- checksum-state )
GENERIC: get-checksum ( checksum-state -- value )

: with-checksum-state ( ..a checksum quot: ( ..a checksum-state -- ..b ) -- ..b )
    [ initialize-checksum-state ] dip with-disposal ; inline

: add-checksum-stream ( checksum-state stream -- checksum-state )
    [ [ add-checksum-bytes ] each-block ] with-input-stream ;

: add-checksum-lines ( checksum-state lines -- checksum-state )
    [ B{ CHAR: \n } add-checksum-bytes ]
    [ add-checksum-bytes ] interleave ;

: add-checksum-file ( checksum-state path -- checksum-state )
    binary <file-reader> add-checksum-stream ;

M: checksum initialize-checksum-state
    checksum-state new-checksum-state swap >>checksum ;

M: checksum-state add-checksum-bytes
    over bytes>> push-all ;

M: checksum-state get-checksum
    [ bytes>> ] [ checksum>> ] bi checksum-bytes ;
