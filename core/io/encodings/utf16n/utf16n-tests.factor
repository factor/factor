USING: accessors alien.c-types kernel
io.encodings.utf16 io.streams.byte-array tools.test ;
IN: io.encodings.utf16n

: correct-endian ( obj -- ? )
    code>> little-endian? [ utf16le = ] [ utf16be = ] if ;

[ t ] [ B{ } utf16n <byte-reader> correct-endian ] unit-test
[ t ] [ utf16n <byte-writer> correct-endian ] unit-test
