! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays classes combinators
compression.lzw constructors endian fry grouping images io
io.binary io.encodings.ascii io.encodings.binary
io.encodings.string io.encodings.utf8 io.files kernel math
math.bitwise math.order math.parser pack prettyprint sequences
strings ;
IN: images.tiff

TUPLE: tiff-image < image ;

TUPLE: parsed-tiff endianness the-answer ifd-offset ifds ;
CONSTRUCTOR: parsed-tiff ( -- tiff ) V{ } clone >>ifds ;

TUPLE: ifd count ifd-entries next
processed-tags strips bitmap ;
CONSTRUCTOR: ifd ( count ifd-entries next -- ifd ) ;

TUPLE: ifd-entry tag type count offset/value ;
CONSTRUCTOR: ifd-entry ( tag type count offset/value -- ifd-entry ) ;

SINGLETONS: photometric-interpretation
photometric-interpretation-white-is-zero
photometric-interpretation-black-is-zero
photometric-interpretation-rgb
photometric-interpretation-palette-color ;
ERROR: bad-photometric-interpretation n ;
: lookup-photometric-interpretation ( n -- singleton )
    {
        { 0 [ photometric-interpretation-white-is-zero ] }
        { 1 [ photometric-interpretation-black-is-zero ] }
        { 2 [ photometric-interpretation-rgb ] }
        { 3 [ photometric-interpretation-palette-color ] }
        [ bad-photometric-interpretation ]
    } case ;

SINGLETONS: compression
compression-none
compression-CCITT-2
compression-lzw
compression-pack-bits ;
ERROR: bad-compression n ;
: lookup-compression ( n -- compression )
    {
        { 1 [ compression-none ] }
        { 2 [ compression-CCITT-2 ] }
        { 5 [ compression-lzw ] }
        { 32773 [ compression-pack-bits ] }
        [ bad-compression ]
    } case ;

SINGLETONS: resolution-unit
resolution-unit-none
resolution-unit-inch
resolution-unit-centimeter ;
ERROR: bad-resolution-unit n ;
: lookup-resolution-unit ( n -- object )
    {
        { 1 [ resolution-unit-none ] }
        { 2 [ resolution-unit-inch ] }
        { 3 [ resolution-unit-centimeter ] }
        [ bad-resolution-unit ]
    } case ;

SINGLETONS: predictor
predictor-none
predictor-horizontal-differencing ;
ERROR: bad-predictor n ;
: lookup-predictor ( n -- object )
    {
        { 1 [ predictor-none ] }
        { 2 [ predictor-horizontal-differencing ] }
        [ bad-predictor ]
    } case ;

SINGLETONS: planar-configuration
planar-configuration-chunky
planar-configuration-planar ;
ERROR: bad-planar-configuration n ;
: lookup-planar-configuration ( n -- object )
    {
        { 1 [ planar-configuration-chunky ] }
        { 2 [ planar-configuration-planar ] }
        [ bad-planar-configuration ]
    } case ;

SINGLETONS: sample-format
sample-format-unsigned-integer
sample-format-signed-integer
sample-format-ieee-float
sample-format-undefined-data ;
ERROR: bad-sample-format n ;
: lookup-sample-format ( sequence -- object )
    [
        {
            { 1 [ sample-format-unsigned-integer ] }
            { 2 [ sample-format-signed-integer ] }
            { 3 [ sample-format-ieee-float ] }
            { 4 [ sample-format-undefined-data ] }
            [ bad-sample-format ]
        } case
    ] map ;

SINGLETONS: extra-samples
extra-samples-unspecified-alpha-data
extra-samples-associated-alpha-data
extra-samples-unassociated-alpha-data ;
ERROR: bad-extra-samples n ;
: lookup-extra-samples ( sequence -- object )
    {
        { 0 [ extra-samples-unspecified-alpha-data ] }
        { 1 [ extra-samples-associated-alpha-data ] }
        { 2 [ extra-samples-unassociated-alpha-data ] }
        [ bad-extra-samples ]
    } case ;

SINGLETONS: image-length image-width x-resolution y-resolution
rows-per-strip strip-offsets strip-byte-counts bits-per-sample
samples-per-pixel new-subfile-type orientation software
date-time photoshop exif-ifd sub-ifd inter-color-profile
xmp iptc unhandled-ifd-entry ;

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

