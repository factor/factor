! Copyright (C) 2010, 2011 Joe Groff, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.syntax assocs cocoa cocoa.classes
cocoa.enumeration cocoa.plists.private core-foundation
core-foundation.data core-foundation.dictionaries
core-foundation.strings core-foundation.urls core-graphics
core-graphics.private core-graphics.types destructors
images.loader io kernel math sequences system system-info ;
IN: images.loader.cocoa

SINGLETON: ns-image

FUNCTION: CFDictionaryRef UTTypeCopyDeclaration ( CFStringRef inUTI )

<<

: supported-ns-images ( -- seq )
    NSImage -> imageTypes [ CF>string ] NSFastEnumeration-map ;

: supported-ns-images-utt ( -- seq )
    NSImage -> imageTypes
    [ [ CF>string ] NSFastEnumeration-map ]
    [ [ UTTypeCopyDeclaration (plist-NSDictionary>) ] NSFastEnumeration-map ] bi zip ;

: supported-ns-image-extensions ( -- seq )
    supported-ns-images-utt
    [ "UTTypeTagSpecification" of dup [ "public.filename-extension" of ] when ] assoc-map values concat ;

>>

os macos? [
    os-version first 11 < [
        { "png" "tif" "tiff" "gif" "jpg" "jpeg" "bmp" "ico" "webp" }
    ] [
        supported-ns-image-extensions
    ] if [ ns-image register-image-class ] each
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
