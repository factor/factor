! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io io.encodings.binary io.files
kernel pack endian tools.hexdump constructors sequences arrays
sorting.slots math.order math.parser prettyprint ;
IN: graphics.tiff

TUPLE: tiff
endianness
the-answer
ifd-offset
ifds
processed-ifds ;

CONSTRUCTOR: tiff ( -- tiff )
    V{ } clone >>ifds ;

TUPLE: ifd count ifd-entries next ;

CONSTRUCTOR: ifd ( count ifd-entries next -- ifd ) ;

TUPLE: ifd-entry tag type count offset ;

CONSTRUCTOR: ifd-entry ( tag type count offset -- ifd-entry ) ;


TUPLE: photometric-interpretation color ;

CONSTRUCTOR: photometric-interpretation ( color -- object ) ;

SINGLETONS: white-is-zero black-is-zero rgb palette-color ;

ERROR: bad-photometric-interpretation n ;

: lookup-photometric-interpretation ( n -- singleton )
    {
        { 0 [ white-is-zero ] }
        { 1 [ black-is-zero ] }
        { 2 [ rgb ] }
        { 3 [ palette-color ] }
        [ bad-photometric-interpretation ]
    } case <photometric-interpretation> ;


TUPLE: compression method ;

CONSTRUCTOR: compression ( method -- object ) ;

SINGLETONS: no-compression CCITT-2 pack-bits lzw ;

ERROR: bad-compression n ;

: lookup-compression ( n -- compression )
    {
        { 1 [ no-compression ] }
        { 2 [ CCITT-2 ] }
        { 5 [ lzw ] }
        { 32773 [ pack-bits ] }
        [ bad-compression ]
    } case <compression> ;

TUPLE: image-length n ;
CONSTRUCTOR: image-length ( n -- object ) ;

TUPLE: image-width n ;
CONSTRUCTOR: image-width ( n -- object ) ;

TUPLE: x-resolution n ;
CONSTRUCTOR: x-resolution ( n -- object ) ;

TUPLE: y-resolution n ;
CONSTRUCTOR: y-resolution ( n -- object ) ;

TUPLE: rows-per-strip n ;
CONSTRUCTOR: rows-per-strip ( n -- object ) ;

TUPLE: strip-offsets n ;
CONSTRUCTOR: strip-offsets ( n -- object ) ;

TUPLE: strip-byte-counts n ;
CONSTRUCTOR: strip-byte-counts ( n -- object ) ;

TUPLE: bits-per-sample n ;
CONSTRUCTOR: bits-per-sample ( n -- object ) ;

TUPLE: samples-per-pixel n ;
CONSTRUCTOR: samples-per-pixel ( n -- object ) ;

SINGLETONS: no-resolution-unit
inch-resolution-unit
centimeter-resolution-unit ;

TUPLE: resolution-unit type ;
CONSTRUCTOR: resolution-unit ( type -- object ) ;

ERROR: bad-resolution-unit n ;

: lookup-resolution-unit ( n -- object )
    {
        { 1 [ no-resolution-unit ] }
        { 2 [ inch-resolution-unit ] }
        { 3 [ centimeter-resolution-unit ] }
        [ bad-resolution-unit ]
    } case <resolution-unit> ;


TUPLE: predictor type ;
CONSTRUCTOR: predictor ( type -- object ) ;

SINGLETONS: no-predictor horizontal-differencing-predictor ;

ERROR: bad-predictor n ;

: lookup-predictor ( n -- object )
    {
        { 1 [ no-predictor ] }
        { 2 [ horizontal-differencing-predictor ] }
        [ bad-predictor ]
    } case <predictor> ;


TUPLE: planar-configuration type ;
CONSTRUCTOR: planar-configuration ( type -- object ) ;

SINGLETONS: chunky planar ;

ERROR: bad-planar-configuration n ;

: lookup-planar-configuration ( n -- object )
    {
        { 1 [ no-predictor ] }
        { 2 [ horizontal-differencing-predictor ] }
        [ bad-predictor ]
    } case <planar-configuration> ;


TUPLE: new-subfile-type n ;
CONSTRUCTOR: new-subfile-type ( n -- object ) ;



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
        dup ifd-offset>> seek-absolute seek-input
        2 read endian>
        dup [ read-ifd ] replicate
        4 read endian>
        [ <ifd> push-ifd ] [ 0 = [ read-ifds ] unless ] bi
    ] with-tiff-endianness ;

! ERROR: unhandled-ifd-entry data n ;

: unhandled-ifd-entry ;

: ifd-entry-value ( ifd-entry -- n )
    dup count>> 1 = [
        offset>>
    ] [
        [ offset>> seek-absolute seek-input ] [ count>> read ] bi
    ] if ;

: process-ifd-entry ( ifd-entry -- object )
    [ ifd-entry-value ] [ tag>> ] bi {
        { 254 [ <new-subfile-type> ] }
        { 256 [ <image-width> ] }
        { 257 [ <image-length> ] }
        { 258 [ <bits-per-sample> ] }
        { 259 [ lookup-compression ] }
        { 262 [ lookup-photometric-interpretation ] }
        { 273 [ <strip-offsets> ] }
        { 277 [ <samples-per-pixel> ] }
        { 278 [ <rows-per-strip> ] }
        { 279 [ <strip-byte-counts> ] }
        { 282 [ <x-resolution> ] }
        { 283 [ <y-resolution> ] }
        { 284 [ <planar-configuration> ] }
        { 296 [ lookup-resolution-unit ] }
        { 317 [ lookup-predictor ] }
        [ unhandled-ifd-entry swap 2array ]
    } case ;

: process-ifd ( ifd -- processed-ifd )
    ifd-entries>> [ process-ifd-entry ] map ;

: (load-tiff) ( path -- tiff )
    binary [
        <tiff>
        read-header
        read-ifds
        dup ifds>> [ process-ifd ] map
        >>processed-ifds
    ] with-file-reader ;

: load-tiff ( path -- tiff )
    (load-tiff) ;
