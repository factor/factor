! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.strings io.encodings.string kernel
sequences byte-arrays io.encodings.utf8 math core-foundation
core-foundation.arrays destructors ;
IN: core-foundation.strings

TYPEDEF: void* CFStringRef

TYPEDEF: int CFStringEncoding
CONSTANT: kCFStringEncodingMacRoman HEX: 0
CONSTANT: kCFStringEncodingWindowsLatin1 HEX: 0500
CONSTANT: kCFStringEncodingISOLatin1 HEX: 0201
CONSTANT: kCFStringEncodingNextStepLatin HEX: 0B01
CONSTANT: kCFStringEncodingASCII HEX: 0600
CONSTANT: kCFStringEncodingUnicode HEX: 0100
CONSTANT: kCFStringEncodingUTF8 HEX: 08000100
CONSTANT: kCFStringEncodingNonLossyASCII HEX: 0BFF
CONSTANT: kCFStringEncodingUTF16 HEX: 0100
CONSTANT: kCFStringEncodingUTF16BE HEX: 10000100
CONSTANT: kCFStringEncodingUTF16LE HEX: 14000100
CONSTANT: kCFStringEncodingUTF32 HEX: 0c000100
CONSTANT: kCFStringEncodingUTF32BE HEX: 18000100
CONSTANT: kCFStringEncodingUTF32LE HEX: 1c000100

FUNCTION: CFStringRef CFStringCreateWithBytes (
    CFAllocatorRef alloc,
    UInt8* bytes,
    CFIndex numBytes,
    CFStringEncoding encoding,
    Boolean isExternalRepresentation
) ;

FUNCTION: CFIndex CFStringGetLength ( CFStringRef theString ) ;

FUNCTION: void CFStringGetCharacters ( void* theString, CFIndex start, CFIndex length, void* buffer ) ;

FUNCTION: Boolean CFStringGetCString (
    CFStringRef theString,
    char* buffer,
    CFIndex bufferSize,
    CFStringEncoding encoding
) ;

FUNCTION: CFIndex CFStringGetBytes (
   CFStringRef theString,
   CFRange range,
   CFStringEncoding encoding,
   UInt8 lossByte,
   Boolean isExternalRepresentation,
   UInt8* buffer,
   CFIndex maxBufLen,
   CFIndex* usedBufLen
) ;

FUNCTION: CFStringRef CFStringCreateWithCString (
    CFAllocatorRef alloc,
    char* cStr,
    CFStringEncoding encoding
) ;

: prepare-CFString ( string -- byte-array )
    [
        dup HEX: 10ffff >
        [ drop HEX: fffd ] when
    ] map utf8 encode ;

: <CFString> ( string -- alien )
    [ f ] dip
    prepare-CFString dup length
    kCFStringEncodingUTF8 f
    CFStringCreateWithBytes
    [ "CFStringCreateWithBytes failed" throw ] unless* ;

: CF>string ( alien -- string )
    dup CFStringGetLength
    [ 0 swap <CFRange> kCFStringEncodingUTF8 0 f ] keep
    4 * 1 + <byte-array> [ dup length 0 <CFIndex> [ CFStringGetBytes drop ] keep ] keep
    swap *CFIndex head-slice utf8 decode ;

: CF>string-array ( alien -- seq )
    CF>array [ CF>string ] map ;

: <CFStringArray> ( seq -- alien )
    [ [ <CFString> &CFRelease ] map <CFArray> ] with-destructors ;
