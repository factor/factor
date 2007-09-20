! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax kernel ;
IN: cocoa.types

C-STRUCT: NSRect
    { "float" "x" }
    { "float" "y" }
    { "float" "w" }
    { "float" "h" } ;

TYPEDEF: NSRect _NSRect
TYPEDEF: NSRect CGRect

: <NSRect> ( x y w h -- rect )
    "NSRect" <c-object>
    [ set-NSRect-h ] keep
    [ set-NSRect-w ] keep
    [ set-NSRect-y ] keep
    [ set-NSRect-x ] keep ;

: NSRect-x-y ( alien -- origin-x origin-y )
    [ NSRect-x ] keep NSRect-y ;

C-STRUCT: NSPoint
    { "float" "x" }
    { "float" "y" } ;

TYPEDEF: NSPoint _NSPoint
TYPEDEF: NSPoint CGPoint

: <NSPoint> ( x y -- point )
    "NSPoint" <c-object>
    [ set-NSPoint-y ] keep
    [ set-NSPoint-x ] keep ;

C-STRUCT: NSSize
    { "float" "w" }
    { "float" "h" } ;

TYPEDEF: NSSize _NSSize
TYPEDEF: NSPoint CGPoint

: <NSSize> ( w h -- size )
    "NSSize" <c-object>
    [ set-NSSize-h ] keep
    [ set-NSSize-w ] keep ;

C-STRUCT: NSRange
    { "uint" "location" }
    { "uint" "length" } ;

TYPEDEF: NSRange _NSRange

: <NSRange> ( length location -- size )
    "NSRange" <c-object>
    [ set-NSRange-length ] keep
    [ set-NSRange-location ] keep ;

C-STRUCT: CGAffineTransform
    { "float" "a" }
    { "float" "b" }
    { "float" "c" }
    { "float" "d" }
    { "float" "tx" }
    { "float" "ty" } ;
