! Copyright (C) 2006, 2008 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.destructors alien.syntax
classes.struct ;
IN: core-foundation

TYPEDEF: void* CFTypeRef

TYPEDEF: void* CFAllocatorRef
CONSTANT: kCFAllocatorDefault f

TYPEDEF: bool Boolean
TYPEDEF: long CFIndex
TYPEDEF: uchar UInt8
TYPEDEF: ushort UInt16
TYPEDEF: uint UInt32
TYPEDEF: ulonglong UInt64
TYPEDEF: char SInt8
TYPEDEF: short SInt16
TYPEDEF: int SInt32
TYPEDEF: longlong SInt64
TYPEDEF: ulong CFTypeID
TYPEDEF: UInt32 CFOptionFlags
TYPEDEF: void* CFUUIDRef
TYPEDEF: SInt32 OSStatus
TYPEDEF: uchar[4] FourCharCode
TYPEDEF: FourCharCode OSType

STRUCT: FSRef
    { opaque uchar[80] } ;

STRUCT: CFRange
    { location CFIndex }
    { length CFIndex } ;

C: <CFRange> CFRange

FUNCTION: CFTypeRef CFRetain ( CFTypeRef cf )

FUNCTION: void CFRelease ( CFTypeRef cf )

DESTRUCTOR: CFRelease
