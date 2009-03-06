! Copyright (C) 2006, 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax combinators kernel layouts
core-graphics.types ;
IN: cocoa.types

TYPEDEF: long NSInteger
TYPEDEF: ulong NSUInteger

TYPEDEF: CGPoint NSPoint
TYPEDEF: NSPoint _NSPoint

TYPEDEF: CGSize NSSize
TYPEDEF: NSSize _NSSize

TYPEDEF: CGRect NSRect
TYPEDEF: NSRect _NSRect

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

C-STRUCT: NSFastEnumerationState
    { "ulong" "state" }
    { "id*" "itemsPtr" }
    { "ulong*" "mutationsPtr" }
    { "ulong[5]" "extra" } ;
