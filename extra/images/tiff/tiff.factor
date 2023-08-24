! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays combinators
combinators.short-circuit compression.lzw endian grouping
images images.loader io io.encodings.ascii
io.encodings.string io.encodings.utf8 io.streams.throwing kernel
math math.bitwise math.vectors pack sequences ;
IN: images.tiff

SINGLETON: tiff-image

TUPLE: loading-tiff endianness the-answer ifd-offset ifds ;

: <loading-tiff> ( -- tiff )
    loading-tiff new
        H{ } clone >>ifds ; inline

! offset, next-offset, and count are not strictly necessary here
! count is just the length of ifd-entries
TUPLE: ifd offset next-offset count
ifd-entries processed-tags strips bitmap ;

: <ifd> ( offset count ifd-entries next-offset -- ifd )
    ifd new
        swap >>next-offset
        swap >>ifd-entries
        swap >>count
        swap >>offset ;

TUPLE: ifd-entry tag type count offset/value ;

: <ifd-entry> ( tag type count offset/value -- ifd-entry )
    ifd-entry new
        swap >>offset/value
        swap >>count
        swap >>type
        swap >>tag ;

SINGLETONS: photometric-interpretation
photometric-interpretation-white-is-zero
photometric-interpretation-black-is-zero
photometric-interpretation-rgb
photometric-interpretation-palette-color
photometric-interpretation-transparency-mask
photometric-interpretation-separated
photometric-interpretation-ycbcr
photometric-interpretation-cielab
photometric-interpretation-icclab
photometric-interpretation-itulab
photometric-interpretation-logl
photometric-interpretation-logluv ;

ERROR: bad-photometric-interpretation n ;
: lookup-photometric-interpretation ( n -- singleton )
    {
        { 0 [ photometric-interpretation-white-is-zero ] }
        { 1 [ photometric-interpretation-black-is-zero ] }
        { 2 [ photometric-interpretation-rgb ] }
        { 3 [ photometric-interpretation-palette-color ] }
        { 4 [ photometric-interpretation-transparency-mask ] }
        { 5 [ photometric-interpretation-separated ] }
        { 6 [ photometric-interpretation-ycbcr ] }
        { 8 [ photometric-interpretation-cielab ] }
        { 9 [ photometric-interpretation-icclab ] }
        { 10 [ photometric-interpretation-itulab ] }
        { 32844 [ photometric-interpretation-logl ] }
        { 32845 [ photometric-interpretation-logluv ] }
        [ bad-photometric-interpretation ]
    } case ;

