! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax math ;
IN: core-graphics

TYPEDEF: void* CGColorSpaceRef
TYPEDEF: void* CGContextRef

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

TYPEDEF: uint CGBitmapInfo
    
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