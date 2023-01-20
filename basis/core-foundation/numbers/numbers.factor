! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.syntax combinators
core-foundation kernel math ;
QUALIFIED-WITH: alien.c-types c
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

FUNCTION: CFNumberRef CFNumberCreate ( CFAllocatorRef allocator, CFNumberType theType, void* valuePtr )

FUNCTION: CFNumberType CFNumberGetType ( CFNumberRef number )

FUNCTION: Boolean CFNumberGetValue ( CFNumberRef number, CFNumberType theType, void* valuePtr )

GENERIC: <CFNumber> ( number -- alien )

M: integer <CFNumber>
    [ f kCFNumberLongLongType ] dip longlong <ref> CFNumberCreate ;

M: float <CFNumber>
    [ f kCFNumberDoubleType ] dip double <ref> CFNumberCreate ;

M: t <CFNumber>
    drop f kCFNumberIntType 1 int <ref> CFNumberCreate ;

M: f <CFNumber>
    drop f kCFNumberIntType 0 int <ref> CFNumberCreate ;

ERROR: unsupported-number-type type ;

: (CFNumber>number) ( alien c-type -- number )
    [
        0 swap <ref> [ CFNumberGetValue drop ] keep
    ] keep deref ; inline

: CFNumber>number ( alien -- number )
    dup CFNumberGetType dup {
        { kCFNumberSInt8Type [ SInt8 (CFNumber>number) ] }
        { kCFNumberSInt16Type [ SInt16 (CFNumber>number) ] }
        { kCFNumberSInt32Type [ SInt32 (CFNumber>number) ] }
        { kCFNumberSInt64Type [ SInt64 (CFNumber>number) ] }
        { kCFNumberFloat64Type [ double (CFNumber>number) ] }
        { kCFNumberCharType [ char (CFNumber>number) ] }
        { kCFNumberShortType [ c:short (CFNumber>number) ] }
        { kCFNumberIntType [ int (CFNumber>number) ] }
        { kCFNumberLongType [ long (CFNumber>number) ] }
        { kCFNumberLongLongType [ longlong (CFNumber>number) ] }
        { kCFNumberDoubleType [ double (CFNumber>number) ] }
        [ unsupported-number-type ]
    } case ;
