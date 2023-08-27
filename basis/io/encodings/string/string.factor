! Copyright (C) 2008 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays byte-vectors io io.encodings
io.streams.byte-array io.streams.string kernel locals
sbufs sequences io.private io.encodings.ascii
io.encodings.binary io.encodings.private io.encodings.utf8 ;
IN: io.encodings.string

:: decode ( byte-array encoding -- string )
    encoding binary eq? [ byte-array ] [
        byte-array byte-array? encoding ascii eq? and [
            byte-array byte-array>string-fast
        ] [
            byte-array encoding <byte-reader> :> reader
            byte-array length encoding guess-decoded-length <sbuf> :> buf
            [ reader stream-read1 ] [ buf push ] while*
            buf "" like
        ] if
    ] if ; inline

:: encode ( string encoding -- byte-array )
    encoding binary eq? [ string ] [
        string aux>> not encoding { ascii utf8 } member-eq? and [
            string string>byte-array-fast
        ] [
            string length encoding guess-encoded-length <byte-vector> :> vec
            string vec encoding <encoder> stream-write
            vec B{ } like
        ] if
    ] if ; inline
