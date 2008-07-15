! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings alien.syntax kernel
math sequences io.encodings.utf16 ;
IN: core-foundation

TYPEDEF: void* CFAllocatorRef
TYPEDEF: void* CFArrayRef
TYPEDEF: void* CFDataRef
TYPEDEF: void* CFDictionaryRef
TYPEDEF: void* CFMutableDictionaryRef
TYPEDEF: void* CFNumberRef
TYPEDEF: void* CFBundleRef
TYPEDEF: void* CFRunLoopRef
TYPEDEF: void* CFSetRef
TYPEDEF: void* CFStringRef
TYPEDEF: void* CFURLRef
TYPEDEF: void* CFUUIDRef
TYPEDEF: void* CFTypeRef
TYPEDEF: bool Boolean
TYPEDEF: int CFIndex
TYPEDEF: int SInt32
TYPEDEF: uint UInt32
TYPEDEF: uint CFTypeID
TYPEDEF: double CFTimeInterval
TYPEDEF: double CFAbsoluteTime

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

FUNCTION: CFArrayRef CFArrayCreateMutable ( CFAllocatorRef allocator, CFIndex capacity, void* callbacks ) ;

FUNCTION: void* CFArrayGetValueAtIndex ( CFArrayRef array, CFIndex idx ) ;

FUNCTION: void CFArraySetValueAtIndex ( CFArrayRef array, CFIndex index, void* value ) ;

FUNCTION: CFIndex CFArrayGetCount ( CFArrayRef array ) ;

: kCFURLPOSIXPathStyle 0 ; inline
: kCFAllocatorDefault f ; inline

FUNCTION: CFURLRef CFURLCreateWithFileSystemPath ( CFAllocatorRef allocator, CFStringRef filePath, int pathStyle, Boolean isDirectory ) ;

FUNCTION: CFURLRef CFURLCreateWithString ( CFAllocatorRef allocator, CFStringRef string, CFURLRef base ) ;

FUNCTION: CFURLRef CFURLCopyFileSystemPath ( CFURLRef url, int pathStyle ) ;

FUNCTION: CFStringRef CFStringCreateWithCharacters ( CFAllocatorRef allocator, wchar_t* cStr, CFIndex numChars ) ;

FUNCTION: CFIndex CFStringGetLength ( CFStringRef theString ) ;

FUNCTION: void CFStringGetCharacters ( void* theString, CFIndex start, CFIndex length, void* buffer ) ;

FUNCTION: CFNumberRef CFNumberCreate ( CFAllocatorRef allocator, CFNumberType theType, void* valuePtr ) ;

FUNCTION: CFDataRef CFDataCreate ( CFAllocatorRef allocator, uchar* bytes, CFIndex length ) ;

FUNCTION: CFBundleRef CFBundleCreate ( CFAllocatorRef allocator, CFURLRef bundleURL ) ;

FUNCTION: Boolean CFBundleLoadExecutable ( CFBundleRef bundle ) ;

FUNCTION: CFTypeRef CFRetain ( CFTypeRef cf ) ;
FUNCTION: void CFRelease ( CFTypeRef cf ) ;

FUNCTION: CFTypeID CFGetTypeID ( CFTypeRef cf ) ;

FUNCTION: CFRunLoopRef CFRunLoopGetCurrent ( ) ;
FUNCTION: CFRunLoopRef CFRunLoopGetMain ( ) ;

: CF>array ( alien -- array )
    dup CFArrayGetCount [ CFArrayGetValueAtIndex ] with map ;

: <CFArray> ( seq -- alien )
    [ f swap length f CFArrayCreateMutable ] keep
    [ length ] keep
    [ >r dupd r> CFArraySetValueAtIndex ] 2each ;

: <CFString> ( string -- alien )
    f swap dup length CFStringCreateWithCharacters ;

: CF>string ( alien -- string )
    dup CFStringGetLength 1+ "ushort" <c-array> [
        >r 0 over CFStringGetLength r> CFStringGetCharacters
    ] keep utf16n alien>string ;

: CF>string-array ( alien -- seq )
    CF>array [ CF>string ] map ;

: <CFStringArray> ( seq -- alien )
    [ <CFString> ] map dup <CFArray> swap [ CFRelease ] each ;

: <CFFileSystemURL> ( string dir? -- url )
    >r <CFString> f over kCFURLPOSIXPathStyle
    r> CFURLCreateWithFileSystemPath swap CFRelease ;

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

: load-framework ( name -- )
    dup <CFBundle> [
        CFBundleLoadExecutable drop
    ] [
        "Cannot load bundled named " prepend throw
    ] ?if ;

: kCFRunLoopDefaultMode "kCFRunLoopDefaultMode" <CFString> ; inline
