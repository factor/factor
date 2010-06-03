! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax classes.struct kernel layouts
math math.rectangles arrays literals ;
FROM: alien.c-types => float ;
IN: core-graphics.types

SYMBOL: CGFloat
<< cell 4 = float double ? \ CGFloat typedef >>

STRUCT: CGPoint
    { x CGFloat }
    { y CGFloat } ;

: <CGPoint> ( x y -- point )
    CGPoint <struct-boa> ;

STRUCT: CGSize
    { w CGFloat }
    { h CGFloat } ;

: <CGSize> ( w h -- size )
    CGSize <struct-boa> ;

STRUCT: CGRect
    { origin CGPoint }
    { size CGSize } ;

: CGPoint>loc ( CGPoint -- loc )
    [ x>> ] [ y>> ] bi 2array ;

: CGSize>dim ( CGSize -- dim )
    [ w>> ] [ h>> ] bi 2array ;

: CGRect>rect ( CGRect -- rect )
    [ origin>> CGPoint>loc ]
    [ size>> CGSize>dim ]
    bi <rect> ; inline

: CGRect-x ( CGRect -- x )
    origin>> x>> ; inline
: CGRect-y ( CGRect -- y )
    origin>> y>> ; inline
: CGRect-w ( CGRect -- w )
    size>> w>> ; inline
: CGRect-h ( CGRect -- h )
    size>> h>> ; inline

: set-CGRect-x ( x CGRect -- )
    origin>> x<< ; inline
: set-CGRect-y ( y CGRect -- )
    origin>> y<< ; inline
: set-CGRect-w ( w CGRect -- )
    size>> w<< ; inline
: set-CGRect-h ( h CGRect -- )
    size>> h<< ; inline

: <CGRect> ( x y w h -- rect )
    [ CGPoint <struct-boa> ] [ CGSize <struct-boa> ] 2bi*
    CGRect <struct-boa> ;

: CGRect-x-y ( alien -- origin-x origin-y )
    [ CGRect-x ] [ CGRect-y ] bi ;

: CGRect-top-left ( alien -- x y )
    [ CGRect-x ] [ [ CGRect-y ] [ CGRect-h ] bi + ] bi ;

STRUCT: CGAffineTransform
    { a CGFloat }
    { b CGFloat }
    { c CGFloat }
    { d CGFloat }
    { tx CGFloat }
    { ty CGFloat } ;

TYPEDEF: void* CGColorRef
TYPEDEF: void* CGColorSpaceRef
TYPEDEF: void* CGContextRef
TYPEDEF: uint CGBitmapInfo

TYPEDEF: int CGLError
TYPEDEF: int CGError
TYPEDEF: uint CGDirectDisplayID
TYPEDEF: int boolean_t
TYPEDEF: void* CGLContextObj
TYPEDEF: int CGLContextParameter