: push-ifd ( tiff ifd -- tiff ) over ifds>> push ;

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
    swap processed-tags>> ?at [ no-tag ] unless ;

: read-strips ( ifd -- ifd )
    dup
    [ strip-byte-counts find-tag ]
    [ strip-offsets find-tag ] bi
    2dup [ integer? ] both? [
        seek-absolute seek-input read 1array
    ] [
        [ seek-absolute seek-input read ] { } 2map-as
    ] if >>strips ;

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
        { 13 [ 4 * ] }
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
        { 13 [ endian> 32 >signed ] }
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

: process-ifd-entry ( ifd-entry -- value class )
    [ ifd-entry-value ] [ tag>> ] bi {
        { 254 [ new-subfile-type ] }
        { 256 [ image-width ] }
        { 257 [ image-length ] }
        { 258 [ bits-per-sample ] }
        { 259 [ lookup-compression compression ] }
        { 262 [ lookup-photometric-interpretation photometric-interpretation ] }
        { 273 [ strip-offsets ] }
        { 274 [ orientation ] }
        { 277 [ samples-per-pixel ] }
        { 278 [ rows-per-strip ] }
        { 279 [ strip-byte-counts ] }
        { 282 [ first x-resolution ] }
        { 283 [ first y-resolution ] }
        { 284 [ planar-configuration ] }
        { 296 [ lookup-resolution-unit resolution-unit ] }
        { 305 [ ascii decode software ] }
        { 306 [ ascii decode date-time ] }
        { 317 [ lookup-predictor predictor ] }
        { 330 [ sub-ifd ] }
        { 338 [ lookup-extra-samples extra-samples ] }
        { 339 [ lookup-sample-format sample-format ] }
        { 700 [ utf8 decode xmp ] }
        { 34377 [ photoshop ] }
        { 34665 [ exif-ifd ] }
        { 33723 [ iptc ] }
        { 34675 [ inter-color-profile ] }
        [ nip unhandled-ifd-entry swap ]
    } case ;

: process-ifd ( ifd -- ifd )
    dup ifd-entries>>
    [ process-ifd-entry swap ] H{ } map>assoc >>processed-tags ;

ERROR: unhandled-compression compression ;

: (uncompress-strips) ( strips compression -- uncompressed-strips )
    {
        { compression-none [ ] }
        { compression-lzw [ [ lzw-uncompress ] map ] }
        [ unhandled-compression ]
    } case ;

: uncompress-strips ( ifd -- ifd )
    dup '[
        _ compression find-tag (uncompress-strips)
    ] change-strips ;

: strips>bitmap ( ifd -- ifd )
    dup strips>> concat >>bitmap ;

ERROR: unknown-component-order ifd ;

: fix-bitmap-endianness ( ifd -- ifd )
    dup [ bitmap>> ] [ bits-per-sample find-tag ] bi
    {
        { { 32 32 32 32 } [ 4 seq>native-endianness ] }
        { { 32 32 32 } [ 4 seq>native-endianness ] }
        { { 16 16 16 16 } [ 2 seq>native-endianness ] }
        { { 16 16 16 } [ 2 seq>native-endianness ] }
        { { 8 8 8 8 } [ ] }
        { { 8 8 8 } [ ] }
        [ unknown-component-order ]
    } case >>bitmap ;

: ifd-component-order ( ifd -- byte-order )
    bits-per-sample find-tag {
        { { 32 32 32 } [ R32G32B32 ] }
        { { 16 16 16 } [ R16G16B16 ] }
        { { 8 8 8 8 } [ RGBA ] }
        { { 8 8 8 } [ RGB ] }
        [ unknown-component-order ]
    } case ;

: ifd>image ( ifd -- image )
    {
        [ [ image-width find-tag ] [ image-length find-tag ] bi 2array ]
        [ ifd-component-order ]
        [ bitmap>> ]
    } cleave tiff-image boa ;

: tiff>image ( image -- image )
    ifds>> [ ifd>image ] map first ;

: load-tiff ( path -- parsed-tiff )
    binary [
        <parsed-tiff>
        read-header dup endianness>> [
            read-ifds
            dup ifds>> [
                process-ifd read-strips
                uncompress-strips
                strips>bitmap
                fix-bitmap-endianness
                drop
            ] each
        ] with-endianness
    ] with-file-reader ;

! tiff files can store several images -- we just take the first for now
M: tiff-image load-image* ( path tiff-image -- image )
    drop load-tiff tiff>image ;
