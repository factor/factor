! Copyrigt (C) 2009 Doug Coleman, Keith Lazuka
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators compression.lzw constructors
endian grouping images images.loader io io.encodings.string
io.encodings.utf8 kernel make math math.bitwise sequences ;
IN: images.gif

SINGLETON: gif-image
"gif" gif-image ?register-image-class

TUPLE: loading-gif
loading?
magic
width height
flags
background-color
default-aspect-ratio
global-color-table
graphic-control-extensions
application-extensions
plain-text-extensions
comment-extensions

image-descriptor
local-color-table
compressed-bytes ;

TUPLE: gif-frame
image-descriptor
local-color-table ;

ERROR: unsupported-gif-format magic ;
ERROR: unknown-extension n ;
ERROR: gif-unexpected-eof ;

TUPLE: graphics-control-extension
flags delay-time transparent-color-index ;

TUPLE: image-descriptor
left top width height flags first-code-size ;

TUPLE: plain-text-extension
introducer label block-size text-grid-left text-grid-top text-grid-width
text-grid-height cell-width cell-height
text-fg-color-index text-bg-color-index plain-text-data ;

TUPLE: application-extension
introducer label block-size identifier authentication-code
application-data ;

TUPLE: comment-extension
introducer label comment-data ;

TUPLE: trailer byte ;
CONSTRUCTOR: <trailer> trailer ( byte -- obj ) ;

CONSTANT: IMAGE-DESCRIPTOR 0x2c
! Extensions
CONSTANT: EXTENSION-IDENTIFIER 0x21
CONSTANT: PLAIN-TEXT-EXTENSION 0x01
CONSTANT: GRAPHICS-CONTROL-EXTENSION 0xf9
CONSTANT: COMMENT-EXTENSION 0xfe
CONSTANT: APPLICATION-EXTENSION 0xff
CONSTANT: TRAILER 0x3b
CONSTANT: GRAPHIC-CONTROL-EXTENSION-BLOCK-SIZE 0x04
CONSTANT: BLOCK-TERMINATOR 0x00

: <loading-gif> ( -- loading-gif )
    \ loading-gif new
        V{ } clone >>graphic-control-extensions
        V{ } clone >>application-extensions
        V{ } clone >>plain-text-extensions
        V{ } clone >>comment-extensions
        t >>loading? ;

: (read-sub-blocks) ( -- )
    read1 [ read , (read-sub-blocks) ] unless-zero ;

: read-sub-blocks ( -- bytes )
    [ (read-sub-blocks) ] { } make B{ } concat-as ;

: read-image-descriptor ( -- image-descriptor )
    \ image-descriptor new
        2 read le> >>left
        2 read le> >>top
        2 read le> >>width
        2 read le> >>height
        1 read le> >>flags
        1 read le> 1 + >>first-code-size ;

: read-graphic-control-extension ( -- graphic-control-extension )
    \ graphics-control-extension new
        1 read le> GRAPHIC-CONTROL-EXTENSION-BLOCK-SIZE assert=
        1 read le> >>flags
        2 read le> >>delay-time
        1 read le> >>transparent-color-index
        1 read le> BLOCK-TERMINATOR assert= ;

: read-plain-text-extension ( -- plain-text-extension )
    \ plain-text-extension new
        1 read le> >>block-size
        2 read le> >>text-grid-left
        2 read le> >>text-grid-top
        2 read le> >>text-grid-width
        2 read le> >>text-grid-height
        1 read le> >>cell-width
        1 read le> >>cell-height
        1 read le> >>text-fg-color-index
        1 read le> >>text-bg-color-index
        read-sub-blocks >>plain-text-data ;

: read-comment-extension ( -- comment-extension )
    \ comment-extension new
        read-sub-blocks >>comment-data ;

: read-application-extension ( -- read-application-extension )
    \ application-extension new
        1 read le> >>block-size
        8 read utf8 decode >>identifier
        3 read >>authentication-code
        read-sub-blocks >>application-data ;

: read-gif-header ( loading-gif -- loading-gif )
    6 read utf8 decode >>magic ;

ERROR: unimplemented message ;
: read-GIF87a ( loading-gif -- loading-gif )
    "GIF87a" unimplemented ;

: read-logical-screen-descriptor ( loading-gif -- loading-gif )
    2 read le> >>width
    2 read le> >>height
    1 read le> >>flags
    1 read le> >>background-color
    1 read le> >>default-aspect-ratio ;

