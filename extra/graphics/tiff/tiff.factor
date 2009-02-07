! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io io.encodings.binary io.files
kernel pack endian ;
IN: graphics.tiff

TUPLE: tiff
endianness
the-answer
ifd-offset
;


ERROR: bad-tiff-magic bytes ;

: tiff-endianness ( byte-array -- ? )
    {
        { B{ CHAR: M CHAR: M } [ big-endian ] }
        { B{ CHAR: I CHAR: I } [ little-endian ] }
        [ bad-tiff-magic ]
    } case ;

: read-header ( tiff -- tiff )
    2 read tiff-endianness [ >>endianness ] keep
    [
        2 read endian> >>the-answer
        4 read endian> >>ifd-offset
    ] with-endianness ;

: (load-tiff) ( path -- tiff )
    binary [
        tiff new
        read-header
    ] with-file-reader ;

: load-tiff ( path -- tiff )
    (load-tiff) ;
