! Copyright (C) 2010, 2011 Joe Groff, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.data cocoa cocoa.classes cocoa.messages
combinators core-foundation.data core-graphics
core-graphics.types fry locals images images.loader io kernel
math sequences ;
IN: images.cocoa

SINGLETON: ns-image
"png" ns-image register-image-class
"tif" ns-image register-image-class
"tiff" ns-image register-image-class
"gif" ns-image register-image-class
"jpg" ns-image register-image-class
"jpeg" ns-image register-image-class
"bmp" ns-image register-image-class
"ico" ns-image register-image-class

CONSTANT: NSImageRepLoadStatusUnknownType     -1
CONSTANT: NSImageRepLoadStatusReadingHeader   -2
CONSTANT: NSImageRepLoadStatusWillNeedAllData -3
CONSTANT: NSImageRepLoadStatusInvalidData     -4
CONSTANT: NSImageRepLoadStatusUnexpectedEOF   -5
CONSTANT: NSImageRepLoadStatusCompleted       -6

CONSTANT: NSColorRenderingIntentDefault                 0
CONSTANT: NSColorRenderingIntentAbsoluteColorimetric    1
CONSTANT: NSColorRenderingIntentRelativeColorimetric    2
CONSTANT: NSColorRenderingIntentPerceptual              3
CONSTANT: NSColorRenderingIntentSaturation              4

ERROR: ns-image-unknown-type ;
ERROR: ns-image-invalid-data ;
ERROR: ns-image-unexpected-eof ;
ERROR: ns-image-planar-images-not-supported ;

<PRIVATE

: check-return ( n -- )
    {
        { NSImageRepLoadStatusUnknownType   [ ns-image-unknown-type   ] }
        { NSImageRepLoadStatusInvalidData   [ ns-image-invalid-data   ] }
        { NSImageRepLoadStatusUnexpectedEOF [ ns-image-unexpected-eof ] }
        [ drop ]
    } case ;

PRIVATE>

: <CGImage> ( byte-array -- image-rep )
    [ NSBitmapImageRep ] dip
    <CFData> -> autorelease
    -> imageRepWithData:
    -> CGImage ;

:: CGImage>image ( image -- image )
    image CGImageGetWidth :> w
    image CGImageGetHeight :> h
    { w h } [
        0 0 w h <CGRect> image CGContextDrawImage
    ] make-bitmap-image
    t >>premultiplied-alpha? ;

M: ns-image stream>image
    drop stream-contents <CGImage> CGImage>image ;
