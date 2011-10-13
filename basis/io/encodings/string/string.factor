! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-vectors io io.encodings io.streams.byte-array
io.streams.string kernel locals sbufs sequences ;
IN: io.encodings.string

:: decode ( byte-array encoding -- string )
    byte-array encoding <byte-reader> :> reader
    byte-array length encoding guess-decoded-length <sbuf> :> buf
    [ reader stream-read1 dup ] [ buf push ] while drop
    buf "" like ; inline

:: encode ( string encoding -- byte-array )
    string length encoding guess-encoded-length <byte-vector> :> vec
    string vec encoding <encoder> stream-write
    vec B{ } like ; inline
