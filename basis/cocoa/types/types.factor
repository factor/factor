! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax combinators kernel ;
IN: cocoa.types

TYPEDEF: long NSInteger
TYPEDEF: ulong NSUInteger
<< "ptrdiff_t" heap-size {
    { 4 [ "float" ] }
    { 8 [ "double" ] }
} case "CGFloat" typedef >>

C-STRUCT: NSPoint
    { "CGFloat" "x" }
    { "CGFloat" "y" } ;

TYPEDEF: NSPoint _NSPoint
TYPEDEF: NSPoint CGPoint

: <NSPoint> ( x y -- point )
    "NSPoint" <c-object>
    [ set-NSPoint-y ] keep
    [ set-NSPoint-x ] keep ;

C-STRUCT: NSSize
    { "CGFloat" "w" }
    { "CGFloat" "h" } ;

TYPEDEF: NSSize _NSSize
TYPEDEF: NSSize CGSize

: <NSSize> ( w h -- size )
    "NSSize" <c-object>
    [ set-NSSize-h ] keep
    [ set-NSSize-w ] keep ;

C-STRUCT: NSRect
    { "NSPoint" "origin" }
    { "NSSize"  "size"   } ;

TYPEDEF: NSRect _NSRect
TYPEDEF: NSRect CGRect

: NSRect-x ( NSRect -- x )
    NSRect-origin NSPoint-x ; inline
: NSRect-y ( NSRect -- y )
    NSRect-origin NSPoint-y ; inline
: NSRect-w ( NSRect -- w )
    NSRect-size NSSize-w ; inline
: NSRect-h ( NSRect -- h )
    NSRect-size NSSize-h ; inline

: set-NSRect-x ( x NSRect -- )
    NSRect-origin set-NSPoint-x ; inline
: set-NSRect-y ( y NSRect -- )
    NSRect-origin set-NSPoint-y ; inline
: set-NSRect-w ( w NSRect -- )
    NSRect-size set-NSSize-w ; inline
: set-NSRect-h ( h NSRect -- )
    NSRect-size set-NSSize-h ; inline

: <NSRect> ( x y w h -- rect )
    "NSRect" <c-object>
    [ set-NSRect-h ] keep
    [ set-NSRect-w ] keep
    [ set-NSRect-y ] keep
    [ set-NSRect-x ] keep ;

: NSRect-x-y ( alien -- origin-x origin-y )
    [ NSRect-x ] keep NSRect-y ;

C-STRUCT: NSRange
    { "NSUInteger" "location" }
    { "NSUInteger" "length" } ;

TYPEDEF: NSRange _NSRange

! The "lL" type encodings refer to 32-bit values even in 64-bit mode
TYPEDEF: int long32
TYPEDEF: uint ulong32
TYPEDEF: void* unknown_type

: <NSRange> ( length location -- size )
    "NSRange" <c-object>
    [ set-NSRange-length ] keep
    [ set-NSRange-location ] keep ;

C-STRUCT: CGAffineTransform
    { "CGFloat" "a" }
    { "CGFloat" "b" }
    { "CGFloat" "c" }
    { "CGFloat" "d" }
    { "CGFloat" "tx" }
    { "CGFloat" "ty" } ;

C-STRUCT: NSFastEnumerationState
    { "ulong" "state" }
    { "id*" "itemsPtr" }
    { "ulong*" "mutationsPtr" }
    { "ulong[5]" "extra" } ;
