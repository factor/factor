! Copyright (C) 2010, 2011 Joe Groff, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors cocoa cocoa.classes core-foundation
core-foundation.data core-foundation.urls core-graphics
core-graphics.private core-graphics.types destructors
images.loader io kernel locals math sequences ;
FROM: system => os macosx? ;
IN: images.loader.cocoa

SINGLETON: ns-image

os macosx? [
    "png" ns-image register-image-class
    "tif" ns-image register-image-class
    "tiff" ns-image register-image-class
    "gif" ns-image register-image-class
    "jpg" ns-image register-image-class
    "jpeg" ns-image register-image-class
    "bmp" ns-image register-image-class
    "ico" ns-image register-image-class
] when

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
    ] make-bitmap-image ;

: image>CGImage ( image -- image )
    [ bitmap>> ] [ dim>> first2 ] bi 8 pick 4 *
    bitmap-color-space bitmap-flags
    CGBitmapContextCreate -> autorelease
    CGBitmapContextCreateImage ;

M: ns-image stream>image*
    drop stream-contents <CGImage> CGImage>image ;

:: save-ns-image ( image path type -- )
    [
        path f <CFFileSystemURL> &CFRelease
        type 1 f CGImageDestinationCreateWithURL &CFRelease
        [
            image image>CGImage &CFRelease
            f CGImageDestinationAddImage
        ] [
            CGImageDestinationFinalize drop
        ] bi
    ] with-destructors ;
