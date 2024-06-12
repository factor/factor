! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.c-types alien.data alien.syntax
byte-vectors combinators.short-circuit core-foundation
core-foundation.arrays core-foundation.data destructors fry
io.encodings.string io.encodings.utf8 kernel math math.order
parser sequences words ;

IN: core-foundation.strings

TYPEDEF: void* CFStringRef

TYPEDEF: int CFStringEncoding
CONSTANT: kCFStringEncodingMacRoman 0x0
CONSTANT: kCFStringEncodingWindowsLatin1 0x0500
CONSTANT: kCFStringEncodingISOLatin1 0x0201
CONSTANT: kCFStringEncodingNextStepLatin 0x0B01
CONSTANT: kCFStringEncodingASCII 0x0600
CONSTANT: kCFStringEncodingUnicode 0x0100
CONSTANT: kCFStringEncodingUTF8 0x08000100
CONSTANT: kCFStringEncodingNonLossyASCII 0x0BFF
CONSTANT: kCFStringEncodingUTF16 0x0100
CONSTANT: kCFStringEncodingUTF16BE 0x10000100
CONSTANT: kCFStringEncodingUTF16LE 0x14000100
CONSTANT: kCFStringEncodingUTF32 0x0c000100
CONSTANT: kCFStringEncodingUTF32BE 0x18000100
CONSTANT: kCFStringEncodingUTF32LE 0x1c000100

FUNCTION: CFStringRef CFStringCreateWithBytes (
    CFAllocatorRef alloc,
    UInt8* bytes,
    CFIndex numBytes,
    CFStringEncoding encoding,
    Boolean isExternalRepresentation
)

FUNCTION: CFIndex CFStringGetLength ( CFStringRef theString )

FUNCTION: void CFStringGetCharacters ( void* theString, CFIndex start, CFIndex length, void* buffer )

FUNCTION: Boolean CFStringGetCString (
    CFStringRef theString,
    UInt8* buffer,
    CFIndex bufferSize,
    CFStringEncoding encoding
)

FUNCTION: CFIndex CFStringGetBytes (
   CFStringRef theString,
   CFRange range,
   CFStringEncoding encoding,
   UInt8 lossByte,
   Boolean isExternalRepresentation,
   UInt8* buffer,
   CFIndex maxBufLen,
   CFIndex* usedBufLen
)

FUNCTION: CFStringRef CFStringCreateWithCString (
    CFAllocatorRef alloc,
    UInt8* cStr,
    CFStringEncoding encoding
)

FUNCTION: CFStringRef CFCopyDescription ( CFTypeRef cf )
FUNCTION: CFStringRef CFCopyTypeIDDescription ( CFTypeID type_id )

: prepare-CFString ( string -- byte-array )
    [
        dup { [ 0x10ffff > ] [ 0xd800 0xdfff between? ] } 1||
        [ drop 0xfffd ] when
    ] map! utf8 encode ;

: <CFString> ( string -- alien )
    [ f ] dip
    prepare-CFString dup length
    kCFStringEncodingUTF8 f
    CFStringCreateWithBytes
    [ "CFStringCreateWithBytes failed" throw ] unless* ;

: CF>string ( alien -- string )
    dup CFStringGetLength
    [ 0 swap <CFRange> kCFStringEncodingUTF8 0 f ] keep
    4 * 1 + <byte-vector> [
        underlying>> dup length
        { CFIndex } [ CFStringGetBytes drop ] with-out-parameters
    ] 1guard >>length utf8 decode ;

: CF>string-array ( alien -- seq )
    CF>array [ CF>string ] map ;

: <CFStringArray> ( seq -- alien )
    [ [ <CFString> &CFRelease ] map <CFArray> ] with-destructors ;

: CF>description ( cf -- description )
    [ CFCopyDescription &CFRelease CF>string ] with-destructors ;
: CFType>description ( cf -- description )
    CFGetTypeID [ CFCopyTypeIDDescription &CFRelease CF>string ] with-destructors ;

SYNTAX: CFSTRING:
    scan-new-word scan-object
    [ drop ] [ '[ _ [ _ <CFString> ] initialize-alien ] ] 2bi
    ( -- alien ) define-declared ;