SINGLETONS: compression
compression-none
compression-CCITT-2
compression-CCITT-3
compression-CCITT-4
compression-lzw
compression-jpeg-old
compression-jpeg-new
compression-adobe-deflate
compression-9
compression-10
compression-deflate
compression-next
compression-ccittrlew
compression-pack-bits
compression-thunderscan
compression-it8ctpad
compression-it8lw
compression-it8mp
compression-it8bl
compression-pixarfilm
compression-pixarlog
compression-dcs
compression-jbig
compression-sgilog
compression-sgilog24
compression-jp2000 ;
ERROR: bad-compression n ;
: lookup-compression ( n -- compression )
    {
        { 1 [ compression-none ] }
        { 2 [ compression-CCITT-2 ] }
        { 3 [ compression-CCITT-3 ] }
        { 4 [ compression-CCITT-4 ] }
        { 5 [ compression-lzw ] }
        { 6 [ compression-jpeg-old ] }
        { 7 [ compression-jpeg-new ] }
        { 8 [ compression-adobe-deflate ] }
        { 9 [ compression-9 ] }
        { 10 [ compression-10 ] }
        { 32766 [ compression-next ] }
        { 32771 [ compression-ccittrlew ] }
        { 32773 [ compression-pack-bits ] }
        { 32809 [ compression-thunderscan ] }
        { 32895 [ compression-it8ctpad ] }
        { 32896 [ compression-it8lw ] }
        { 32897 [ compression-it8mp ] }
        { 32898 [ compression-it8bl ] }
        { 32908 [ compression-pixarfilm ] }
        { 32909 [ compression-pixarlog ] }
        { 32946 [ compression-deflate ] }
        { 32947 [ compression-dcs ] }
        { 34661 [ compression-jbig ] }
        { 34676 [ compression-sgilog ] }
        { 34677 [ compression-sgilog24 ] }
        { 34712 [ compression-jp2000 ] }
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
sample-format-none
sample-format-unsigned-integer
sample-format-signed-integer
sample-format-ieee-float
sample-format-undefined-data ;
ERROR: bad-sample-format n ;
: lookup-sample-format ( sequence -- object )
    [
        {
            { 0 [ sample-format-none ] }
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
samples-per-pixel new-subfile-type subfile-type orientation
software date-time photoshop exif-ifd sub-ifd inter-color-profile
xmp iptc fill-order document-name page-number page-name
x-position y-position host-computer copyright artist
min-sample-value max-sample-value tiff-make tiff-model cell-width cell-length
gray-response-unit gray-response-curve color-map threshholding
image-description free-offsets free-byte-counts tile-width tile-length
matteing data-type image-depth tile-depth
ycbcr-subsampling gdal-metadata
tile-offsets tile-byte-counts jpeg-qtables jpeg-dctables jpeg-actables
ycbcr-positioning ycbcr-coefficients reference-black-white halftone-hints
jpeg-interchange-format
jpeg-interchange-format-length
jpeg-restart-interval jpeg-tables
t4-options clean-fax-data bad-fax-lines consecutive-bad-fax-lines
sto-nits print-image-matching-info
unhandled-ifd-entry ;

SINGLETONS: jpeg-proc
jpeg-proc-baseline
jpeg-proc-lossless ;

ERROR: bad-jpeg-proc n ;

: lookup-jpeg-proc ( sequence -- object )
    {
        { 1 [ jpeg-proc-baseline ] }
        { 14 [ jpeg-proc-lossless ] }
        [ bad-jpeg-proc ]
    } case ;

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

: store-ifd ( tiff ifd -- tiff )
    dup offset>> pick ifds>> set-at ;

: read-ifd-entry ( -- ifd )
    2 read endian>
    2 read endian>
    4 read endian>
    4 read endian> <ifd-entry> ;

: read-ifd ( offset -- ifd )
    dup seek-absolute seek-input
    2 read endian>
    dup [ read-ifd-entry ] replicate

    ! next ifd offset, 0 for stop
    4 read endian>
    <ifd> ;

: read-ifds ( tiff offset -- tiff )
    read-ifd
    [ store-ifd ]
    [
        next-offset>> dup { [ 0 > ] [ pick ifds>> key? not ] } 1&& [
            read-ifds
        ] [
            drop
        ] if
    ] bi ;

ERROR: no-tag class ;

: find-tag* ( ifd class -- tag/class ? )
    swap processed-tags>> ?at ;

: find-tag ( ifd class -- tag )
    find-tag* [ no-tag ] unless ;

: tag? ( ifd class -- tag )
    swap processed-tags>> key? ;

: read-strips ( ifd -- ifd )
    dup
    [ strip-byte-counts find-tag ]
    [ strip-offsets find-tag ] bi
    2dup [ integer? ] both? [
        seek-absolute seek-input read 1array
    ] [
        [ seek-absolute seek-input read ] { } 2map-as
    ] if >>strips ;

ERROR: unknown-ifd-type n where ;

: bytes>bits ( n/byte-array -- n )
    dup byte-array? [ le> ] when ;

! TODO: Should skip entire ifd-entry instead of throwing
! if type is unknown (e.g. type 0 from the AFL american fuzzy loop test cases)
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
        [ "value-length" unknown-ifd-type ]
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
        { 3 [ 2 <groups> [ endian> ] map ] }
        { 4 [ 4 <groups> [ endian> ] map ] }
        { 5 [ 8 <groups> [ "II" unpack first2 / ] map ] }
        { 6 [ [ 8 >signed ] map ] }
        { 7 [ ] } ! blank
        { 8 [ 2 <groups> [ endian> 16 >signed ] map ] }
        { 9 [ 4 <groups> [ endian> 32 >signed ] map ] }
        { 10 [ 8 group [ "ii" unpack first2 / ] map ] }
        { 11 [ 4 group [ "f" unpack ] map ] }
        { 12 [ 8 group [ "d" unpack ] map ] }
        [ "offset-bytes>obj" unknown-ifd-type ]
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
        { 255 [ subfile-type ] }
        { 256 [ image-width ] }
        { 257 [ image-length ] }
        { 258 [ bits-per-sample ] }
        { 259 [ lookup-compression compression ] }
        { 262 [ lookup-photometric-interpretation photometric-interpretation ] }
        { 263 [ threshholding ] }
        { 264 [ cell-width ] }
        { 265 [ cell-length ] }
        { 266 [ fill-order ] }
        { 269 [ ascii decode document-name ] }
        { 270 [ ascii decode image-description ] }
        { 271 [ ascii decode tiff-make ] }
        { 272 [ ascii decode tiff-model ] }
        { 273 [ strip-offsets ] }
        { 274 [ orientation ] }
        { 277 [ samples-per-pixel ] }
        { 278 [ rows-per-strip ] }
        { 279 [ strip-byte-counts ] }
        { 280 [ min-sample-value ] }
        { 281 [ max-sample-value ] }
        { 282 [ first x-resolution ] }
        { 283 [ first y-resolution ] }
        { 284 [ lookup-planar-configuration planar-configuration ] }
        { 285 [ page-name ] }
        { 286 [ x-position ] }
        { 287 [ y-position ] }
        { 288 [ free-offsets ] }
        { 289 [ free-byte-counts ] }
        { 290 [ gray-response-unit ] }
        { 291 [ gray-response-curve ] }
        { 292 [ t4-options ] }
        { 296 [ lookup-resolution-unit resolution-unit ] }
        { 297 [ page-number ] }
        { 305 [ ascii decode software ] }
        { 306 [ ascii decode date-time ] }
        { 315 [ ascii decode artist ] }
        { 316 [ ascii decode host-computer ] }
        { 317 [ lookup-predictor predictor ] }
        { 320 [ color-map ] }
        { 321 [ halftone-hints ] }
        { 322 [ tile-width ] }
        { 323 [ tile-length ] }
        { 324 [ tile-offsets ] }
        { 325 [ tile-byte-counts ] }
        { 326 [ bad-fax-lines ] }
        { 327 [ clean-fax-data ] }
        { 328 [ consecutive-bad-fax-lines ] }
        { 330 [ sub-ifd ] }
        { 338 [ lookup-extra-samples extra-samples ] }
        { 339 [ lookup-sample-format sample-format ] }
        { 347 [ jpeg-tables ] }
        { 512 [ lookup-jpeg-proc jpeg-proc ] }
        { 513 [ jpeg-interchange-format ] }
        { 514 [ jpeg-interchange-format-length ] }
        { 515 [ jpeg-restart-interval ] }
        { 519 [ jpeg-qtables ] }
        { 520 [ jpeg-dctables ] }
        { 521 [ jpeg-actables ] }
        { 529 [ ycbcr-coefficients ] }
        { 530 [ ycbcr-subsampling ] }
        { 531 [ ycbcr-positioning ] }
        { 532 [ reference-black-white ] }
        { 700 [ utf8 decode xmp ] }
        { 32995 [ matteing ] }
        { 32996 [ data-type ] }
        { 32997 [ image-depth ] }
        { 32998 [ tile-depth ] }
        { 33432 [ copyright ] }
        { 33723 [ iptc ] }
        { 34377 [ photoshop ] }
        { 34665 [ exif-ifd ] }
        { 34675 [ inter-color-profile ] }
        { 37439 [ sto-nits ] }
        { 42112 [ gdal-metadata ] }
        { 50341 [ print-image-matching-info ] }
        [ nip unhandled-ifd-entry swap ]
    } case ;

: process-ifds ( loading-tiff -- loading-tiff )
    [
        [
            dup ifd-entries>>
            [ process-ifd-entry swap ] H{ } map>assoc >>processed-tags
        ] assoc-map
    ] change-ifds ;

ERROR: unhandled-compression compression ;

: (uncompress-strips) ( strips compression -- uncompressed-strips )
    {
        { compression-none [ ] }
        { compression-lzw [ [ tiff-lzw-uncompress ] map ] }
        [ unhandled-compression ]
    } case ;

: uncompress-strips ( ifd -- ifd )
    dup '[
        _ compression find-tag (uncompress-strips)
    ] change-strips ;

: strips>bitmap ( ifd -- ifd )
    dup strips>> concat >>bitmap ;

: (strips-predictor) ( ifd -- ifd )
    [ ]
    [ image-width find-tag ]
    [ samples-per-pixel find-tag ] tri
    [ * ] keep
    '[
        _ group
        [ _ [ group ] [ 0 <array> ] bi [ v+ ] accumulate* concat ] map
        B{ } concat-as
    ] change-bitmap ;

