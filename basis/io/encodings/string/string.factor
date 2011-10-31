! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-vectors io io.encodings io.streams.byte-array
io.streams.string kernel locals sbufs sequences io.private
io.encodings.binary ;
IN: io.encodings.string

:: decode ( byte-array encoding -- string )
    encoding binary eq? [ byte-array ] [
        byte-array encoding <byte-reader> :> reader
        byte-array length
        encoding guess-decoded-length
        reader stream-exemplar-growable new-resizable :> buf
        [ reader stream-read1 dup ] [ buf push ] while drop
        buf reader stream-exemplar like
    ] if ; inline

:: encode ( string encoding -- byte-array )
    encoding binary eq? [ string ] [
        string length encoding guess-encoded-length <byte-vector> :> vec
        string vec encoding <encoder> stream-write
        vec B{ } like
    ] if ; inline
