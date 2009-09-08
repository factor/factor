! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.c-types alien.destructors accessors classes.struct kernel ;
IN: core-foundation

TYPEDEF: void* CFTypeRef

TYPEDEF: void* CFAllocatorRef
CONSTANT: kCFAllocatorDefault f

TYPEDEF: bool Boolean
TYPEDEF: long CFIndex
TYPEDEF: char UInt8
TYPEDEF: int SInt32
TYPEDEF: uint UInt32
TYPEDEF: ulong CFTypeID
TYPEDEF: UInt32 CFOptionFlags
TYPEDEF: void* CFUUIDRef

ALIAS: <CFIndex> <long>
ALIAS: *CFIndex *long

STRUCT: CFRange
    { location CFIndex }
    { length CFIndex } ;

: <CFRange> ( location length -- range )
    CFRange <struct-boa> ;

FUNCTION: CFTypeRef CFRetain ( CFTypeRef cf ) ;

FUNCTION: void CFRelease ( CFTypeRef cf ) ;

DESTRUCTOR: CFRelease