: strips-predictor ( ifd -- ifd )
    dup predictor tag? [
        dup predictor find-tag
        {
            { predictor-none [ ] }
            { predictor-horizontal-differencing [ (strips-predictor) ] }
            [ bad-predictor ]
        } case
    ] when ;

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
        { 8 [ ] }
        [ unknown-component-order ]
    } case >>bitmap ;

: ifd-component-order ( ifd -- component-order component-type )
    bits-per-sample find-tag {
        { { 32 32 32 32 } [ RGBA float-components ] }
        { { 32 32 32 } [ RGB float-components ] }
        { { 16 16 16 16 } [ RGBA ushort-components ] }
        { { 16 16 16 } [ RGB ushort-components ] }
        { { 8 8 8 8 } [ RGBA ubyte-components ] }
        { { 8 8 8 } [ RGB ubyte-components ] }
        { 8 [ LA ubyte-components ] }
        [ unknown-component-order ]
    } case ;

: handle-alpha-data ( ifd -- ifd )
    dup extra-samples find-tag {
        { extra-samples-associated-alpha-data [ ] }
        { extra-samples-unspecified-alpha-data [ ] }
        { extra-samples-unassociated-alpha-data [ ] }
        [ bad-extra-samples ]
    } case ;

: ifd>image ( ifd -- image )
    [ <image> ] dip {
        [ [ image-width find-tag ] [ image-length find-tag ] bi 2array >>dim ]
        [ ifd-component-order [ >>component-order ] [ >>component-type ] bi* ]
        [ bitmap>> >>bitmap ]
    } cleave ;

