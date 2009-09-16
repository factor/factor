! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax kernel math core-foundation ;
FROM: math => float ;
IN: core-foundation.numbers

TYPEDEF: void* CFNumberRef

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

FUNCTION: CFNumberRef CFNumberCreate ( CFAllocatorRef allocator, CFNumberType theType, void* valuePtr ) ;

GENERIC: <CFNumber> ( number -- alien )

M: integer <CFNumber>
    [ f kCFNumberLongLongType ] dip <longlong> CFNumberCreate ;

M: float <CFNumber>
    [ f kCFNumberDoubleType ] dip <double> CFNumberCreate ;

M: t <CFNumber>
    drop f kCFNumberIntType 1 <int> CFNumberCreate ;

M: f <CFNumber>
    drop f kCFNumberIntType 0 <int> CFNumberCreate ;

