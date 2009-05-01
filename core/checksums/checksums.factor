! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: sequences math.parser io io.backend io.files
kernel ;
IN: checksums

MIXIN: checksum

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
