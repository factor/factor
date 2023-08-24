! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.c-types alien.data
alien.destructors alien.syntax colors
core-foundation.dictionaries core-foundation.strings
core-foundation.urls core-foundation.utilities
core-graphics.types destructors images images.memory kernel
libc math opengl.gl sequences ;

IN: core-graphics

TYPEDEF: int CGImageAlphaInfo
CONSTANT: kCGImageAlphaNone 0
CONSTANT: kCGImageAlphaPremultipliedLast 1
CONSTANT: kCGImageAlphaPremultipliedFirst 2
CONSTANT: kCGImageAlphaLast 3
CONSTANT: kCGImageAlphaFirst 4
CONSTANT: kCGImageAlphaNoneSkipLast 5
CONSTANT: kCGImageAlphaNoneSkipFirst 6

CONSTANT: kCGBitmapAlphaInfoMask 0x1f
CONSTANT: kCGBitmapFloatComponents 256

CONSTANT: kCGBitmapByteOrderMask 0x7000
CONSTANT: kCGBitmapByteOrderDefault 0
CONSTANT: kCGBitmapByteOrder16Little 4096
CONSTANT: kCGBitmapByteOrder32Little 8192
CONSTANT: kCGBitmapByteOrder16Big 12288
CONSTANT: kCGBitmapByteOrder32Big 16384

: kCGBitmapByteOrder16Host ( -- n )
    little-endian?
    kCGBitmapByteOrder16Little
    kCGBitmapByteOrder16Big ? ; foldable

: kCGBitmapByteOrder32Host ( -- n )
    little-endian?
    kCGBitmapByteOrder32Little
    kCGBitmapByteOrder32Big ? ; foldable

FUNCTION: CGColorRef CGColorCreateGenericRGB (
   CGFloat red,
   CGFloat green,
   CGFloat blue,
   CGFloat alpha
)

: <CGColor> ( color -- CGColor )
    >rgba-components CGColorCreateGenericRGB ;

M: color (>cf) <CGColor> ;

FUNCTION: CGColorSpaceRef CGColorSpaceCreateDeviceRGB ( )

FUNCTION: CGContextRef CGBitmapContextCreate (
   void* data,
   size_t width,
   size_t height,
   size_t bitsPerComponent,
   size_t bytesPerRow,
   CGColorSpaceRef colorspace,
   CGBitmapInfo bitmapInfo
)

FUNCTION: CGImageRef CGBitmapContextCreateImage (
   CGContextRef c
)

FUNCTION: void CGColorSpaceRelease ( CGColorSpaceRef ref )

DESTRUCTOR: CGColorSpaceRelease

FUNCTION: void CGContextRelease ( CGContextRef ref )

DESTRUCTOR: CGContextRelease

FUNCTION: void CGContextSetRGBStrokeColor (
   CGContextRef c,
   CGFloat red,
   CGFloat green,
   CGFloat blue,
   CGFloat alpha
)

FUNCTION: void CGContextSetRGBFillColor (
   CGContextRef c,
   CGFloat red,
   CGFloat green,
   CGFloat blue,
   CGFloat alpha
)

FUNCTION: void CGContextSetTextPosition (
   CGContextRef c,
   CGFloat x,
   CGFloat y
)

FUNCTION: void CGContextFillRect (
   CGContextRef c,
   CGRect rect
)

FUNCTION: void CGContextSetShouldSmoothFonts (
   CGContextRef c,
   bool shouldSmoothFonts
)

FUNCTION: void CGContextDrawImage (
   CGContextRef c,
   CGRect rect,
   CGImageRef image
)

FUNCTION: size_t CGImageGetWidth (
   CGImageRef image
)

FUNCTION: size_t CGImageGetHeight (
   CGImageRef image
)

FUNCTION: CGImageDestinationRef CGImageDestinationCreateWithURL (
   CFURLRef url,
   CFStringRef type,
   size_t count,
   CFDictionaryRef options
)

FUNCTION: void CGImageDestinationAddImage (
   CGImageDestinationRef idst,
   CGImageRef image,
   CFDictionaryRef properties
)

FUNCTION: bool CGImageDestinationFinalize (
   CGImageDestinationRef idst
)

FUNCTION: void* CGBitmapContextGetData ( CGContextRef c )

CONSTANT: kCGLRendererGenericFloatID 0x00020400

FUNCTION: CGLError CGLSetParameter ( CGLContextObj ctx, CGLContextParameter pname, GLint* params )

FUNCTION: CGDirectDisplayID CGMainDisplayID ( )

FUNCTION: CGError CGDisplayHideCursor ( CGDirectDisplayID display )
FUNCTION: CGError CGDisplayShowCursor ( CGDirectDisplayID display )

FUNCTION: CGError CGDisplayMoveCursorToPoint ( CGDirectDisplayID display, CGPoint point )

FUNCTION: CGError CGAssociateMouseAndMouseCursorPosition ( boolean_t connected )

FUNCTION: CGError CGWarpMouseCursorPosition ( CGPoint newCursorPosition )

FUNCTION: uint GetCurrentButtonState ( )

<PRIVATE

: bitmap-flags ( -- n )
    kCGImageAlphaPremultipliedFirst kCGBitmapByteOrder32Host bitor ;

: bitmap-color-space ( -- color-space )
    CGColorSpaceCreateDeviceRGB &CGColorSpaceRelease ;

: <CGBitmapContext> ( data dim -- context )
    [ first2 8 ] [ first 4 * ] bi
    bitmap-color-space bitmap-flags CGBitmapContextCreate
    [ "CGBitmapContextCreate failed" throw ] unless* ;

PRIVATE>

: dummy-context ( -- context )
    \ dummy-context [
        [ 4 malloc { 1 1 } <CGBitmapContext> ] with-destructors
    ] initialize-alien ;

: make-bitmap-image ( dim quot -- image )
    '[ <CGBitmapContext> &CGContextRelease @ ] make-memory-bitmap
    ARGB >>component-order
    ubyte-components >>component-type
    t >>premultiplied-alpha? ; inline