: tiff>image ( image -- image )
    ifds>> values [ ifd>image ] map first ;

: with-tiff-endianness ( loading-tiff quot -- )
    [ dup endianness>> ] dip with-endianness ; inline

: load-tiff-ifds ( -- loading-tiff )
    <loading-tiff>
    read-header [
        dup ifd-offset>> read-ifds
        process-ifds
    ] with-tiff-endianness ;

: process-chunky-ifd ( ifd -- )
    read-strips
    uncompress-strips
    strips>bitmap
    fix-bitmap-endianness
    strips-predictor
    dup extra-samples tag? [ handle-alpha-data ] when
    drop ;

: process-planar-ifd ( ifd -- )
    "planar ifd not supported" throw ;

: dispatch-planar-configuration ( ifd planar-configuration -- )
    {
        { planar-configuration-chunky [ process-chunky-ifd ] }
        { planar-configuration-planar [ process-planar-ifd ] }
    } case ;

: process-ifd ( ifd -- )
    dup planar-configuration find-tag* [
        dispatch-planar-configuration
    ] [
        drop "no planar configuration" throw
    ] if ;

: process-tif-ifds ( loading-tiff -- )
    ifds>> values [ process-ifd ] each ;

: load-tiff ( -- loading-tiff )
    load-tiff-ifds dup
    0 seek-absolute seek-input
    [ process-tif-ifds ] with-tiff-endianness ;

! tiff files can store several images -- we just take the first for now
M: tiff-image stream>image* ( stream tiff-image -- image )
    drop [ [ load-tiff tiff>image ] throw-on-eof ] with-input-stream ;

{ "tif" "tiff" } [ tiff-image ?register-image-class ] each
