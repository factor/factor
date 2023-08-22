! Copyright (C) 2008 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax core-foundation kernel
sequences ;
IN: core-foundation.data

TYPEDEF: void* CFDataRef
TYPEDEF: void* CFSetRef

TYPEDEF: int CFPropertyListMutabilityOptions
CONSTANT: kCFPropertyListImmutable 0
CONSTANT: kCFPropertyListMutableContainers 1
CONSTANT: kCFPropertyListMutableContainersAndLeaves 2

FUNCTION: CFDataRef CFDataCreate ( CFAllocatorRef allocator, UInt8* bytes, CFIndex length )

FUNCTION: CFTypeID CFGetTypeID ( CFTypeRef cf )

: <CFData> ( byte-array -- alien )
    [ f ] dip dup length CFDataCreate ;
