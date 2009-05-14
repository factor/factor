! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.syntax accessors
destructors fry kernel math math.bitwise sequences libc colors
images images.memory core-graphics.types core-foundation.utilities ;
IN: core-graphics

! CGImageAlphaInfo
C-ENUM:
kCGImageAlphaNone
kCGImageAlphaPremultipliedLast
kCGImageAlphaPremultipliedFirst
kCGImageAlphaLast
kCGImageAlphaFirst
kCGImageAlphaNoneSkipLast
kCGImageAlphaNoneSkipFirst ;

: kCGBitmapAlphaInfoMask ( -- n ) HEX: 1f ; inline
: kCGBitmapFloatComponents ( -- n ) 1 8 shift ; inline

: kCGBitmapByteOrderMask ( -- n ) HEX: 7000 ; inline
: kCGBitmapByteOrderDefault ( -- n ) 0 12 shift ; inline
: kCGBitmapByteOrder16Little ( -- n ) 1 12 shift ; inline
: kCGBitmapByteOrder32Little ( -- n ) 2 12 shift ; inline
: kCGBitmapByteOrder16Big ( -- n ) 3 12 shift ; inline
: kCGBitmapByteOrder32Big ( -- n ) 4 12 shift ; inline

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
) ;

: <CGColor> ( color -- CGColor )
    >rgba-components CGColorCreateGenericRGB ;

M: color (>cf) <CGColor> ;

FUNCTION: CGColorSpaceRef CGColorSpaceCreateDeviceRGB ( ) ;

FUNCTION: CGContextRef CGBitmapContextCreate (
   void* data,
   size_t width,
   size_t height,
   size_t bitsPerComponent,
   size_t bytesPerRow,
   CGColorSpaceRef colorspace,
   CGBitmapInfo bitmapInfo
) ;

FUNCTION: void CGColorSpaceRelease ( CGColorSpaceRef ref ) ;

DESTRUCTOR: CGColorSpaceRelease

FUNCTION: void CGContextRelease ( CGContextRef ref ) ;

DESTRUCTOR: CGContextRelease

FUNCTION: void CGContextSetRGBStrokeColor (
   CGContextRef c,
   CGFloat red,
   CGFloat green,
   CGFloat blue,
   CGFloat alpha
) ;
  
FUNCTION: void CGContextSetRGBFillColor (
   CGContextRef c,
   CGFloat red,
   CGFloat green,
   CGFloat blue,
   CGFloat alpha
) ;

FUNCTION: void CGContextSetTextPosition (
   CGContextRef c,
   CGFloat x,
   CGFloat y
) ;

FUNCTION: void CGContextFillRect (
   CGContextRef c,
   CGRect rect
) ;

FUNCTION: void CGContextSetShouldSmoothFonts (
   CGContextRef c,
   bool shouldSmoothFonts
) ;

FUNCTION: void* CGBitmapContextGetData ( CGContextRef c ) ;

CONSTANT: kCGLRendererGenericFloatID HEX: 00020400

FUNCTION: CGLError CGLSetParameter ( CGLContextObj ctx, CGLContextParameter pname, GLint* params ) ;

FUNCTION: CGDirectDisplayID CGMainDisplayID ( ) ;

FUNCTION: CGError CGDisplayHideCursor ( CGDirectDisplayID display ) ;
FUNCTION: CGError CGDisplayShowCursor ( CGDirectDisplayID display ) ;

FUNCTION: CGError CGDisplayMoveCursorToPoint ( CGDirectDisplayID display, CGPoint point ) ;

FUNCTION: CGError CGAssociateMouseAndMouseCursorPosition ( boolean_t connected ) ;

FUNCTION: CGError CGWarpMouseCursorPosition ( CGPoint newCursorPosition ) ;

FUNCTION: uint GetCurrentButtonState ( ) ;

<PRIVATE

: bitmap-flags ( -- flags )
    { kCGImageAlphaPremultipliedFirst kCGBitmapByteOrder32Host } flags ;

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
    ARGB >>component-order ; inline
