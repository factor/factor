! Copyright (C) 2008 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.c-types sequences kernel math ;
IN: core-foundation.data

TYPEDEF: void* CFDataRef
TYPEDEF: void* CFDictionaryRef
TYPEDEF: void* CFMutableDictionaryRef
TYPEDEF: void* CFNumberRef
TYPEDEF: void* CFSetRef

TYPEDEF: int CFNumberType
: kCFNumberSInt8Type 1 ; inline
: kCFNumberSInt16Type 2 ; inline
: kCFNumberSInt32Type 3 ; inline
: kCFNumberSInt64Type 4 ; inline
: kCFNumberFloat32Type 5 ; inline
: kCFNumberFloat64Type 6 ; inline
: kCFNumberCharType 7 ; inline
: kCFNumberShortType 8 ; inline
: kCFNumberIntType 9 ; inline
: kCFNumberLongType 10 ; inline
: kCFNumberLongLongType 11 ; inline
: kCFNumberFloatType 12 ; inline
: kCFNumberDoubleType 13 ; inline
: kCFNumberCFIndexType 14 ; inline
: kCFNumberNSIntegerType 15 ; inline
: kCFNumberCGFloatType 16 ; inline
: kCFNumberMaxType 16 ; inline

TYPEDEF: int CFPropertyListMutabilityOptions
: kCFPropertyListImmutable                  0 ; inline
: kCFPropertyListMutableContainers          1 ; inline
: kCFPropertyListMutableContainersAndLeaves 2 ; inline

FUNCTION: CFNumberRef CFNumberCreate ( CFAllocatorRef allocator, CFNumberType theType, void* valuePtr ) ;

FUNCTION: CFDataRef CFDataCreate ( CFAllocatorRef allocator, uchar* bytes, CFIndex length ) ;

FUNCTION: CFTypeID CFGetTypeID ( CFTypeRef cf ) ;

GENERIC: <CFNumber> ( number -- alien )

M: integer <CFNumber>
    [ f kCFNumberLongLongType ] dip <longlong> CFNumberCreate ;

M: float <CFNumber>
    [ f kCFNumberDoubleType ] dip <double> CFNumberCreate ;

M: t <CFNumber>
    drop f kCFNumberIntType 1 <int> CFNumberCreate ;

M: f <CFNumber>
    drop f kCFNumberIntType 0 <int> CFNumberCreate ;

: <CFData> ( byte-array -- alien )
    [ f ] dip dup length CFDataCreate ;
