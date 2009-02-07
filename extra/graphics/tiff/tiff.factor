! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io io.encodings.binary io.files
kernel pack endian tools.hexdump constructors sequences arrays
sorting.slots math.order ;
IN: graphics.tiff

TUPLE: tiff
endianness
the-answer
ifd-offset
ifds
;

CONSTRUCTOR: tiff ( -- tiff )
    V{ } clone >>ifds ;

TUPLE: ifd count ifd-entries ;

CONSTRUCTOR: ifd ( count ifd-entries -- ifd ) ;

TUPLE: ifd-entry tag type count offset ;

CONSTRUCTOR: ifd-entry ( tag type count offset -- ifd-entry ) ;


ERROR: bad-tiff-magic bytes ;

: tiff-endianness ( byte-array -- ? )
    {
        { B{ CHAR: M CHAR: M } [ big-endian ] }
        { B{ CHAR: I CHAR: I } [ little-endian ] }
        [ bad-tiff-magic ]
    } case ;

: with-tiff-endianness ( tiff quot -- tiff )
    [ dup endianness>> ] dip with-endianness ; inline

: read-header ( tiff -- tiff )
    2 read tiff-endianness [ >>endianness ] keep
    [
        2 read endian> >>the-answer
        4 read endian> >>ifd-offset
    ] with-endianness ;

: push-ifd ( tiff ifd -- tiff )
    over ifds>> push ;

: read-ifd ( -- ifd )
    2 read endian>
    2 read endian>
    4 read endian>
    4 read endian> <ifd-entry> ;

: read-ifds ( tiff -- tiff )
    [
        dup ifd-offset>> seek
        2 read endian>
        dup [ read-ifd ] replicate <ifd> >>ifds
    ] with-tiff-endianness ;

: (load-tiff) ( path -- tiff )
    binary [
        tiff new
        read-header
        read-ifds
    ] with-file-reader ;

: load-tiff ( path -- tiff )
    (load-tiff) ;
