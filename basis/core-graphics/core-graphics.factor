! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.destructors alien.syntax
destructors fry kernel math sequences libc
core-graphics.types ;
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

FUNCTION: CGLError CGLSetParameter ( CGLContextObj ctx, CGLContextParameter pname, GLint* params ) ;

FUNCTION: void* CGBitmapContextGetData ( CGContextRef c ) ;

<PRIVATE

: <CGBitmapContext> ( dim -- context )
    [ product "uint" malloc-array &free ] [ first2 8 ] [ first 4 * ] tri
    CGColorSpaceCreateDeviceRGB &CGColorSpaceRelease
    kCGImageAlphaPremultipliedLast CGBitmapContextCreate
    [ "CGBitmapContextCreate failed" throw ] unless* ;

: bitmap-data ( bitmap dim -- data )
    [ CGBitmapContextGetData ]
    [ product "uint" heap-size * ] bi*
    memory>byte-array ;

PRIVATE>

: with-bitmap-context ( dim quot -- data )
    [
        [ [ <CGBitmapContext> &CGContextRelease ] keep ] dip
        [ nip call ] [ drop bitmap-data ] 3bi
    ] with-destructors ; inline
