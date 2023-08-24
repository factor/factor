! Copyright (C) 2010 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar colors combinators
continuations endian hashtables images images.loader io
io.encodings.ascii io.encodings.string io.streams.throwing
kernel math math.parser ranges sequences ;
IN: images.tga

SINGLETON: tga-image
"tga" tga-image ?register-image-class

ERROR: bad-tga-header ;
ERROR: bad-tga-footer ;
ERROR: bad-tga-extension-size ;
ERROR: bad-tga-timestamp ;
ERROR: bad-tga-unsupported ;

: read-id-length ( -- byte )
    1 read le> ; inline

: read-color-map-type ( -- byte )
    1 read le> dup
    { 0 1 } member? [ bad-tga-header ] unless ;

: read-image-type ( -- byte )
    1 read le> dup
    { 0 1 2 3 9 10 11 } member? [ bad-tga-header ] unless ; inline

: read-color-map-first ( -- short )
    2 read le> ; inline

: read-color-map-length ( -- short )
    2 read le> ; inline

: read-color-map-entry-size ( -- byte )
    1 read le> ; inline

: read-x-origin ( -- short )
    2 read le> ; inline

: read-y-origin ( -- short )
    2 read le> ; inline

: read-image-width ( -- short )
    2 read le> ; inline

: read-image-height ( -- short )
    2 read le> ; inline

: read-pixel-depth ( -- byte )
    1 read le> ; inline

: read-image-descriptor ( -- alpha-bits pixel-order )
    1 read le>
    [ 7 bitand ] [ 24 bitand -3 shift ] bi ; inline

: read-image-id ( length -- image-id )
    read ; inline

: read-color-map ( type length elt-size -- color-map )
    pick 1 = [ 8 align 8 / * read ] [ 2drop f ] if nip ; inline

: read-image-data ( width height depth -- image-data )
    8 align 8 / * * read ; inline

: read-extension-area-offset ( -- offset )
    4 read le> ; inline

: read-developer-directory-offset ( -- offset )
    4 read le> ; inline

: read-signature ( -- )
    18 read ascii decode "TRUEVISION-XFILE.\0" = [ bad-tga-footer ] unless ; inline

: read-extension-size ( -- )
    2 read le> 495 = [ bad-tga-extension-size ] unless ; inline

: read-author-name ( -- string )
    41 read ascii decode [ 0 = ] trim ; inline

: read-author-comments ( -- string )
    4 <iota> [ drop 81 read ascii decode [ 0 = ] trim ] map concat ; inline

: read-date-timestamp ( -- timestamp )
    timestamp new
    2 read le> dup 12 [1..b] member? [ bad-tga-timestamp ] unless >>month
    2 read le> dup 31 [1..b] member? [ bad-tga-timestamp ] unless >>day
    2 read le>                                                   >>year
    2 read le> dup 23 [0..b] member? [ bad-tga-timestamp ] unless >>hour
    2 read le> dup 59 [0..b] member? [ bad-tga-timestamp ] unless >>minute
    2 read le> dup 59 [0..b] member? [ bad-tga-timestamp ] unless >>second ; inline

: read-job-name ( -- string )
    41 read ascii decode [ 0 = ] trim ; inline

: read-job-time ( -- duration )
    duration new
    2 read le>                                                   >>hour
    2 read le> dup 59 [0..b] member? [ bad-tga-timestamp ] unless >>minute
    2 read le> dup 59 [0..b] member? [ bad-tga-timestamp ] unless >>second ; inline

: read-software-id ( -- string )
    41 read ascii decode [ 0 = ] trim ; inline

: read-software-version ( -- string )
    2 read le> 100 /f number>string
    1 read ascii decode append [ " " = ] trim ; inline

:: read-key-color ( -- color )
    1 read le> 255 /f :> alpha
    1 read le> 255 /f
    1 read le> 255 /f
    1 read le> 255 /f
    alpha <rgba> ; inline

: read-pixel-aspect-ratio ( -- aspect-ratio )
    2 read le> 2 read le> /f ; inline

: read-gamma-value ( -- gamma-value )
    2 read le> 2 read le> /f ; inline

: read-color-correction-offset ( -- offset )
    4 read le> ; inline

: read-postage-stamp-offset ( -- offset )
    4 read le> ; inline

: read-scan-line-offset ( -- offset )
    4 read le> ; inline

: read-premultiplied-alpha ( -- boolean )
    1 read le> 4 = ; inline

: read-scan-line-table ( height -- scan-offsets )
    <iota> [ drop 4 read le> ] map ; inline

: read-postage-stamp-image ( depth -- postage-data )
    8 align 8 / 1 read le> 1 read le> * * read ; inline

