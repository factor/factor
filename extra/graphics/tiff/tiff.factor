! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io io.encodings.binary io.files
kernel pack endian tools.hexdump constructors sequences arrays
sorting.slots math.order math.parser prettyprint classes
io.binary assocs math math.bitwise byte-arrays grouping ;
USE: multiline

IN: graphics.tiff

TUPLE: tiff
endianness
the-answer
ifd-offset
ifds ;


CONSTRUCTOR: tiff ( -- tiff )
    V{ } clone >>ifds ;

TUPLE: ifd count ifd-entries next
processed-tags strips buffer ;

CONSTRUCTOR: ifd ( count ifd-entries next -- ifd ) ;

TUPLE: ifd-entry tag type count offset/value ;

CONSTRUCTOR: ifd-entry ( tag type count offset/value -- ifd-entry ) ;


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

TUPLE: sample-format n ;
CONSTRUCTOR: sample-format ( n -- object ) ;
ERROR: bad-sample-format n ;

SINGLETONS: sample-unsigned-integer sample-signed-integer
sample-ieee-float sample-undefined-data ;

: lookup-sample-format ( seq -- object )
    [
        {
            { 1 [ sample-unsigned-integer ] }
            { 2 [ sample-signed-integer ] }
            { 3 [ sample-ieee-float ] }
            { 4 [ sample-undefined-data ] }
            [ bad-sample-format ]
        } case
    ] map <sample-format> ;


TUPLE: extra-samples n ;
CONSTRUCTOR: extra-samples ( n -- object ) ;
ERROR: bad-extra-samples n ;

SINGLETONS: unspecified-alpha-data associated-alpha-data
unassociated-alpha-data ;

: lookup-extra-samples ( seq -- object )
    {
        { 0 [ unspecified-alpha-data ] }
        { 1 [ associated-alpha-data ] }
        { 2 [ unassociated-alpha-data ] }
        [ bad-extra-samples ]
    } case <extra-samples> ;


TUPLE: orientation n ;
CONSTRUCTOR: orientation ( n -- object ) ;


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
    ! over [ dup class ] [ ifds>> ] bi* set-at ;

: read-ifd ( -- ifd )
    2 read endian>
    2 read endian>
    4 read endian>
    4 read endian> <ifd-entry> ;

: read-ifds ( tiff -- tiff )
    dup ifd-offset>> seek-absolute seek-input
    2 read endian>
    dup [ read-ifd ] replicate
    4 read endian>
    [ <ifd> push-ifd ] [ 0 = [ read-ifds ] unless ] bi ;

ERROR: no-tag class ;

: ?at ( key assoc -- value/key ? )
    dupd at* [ nip t ] [ drop f ] if ; inline

: find-tag ( idf class -- tag )
    swap processed-tags>>
    ?at [ no-tag ] unless ;

: read-strips ( ifd -- ifd )
    dup
    [ strip-byte-counts find-tag n>> ]
    [ strip-offsets find-tag n>> ] bi
    2dup [ integer? ] both? [
        seek-absolute seek-input read 1array
    ] [
        [ seek-absolute seek-input read ] { } 2map-as
    ] if >>strips ;

! ERROR: unhandled-ifd-entry data n ;

: unhandled-ifd-entry ;

ERROR: unknown-ifd-type n ;

: bytes>bits ( n/byte-array -- n )
    dup byte-array? [ byte-array>bignum ] when ;

: value-length ( ifd-entry -- n )
    [ count>> ] [ type>> ] bi {
        { 1 [ ] }
        { 2 [ ] }
        { 3 [ 2 * ] }
        { 4 [ 4 * ] }
        { 5 [ 8 * ] }
        { 6 [ ] }
        { 7 [ ] }
        { 8 [ 2 * ] }
        { 9 [ 4 * ] }
        { 10 [ 8 * ] }
        { 11 [ 4 * ] }
        { 12 [ 8 * ] }
        [ unknown-ifd-type ]
    } case ;

ERROR: bad-small-ifd-type n ;

: adjust-offset/value ( ifd-entry -- obj )
    [ offset/value>> 4 >endian ] [ type>> ] bi
    {
        { 1 [ 1 head endian> ] }
        { 3 [ 2 head endian> ] }
        { 4 [ endian> ] }
        { 6 [ 1 head endian> 8 >signed ] }
        { 8 [ 2 head endian> 16 >signed ] }
        { 9 [ endian> 32 >signed ] }
        { 11 [ endian> bits>float ] }
        [ bad-small-ifd-type ]
    } case ;

: offset-bytes>obj ( bytes type -- obj )
    {
        { 1 [ ] } ! blank
        { 2 [ ] } ! read c strings here
        { 3 [ 2 <sliced-groups> [ endian> ] map ] }
        { 4 [ 4 <sliced-groups> [ endian> ] map ] }
        { 5 [ 8 <sliced-groups> [ "II" unpack first2 / ] map ] }
        { 6 [ [ 8 >signed ] map ] }
        { 7 [ ] } ! blank
        { 8 [ 2 <sliced-groups> [ endian> 16 >signed ] map ] }
        { 9 [ 4 <sliced-groups> [ endian> 32 >signed ] map ] }
        { 10 [ 8 group [ "ii" unpack first2 / ] map ] }
        { 11 [ 4 group [ "f" unpack ] map ] }
        { 12 [ 8 group [ "d" unpack ] map ] }
        [ unknown-ifd-type ]
    } case ;

: ifd-entry-value ( ifd-entry -- n )
    dup value-length 4 <= [
        adjust-offset/value
    ] [
        [ offset/value>> seek-absolute seek-input ]
        [ value-length read ]
        [ type>> ] tri offset-bytes>obj
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
        { 274 [ <orientation> ] }
        { 277 [ <samples-per-pixel> ] }
        { 278 [ <rows-per-strip> ] }
        { 279 [ <strip-byte-counts> ] }
        { 282 [ <x-resolution> ] }
        { 283 [ <y-resolution> ] }
        { 284 [ <planar-configuration> ] }
        { 296 [ lookup-resolution-unit ] }
        { 317 [ lookup-predictor ] }
        { 338 [ lookup-extra-samples ] }
        { 339 [ lookup-sample-format ] }
        [ unhandled-ifd-entry swap 2array ]
    } case ;

: process-ifd ( ifd -- ifd )
    dup ifd-entries>>
    [ process-ifd-entry [ class ] keep ] H{ } map>assoc >>processed-tags ;

: strips>buffer ( ifd -- ifd )
    dup strips>> concat >>buffer ;
/*
    [
        [ rows-per-strip find-tag n>> ]
        [ image-length find-tag n>> ] bi
    ] [
        strips>> [ length ] keep
    ] bi assemble-image ;
*/

: (load-tiff) ( path -- tiff )
    binary [
        <tiff>
        read-header [
            read-ifds
            dup ifds>> [ process-ifd read-strips strips>buffer drop ] each
        ] with-tiff-endianness
    ] with-file-reader ;

: load-tiff ( path -- tiff ) (load-tiff) ;
