! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax kernel layouts ;
IN: core-graphics.types

<< cell 4 = "float" "double" ? "CGFloat" typedef >>

: <CGFloat> ( x -- alien )
    cell 4 = [ <float> ] [ <double> ] if ; inline

C-STRUCT: CGPoint
    { "CGFloat" "x" }
    { "CGFloat" "y" } ;

: <CGPoint> ( x y -- point )
    "CGPoint" <c-object>
    [ set-CGPoint-y ] keep
    [ set-CGPoint-x ] keep ;

C-STRUCT: CGSize
    { "CGFloat" "w" }
    { "CGFloat" "h" } ;

: <CGSize> ( w h -- size )
    "CGSize" <c-object>
    [ set-CGSize-h ] keep
    [ set-CGSize-w ] keep ;

C-STRUCT: CGRect
    { "CGPoint" "origin" }
    { "CGSize"  "size"   } ;

: CGRect-x ( CGRect -- x )
    CGRect-origin CGPoint-x ; inline
: CGRect-y ( CGRect -- y )
    CGRect-origin CGPoint-y ; inline
: CGRect-w ( CGRect -- w )
    CGRect-size CGSize-w ; inline
: CGRect-h ( CGRect -- h )
    CGRect-size CGSize-h ; inline

: set-CGRect-x ( x CGRect -- )
    CGRect-origin set-CGPoint-x ; inline
: set-CGRect-y ( y CGRect -- )
    CGRect-origin set-CGPoint-y ; inline
: set-CGRect-w ( w CGRect -- )
    CGRect-size set-CGSize-w ; inline
: set-CGRect-h ( h CGRect -- )
    CGRect-size set-CGSize-h ; inline

: <CGRect> ( x y w h -- rect )
    "CGRect" <c-object>
    [ set-CGRect-h ] keep
    [ set-CGRect-w ] keep
    [ set-CGRect-y ] keep
    [ set-CGRect-x ] keep ;

: CGRect-x-y ( alien -- origin-x origin-y )
    [ CGRect-x ] keep CGRect-y ;

C-STRUCT: CGAffineTransform
    { "CGFloat" "a" }
    { "CGFloat" "b" }
    { "CGFloat" "c" }
    { "CGFloat" "d" }
    { "CGFloat" "tx" }
    { "CGFloat" "ty" } ;

TYPEDEF: void* CGColorSpaceRef
TYPEDEF: void* CGContextRef
TYPEDEF: uint CGBitmapInfo

TYPEDEF: int CGLError
TYPEDEF: void* CGLContextObj
TYPEDEF: int CGLContextParameter