: color-table? ( image -- ? ) flags>> 7 bit? ; inline
: interlaced? ( image -- ? ) flags>> 6 bit? ; inline
: sort? ( image -- ? ) flags>> 5 bit? ; inline
: color-table-size ( image -- ? ) flags>> 3 bits 1 + 2^ 3 * ; inline
: transparency? ( image -- ? )
    graphic-control-extensions>>
    [ f ] [ first flags>> 0 bit? ] if-empty ; inline

: color-resolution ( image -- ? ) flags>> -4 shift 3 bits ; inline

: read-global-color-table ( loading-gif -- loading-gif )
    dup color-table? [
        dup color-table-size read 3 group >>global-color-table
    ] when ;

: maybe-read-local-color-table ( loading-gif -- loading-gif )
    dup image-descriptor>> color-table? [
        dup color-table-size read >>local-color-table
    ] when ;

: read-image-data ( loading-gif -- loading-gif )
    read-sub-blocks >>compressed-bytes ;

: read-table-based-image ( loading-gif -- loading-gif )
    read-image-descriptor >>image-descriptor
    maybe-read-local-color-table
    read-image-data ;

: read-graphic-rendering-block ( loading-gif -- loading-gif )
    read-table-based-image ;

: read-extension ( loading-gif -- loading-gif )
    read1 {
        { PLAIN-TEXT-EXTENSION [
            read-plain-text-extension over plain-text-extensions>> push
        ] }

        { GRAPHICS-CONTROL-EXTENSION [
            read-graphic-control-extension
            over graphic-control-extensions>> push
        ] }
        { COMMENT-EXTENSION [
            read-comment-extension over comment-extensions>> push
        ] }
        { APPLICATION-EXTENSION [
            read-application-extension over application-extensions>> push
        ] }
        { f [ gif-unexpected-eof ] }
        [ unknown-extension ]
    } case ;

ERROR: unhandled-data byte ;

: read-data ( loading-gif -- loading-gif )
    read1 {
        { EXTENSION-IDENTIFIER [ read-extension ] }
        { GRAPHICS-CONTROL-EXTENSION [
            read-graphic-control-extension
            over graphic-control-extensions>> push
        ] }
        { IMAGE-DESCRIPTOR [ read-table-based-image ] }
        { TRAILER [ f >>loading? ] }
        [ unhandled-data ]
    } case ;

: read-GIF89a ( loading-gif -- loading-gif )
    read-logical-screen-descriptor
    read-global-color-table
    [ read-data dup loading?>> ] loop ;

: load-gif ( stream -- loading-gif )
    [
        <loading-gif>
        read-gif-header dup magic>> {
            { "GIF87a" [ read-GIF87a ] }
            { "GIF89a" [ read-GIF89a ] }
            [ unsupported-gif-format ]
        } case
    ] with-input-stream ;

: decompress ( loading-gif -- indexes )
    [ compressed-bytes>> ]
    [ image-descriptor>> first-code-size>> ] bi
    gif-lzw-uncompress ;

: colorize ( index palette transparent-index/f -- seq )
    pick = [ 2drop B{ 0 0 0 0 } ] [ nth 255 suffix ] if ;

: apply-palette ( indexes palette transparent-index/f -- bitmap )
    [ colorize ] 2curry V{ } map-as concat ;

: dimensions ( loading-gif -- dim )
    [ image-descriptor>> width>> ] [ image-descriptor>> height>> ] bi 2array ;

: ?transparent-color-index ( loading-gif -- index/f )
    dup transparency?
    [ graphic-control-extensions>> first transparent-color-index>> ]
    [ drop f ] if ;

: gif>image ( loading-gif -- image )
    [ <image> ] dip
    [ dimensions >>dim ]
    [ drop RGBA >>component-order ubyte-components >>component-type ]
    [
        [ decompress ] [ global-color-table>> ] [ ?transparent-color-index ] tri
        apply-palette >>bitmap
    ] tri ;

ERROR: loading-gif-error gif-image ;

: ensure-loaded ( gif-image -- gif-image )
    dup loading?>> [ loading-gif-error ] when ;

M: gif-image stream>image* ( path gif-image -- image )
    drop load-gif ensure-loaded gif>image ;
