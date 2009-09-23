! Copyrigt (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators constructors destructors
images images.loader io io.binary io.buffers
io.encodings.binary io.encodings.string io.encodings.utf8
io.files io.files.info io.ports io.streams.limited kernel make
math math.bitwise math.functions multiline namespaces
prettyprint sequences ;
IN: images.gif

SINGLETON: gif-image
"gif" gif-image register-image-class

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
label block-size raw-data
packed delay-time color-index
block-terminator ;

TUPLE: image-descriptor
left top width height flags lzw-min-code-size ;

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
CONSTRUCTOR: trailer ( byte -- obj ) ;

CONSTANT: image-descriptor HEX: 2c
! Extensions
CONSTANT: extension-identifier HEX: 21
CONSTANT: plain-text-extension HEX: 01
CONSTANT: graphic-control-extension HEX: f9
CONSTANT: comment-extension HEX: fe
CONSTANT: application-extension HEX: ff
CONSTANT: trailer HEX: 3b

: <loading-gif> ( -- loading-gif )
    \ loading-gif new
        V{ } clone >>graphic-control-extensions
        V{ } clone >>application-extensions
        V{ } clone >>plain-text-extensions
        V{ } clone >>comment-extensions
        t >>loading? ;

GENERIC: stream-peek1 ( stream -- byte )

M: input-port stream-peek1
    dup check-disposed dup wait-to-read
    [ drop f ] [ buffer>> buffer-peek ] if ; inline

: peek1 ( -- byte ) input-stream get stream-peek1 ;

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
        1 read le> >>lzw-min-code-size ;

: read-graphic-control-extension ( -- graphic-control-extension )
    \ graphics-control-extension new
        1 read le> [ >>block-size ] [ read ] bi
        >>raw-data
        1 read le> >>block-terminator ;

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

: color-resolution ( image -- ? ) flags>> -4 shift 3 bits ; inline

: read-global-color-table ( loading-gif -- loading-gif )
    dup color-table? [
        dup color-table-size read >>global-color-table
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
        { plain-text-extension [
            read-plain-text-extension over plain-text-extensions>> push
        ] }

        { graphic-control-extension [
            read-graphic-control-extension
            over graphic-control-extensions>> push
        ] }
        { comment-extension [
            read-comment-extension over comment-extensions>> push
        ] }
        { application-extension [
            read-application-extension over application-extensions>> push
        ] }
        { f [ gif-unexpected-eof ] }
        [ unknown-extension ]
    } case ;

ERROR: unhandled-data byte ;

: read-data ( loading-gif -- loading-gif )
    read1 {
        { extension-identifier [ read-extension ] }
        { graphic-control-extension [
            read-graphic-control-extension
            over graphic-control-extensions>> push
        ] }
        { image-descriptor [ read-table-based-image ] }
        { trailer [ f >>loading? ] }
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

: loading-gif>image ( loading-gif -- image )
    ;

ERROR: loading-gif-error gif-image ;

: ensure-loaded ( gif-image -- gif-image )
    dup loading?>> [ loading-gif-error ] when ;

M: gif-image stream>image ( path gif-image -- image )
    drop load-gif ensure-loaded loading-gif>image ;
