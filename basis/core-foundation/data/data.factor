! Copyright (C) 2008 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.c-types sequences kernel math ;
IN: core-foundation.data

TYPEDEF: void* CFDataRef
TYPEDEF: void* CFNumberRef
TYPEDEF: void* CFSetRef

TYPEDEF: int CFNumberType
CONSTANT: kCFNumberSInt8Type 1
CONSTANT: kCFNumberSInt16Type 2
CONSTANT: kCFNumberSInt32Type 3
CONSTANT: kCFNumberSInt64Type 4
CONSTANT: kCFNumberFloat32Type 5
CONSTANT: kCFNumberFloat64Type 6
CONSTANT: kCFNumberCharType 7
CONSTANT: kCFNumberShortType 8
CONSTANT: kCFNumberIntType 9
CONSTANT: kCFNumberLongType 10
CONSTANT: kCFNumberLongLongType 11
CONSTANT: kCFNumberFloatType 12
CONSTANT: kCFNumberDoubleType 13
CONSTANT: kCFNumberCFIndexType 14
CONSTANT: kCFNumberNSIntegerType 15
CONSTANT: kCFNumberCGFloatType 16
CONSTANT: kCFNumberMaxType 16

TYPEDEF: int CFPropertyListMutabilityOptions
CONSTANT: kCFPropertyListImmutable 0
CONSTANT: kCFPropertyListMutableContainers 1
CONSTANT: kCFPropertyListMutableContainersAndLeaves 2

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
