! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax destructors accessors kernel calendar ;
IN: core-foundation

TYPEDEF: void* CFTypeRef

TYPEDEF: void* CFAllocatorRef
: kCFAllocatorDefault f ; inline

TYPEDEF: bool Boolean
TYPEDEF: long CFIndex
TYPEDEF: int SInt32
TYPEDEF: uint UInt32
TYPEDEF: ulong CFTypeID
TYPEDEF: UInt32 CFOptionFlags
TYPEDEF: double CFTimeInterval
TYPEDEF: double CFAbsoluteTime

FUNCTION: CFTypeRef CFRetain ( CFTypeRef cf ) ;

FUNCTION: void CFRelease ( CFTypeRef cf ) ;

TUPLE: CFRelease-destructor alien disposed ;

M: CFRelease-destructor dispose* alien>> CFRelease ;

: &CFRelease ( alien -- alien )
    dup f CFRelease-destructor boa &dispose drop ; inline

: |CFRelease ( alien -- alien )
    dup f CFRelease-destructor boa |dispose drop ; inline

: >CFTimeInterval ( duration -- interval )
    duration>seconds ; inline

: >CFAbsoluteTime ( timestamp -- time )
    T{ timestamp { year 2001 } { month 1 } { day 1 } } time-
    duration>seconds ; inline
