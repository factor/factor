! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.streams.byte-array ;
IN: io.encodings.string

: decode ( byte-array encoding -- string )
    <byte-reader> stream-contents ;

: encode ( string encoding -- byte-array )
    [ write ] with-byte-writer ;