:: read-color-correction-table ( -- correction-table )
    256 <iota>
    [
        drop
        4 <iota>
        [
            drop
            2 read le> 65535 /f :> alpha
            2 read le> 65535 /f
            2 read le> 65535 /f
            2 read le> 65535 /f
            alpha <rgba>
        ] map
    ] map ; inline

: read-developer-directory ( -- developer-directory )
    2 read le> <iota>
    [
        drop
        2 read le>
        4 read le>
        4 read le>
        3array
    ] map ; inline

: read-developer-areas ( developer-directory -- developer-area-map )
    [
        [ first ]
        [ dup third second seek-absolute seek-input read ] bi 2array
    ] map >hashtable ; inline

:: read-tga ( -- image )
    ! Read header
    read-id-length                                       :> id-length
    read-color-map-type                                  :> map-type
    read-image-type                                      :> image-type
    read-color-map-first                                 :> map-first
    read-color-map-length                                :> map-length
    read-color-map-entry-size                            :> map-entry-size
    read-x-origin                                        :> x-origin
    read-y-origin                                        :> y-origin
    read-image-width                                     :> image-width
    read-image-height                                    :> image-height
    read-pixel-depth                                     :> pixel-depth
    read-image-descriptor                                :> ( alpha-bits pixel-order )
    id-length read-image-id                              :> image-id
    map-type map-length map-entry-size read-color-map    :> color-map-data
    image-width image-height pixel-depth read-image-data :> image-data

    [
        ! Read optional footer
        26 seek-end seek-input
        read-extension-area-offset      :> extension-offset
        read-developer-directory-offset :> directory-offset
        read-signature

        ! Read optional extension section
        extension-offset 0 =
        [
            extension-offset seek-absolute seek-input
            read-extension-size
            read-author-name             :> author-name
            read-author-comments         :> author-comments
            read-date-timestamp          :> date-timestamp
            read-job-name                :> job-name
            read-job-time                :> job-time
            read-software-id             :> software-id
            read-software-version        :> software-version
            read-key-color               :> key-color
            read-pixel-aspect-ratio      :> aspect-ratio
            read-gamma-value             :> gamma-value
            read-color-correction-offset :> color-correction-offset
            read-postage-stamp-offset    :> postage-stamp-offset
            read-scan-line-offset        :> scan-line-offset
            read-premultiplied-alpha     :> premultiplied-alpha

            color-correction-offset 0 =
            [
                color-correction-offset seek-absolute seek-input
                read-color-correction-table :> color-correction-table
            ] unless

            postage-stamp-offset 0 =
            [
                postage-stamp-offset seek-absolute seek-input
                pixel-depth read-postage-stamp-image :> postage-data
            ] unless

            scan-line-offset seek-absolute seek-input
            image-height read-scan-line-table :> scan-offsets

            ! Read optional developer section
            directory-offset 0 =
            [ f ]
            [
                directory-offset seek-absolute seek-input
                read-developer-directory read-developer-areas
            ] if :> developer-areas
        ] unless
    ] ignore-errors

    ! Only 24-bit uncompressed BGR and 32-bit uncompressed BGRA are supported.
    ! Other formats would need to be converted to work within the image class.
    map-type 0 = [ bad-tga-unsupported ] unless
    image-type 2 = [ bad-tga-unsupported ] unless
    pixel-depth { 24 32 } member? [ bad-tga-unsupported ] unless
    pixel-order { 0 2 } member? [ bad-tga-unsupported ] unless

    ! Create image instance
    image new
    alpha-bits 0 = [ BGR ] [ BGRA ] if >>component-order
    { image-width image-height }       >>dim
    pixel-order 0 =                    >>upside-down?
    image-data                         >>bitmap
    ubyte-components                   >>component-type ;

M: tga-image stream>image*
    drop [ [ read-tga ] throw-on-eof ] with-input-stream ;

M: tga-image image>stream
    2drop
    [
        component-order>> { BGRA BGRA } member? [ bad-tga-unsupported ] unless
    ] keep

    B{ 0 }         write ! id-length
    B{ 0 }         write ! map-type
    B{ 2 }         write ! image-type
    B{ 0 0 0 0 0 } write ! color map first, length, entry size
    B{ 0 0 0 0 }   write ! x-origin, y-origin
    {
        [ dim>> first 2 >le write ]
        [ dim>> second 2 >le write ]
        [ component-order>>
          {
              {  BGR [ B{ 24 } write ] }
              { BGRA [ B{ 32 } write ] }
          } case
        ]
        [
            dup component-order>>
            {
                {  BGR [ 0 ] }
                { BGRA [ 8 ] }
            } case swap
            upside-down?>> [ 0 ] [ 2 ] if 3 shift bitor
            1 >le write
        ]
        [ bitmap>> write ]
    } cleave ;
