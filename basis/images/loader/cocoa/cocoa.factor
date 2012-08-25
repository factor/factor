! Copyright (C) 2010, 2011 Joe Groff, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.data cocoa cocoa.classes cocoa.messages
combinators core-foundation.data core-graphics
core-graphics.types fry locals images images.loader io kernel
math sequences ;
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

M: ns-image stream>image*
    drop stream-contents <CGImage> CGImage>image ;
