! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings alien.syntax kernel
math sequences io.encodings.utf8 destructors accessors
combinators byte-arrays ;
IN: core-foundation

TYPEDEF: void* CFAllocatorRef
TYPEDEF: void* CFArrayRef
TYPEDEF: void* CFDataRef
TYPEDEF: void* CFDictionaryRef
TYPEDEF: void* CFMutableDictionaryRef
TYPEDEF: void* CFNumberRef
TYPEDEF: void* CFBundleRef
TYPEDEF: void* CFSetRef
TYPEDEF: void* CFStringRef
TYPEDEF: void* CFURLRef
TYPEDEF: void* CFUUIDRef
TYPEDEF: void* CFTypeRef
TYPEDEF: void* CFFileDescriptorRef
TYPEDEF: bool Boolean
TYPEDEF: long CFIndex
TYPEDEF: int SInt32
TYPEDEF: uint UInt32
TYPEDEF: ulong CFTypeID
TYPEDEF: UInt32 CFOptionFlags
TYPEDEF: double CFTimeInterval
TYPEDEF: double CFAbsoluteTime
TYPEDEF: int CFFileDescriptorNativeDescriptor
TYPEDEF: void* CFFileDescriptorCallBack

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

FUNCTION: CFArrayRef CFArrayCreateMutable ( CFAllocatorRef allocator, CFIndex capacity, void* callbacks ) ;

FUNCTION: void* CFArrayGetValueAtIndex ( CFArrayRef array, CFIndex idx ) ;

FUNCTION: void CFArraySetValueAtIndex ( CFArrayRef array, CFIndex index, void* value ) ;

FUNCTION: CFIndex CFArrayGetCount ( CFArrayRef array ) ;

: kCFURLPOSIXPathStyle 0 ; inline
: kCFAllocatorDefault f ; inline

FUNCTION: CFURLRef CFURLCreateWithFileSystemPath ( CFAllocatorRef allocator, CFStringRef filePath, int pathStyle, Boolean isDirectory ) ;

FUNCTION: CFURLRef CFURLCreateWithString ( CFAllocatorRef allocator, CFStringRef string, CFURLRef base ) ;

FUNCTION: CFURLRef CFURLCopyFileSystemPath ( CFURLRef url, int pathStyle ) ;

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

FUNCTION: CFStringRef CFStringCreateFromExternalRepresentation (
   CFAllocatorRef alloc,
   CFDataRef data,
   CFStringEncoding encoding
) ;

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

FUNCTION: CFNumberRef CFNumberCreate ( CFAllocatorRef allocator, CFNumberType theType, void* valuePtr ) ;

FUNCTION: CFDataRef CFDataCreate ( CFAllocatorRef allocator, uchar* bytes, CFIndex length ) ;

FUNCTION: CFBundleRef CFBundleCreate ( CFAllocatorRef allocator, CFURLRef bundleURL ) ;

FUNCTION: Boolean CFBundleLoadExecutable ( CFBundleRef bundle ) ;

FUNCTION: CFTypeRef CFRetain ( CFTypeRef cf ) ;
FUNCTION: void CFRelease ( CFTypeRef cf ) ;

FUNCTION: CFTypeID CFGetTypeID ( CFTypeRef cf ) ;

: CF>array ( alien -- array )
    dup CFArrayGetCount [ CFArrayGetValueAtIndex ] with map ;

: <CFArray> ( seq -- alien )
    [ f swap length f CFArrayCreateMutable ] keep
    [ length ] keep
    [ [ dupd ] dip CFArraySetValueAtIndex ] 2each ;

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

: <CFFileSystemURL> ( string dir? -- url )
    [ <CFString> f over kCFURLPOSIXPathStyle ] dip
    CFURLCreateWithFileSystemPath swap CFRelease ;

: <CFURL> ( string -- url )
    <CFString>
    [ f swap f CFURLCreateWithString ] keep
    CFRelease ;

: <CFBundle> ( string -- bundle )
    t <CFFileSystemURL> [
        f swap CFBundleCreate
    ] keep CFRelease ;

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

FUNCTION: CFFileDescriptorRef CFFileDescriptorCreate (
    CFAllocatorRef allocator,
    CFFileDescriptorNativeDescriptor fd,
    Boolean closeOnInvalidate,
    CFFileDescriptorCallBack callout, 
    CFFileDescriptorContext* context
) ;

FUNCTION: void CFFileDescriptorEnableCallBacks (
    CFFileDescriptorRef f,
    CFOptionFlags callBackTypes
) ;

: load-framework ( name -- )
    dup <CFBundle> [
        CFBundleLoadExecutable drop
    ] [
        "Cannot load bundle named " prepend throw
    ] ?if ;

TUPLE: CFRelease-destructor alien disposed ;

M: CFRelease-destructor dispose* alien>> CFRelease ;

: &CFRelease ( alien -- alien )
    dup f CFRelease-destructor boa &dispose drop ; inline

: |CFRelease ( alien -- alien )
    dup f CFRelease-destructor boa |dispose drop ; inline
