! Copyright (C) 2006, 2009 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct cocoa.runtime
core-graphics.types kernel literals layouts ;
IN: cocoa.types

CONSTANT: NSNotFound $[ 32-bit? 0x7fffffff 0x7fffffffffffffff ? ]

TYPEDEF: long NSInteger
TYPEDEF: ulong NSUInteger

TYPEDEF: CGPoint NSPoint
TYPEDEF: NSPoint _NSPoint

TYPEDEF: CGSize NSSize
TYPEDEF: NSSize _NSSize

TYPEDEF: CGRect NSRect
TYPEDEF: NSRect _NSRect

STRUCT: NSRange
    { location NSUInteger }
    { length NSUInteger } ;

C: <NSRange> NSRange

TYPEDEF: NSRange _NSRange

! The "lL" type encodings refer to 32-bit values even in 64-bit mode
TYPEDEF: int long32
TYPEDEF: uint ulong32
TYPEDEF: void* unknown_type

STRUCT: NSFastEnumerationState
    { state ulong }
    { itemsPtr id* }
    { mutationsPtr ulong* }
    { extra ulong[5] } ;
