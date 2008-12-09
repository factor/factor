! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: sequences math.parser io io.encodings.binary io.files
kernel ;
IN: checksums

MIXIN: checksum

GENERIC: checksum-bytes ( bytes checksum -- value )

GENERIC: checksum-stream ( stream checksum -- value )

GENERIC: checksum-lines ( lines checksum -- value )

M: checksum checksum-stream
    [ contents ] dip checksum-bytes ;

M: checksum checksum-lines
    [ B{ CHAR: \n } join ] dip checksum-bytes ;

: checksum-file ( path checksum -- value )
    [ binary <file-reader> ] dip checksum-stream ;

: hex-string ( seq -- str )
    [ >hex 2 CHAR: 0 pad-left ] { } map-as concat ;
