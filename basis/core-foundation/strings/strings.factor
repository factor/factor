! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.strings kernel sequences byte-arrays
io.encodings.utf8 math core-foundation core-foundation.arrays ;
IN: core-foundation.strings

TYPEDEF: void* CFStringRef

TYPEDEF: int CFStringEncoding
: kCFStringEncodingMacRoman HEX: 0 ;
: kCFStringEncodingWindowsLatin1 HEX: 0500 ;
: kCFStringEncodingISOLatin1 HEX: 0201 ;
: kCFStringEncodingNextStepLatin HEX: 0B01 ;
: kCFStringEncodingASCII HEX: 0600 ;
: kCFStringEncodingUnicode HEX: 0100 ;
: kCFStringEncodingUTF8 HEX: 08000100 ;
: kCFStringEncodingNonLossyASCII HEX: 0BFF ;
: kCFStringEncodingUTF16 HEX: 0100 ;
: kCFStringEncodingUTF16BE HEX: 10000100 ;
: kCFStringEncodingUTF16LE HEX: 14000100 ;
: kCFStringEncodingUTF32 HEX: 0c000100 ;
: kCFStringEncodingUTF32BE HEX: 18000100 ;
: kCFStringEncodingUTF32LE HEX: 1c000100 ;

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

FUNCTION: CFStringRef CFStringCreateWithCString (
   CFAllocatorRef alloc,
   char* cStr,
   CFStringEncoding encoding
) ;

: <CFString> ( string -- alien )
    f swap utf8 string>alien kCFStringEncodingUTF8 CFStringCreateWithCString
    [ "CFStringCreateWithCString failed" throw ] unless* ;

: CF>string ( alien -- string )
    dup CFStringGetLength 4 * 1 + <byte-array> [
        dup length
        kCFStringEncodingUTF8
        CFStringGetCString
        [ "CFStringGetCString failed" throw ] unless
    ] keep utf8 alien>string ;

: CF>string-array ( alien -- seq )
    CF>array [ CF>string ] map ;

: <CFStringArray> ( seq -- alien )
    [ <CFString> ] map [ <CFArray> ] [ [ CFRelease ] each ] bi ;
