! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.c-types alien.destructors accessors kernel ;
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

C-STRUCT: CFRange
{ "CFIndex" "location" }
{ "CFIndex" "length" } ;

: <CFRange> ( location length -- range )
    "CFRange" <c-object>
    [ set-CFRange-length ] keep
    [ set-CFRange-location ] keep ;

FUNCTION: CFTypeRef CFRetain ( CFTypeRef cf ) ;

FUNCTION: void CFRelease ( CFTypeRef cf ) ;

DESTRUCTOR: CFRelease