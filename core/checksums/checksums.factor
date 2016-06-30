! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: io io.backend io.encodings.binary io.files
io.streams.byte-array kernel sequences ;
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
