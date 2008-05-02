! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: sequences math.parser io io.streams.byte-array
io.encodings.binary io.files kernel ;
IN: checksums

MIXIN: checksum

GENERIC: checksum-bytes ( bytes checksum -- value )

GENERIC: checksum-stream ( stream checksum -- value )

GENERIC: checksum-lines ( lines checksum -- value )

M: checksum checksum-bytes >r binary <byte-reader> r> checksum-stream ;

M: checksum checksum-stream >r contents r> checksum-bytes ;

M: checksum checksum-lines >r B{ CHAR: \n } join r> checksum-bytes ;

: checksum-file ( path checksum -- value )
    >r binary <file-reader> r> checksum-stream ;

: hex-string ( seq -- str )
    [ >hex 2 CHAR: 0 pad-left ] { } map-as concat ;
