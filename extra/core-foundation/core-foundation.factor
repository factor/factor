! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings alien.syntax kernel
math sequences io.encodings.utf16 ;
IN: core-foundation

TYPEDEF: void* CFAllocatorRef
TYPEDEF: void* CFArrayRef
TYPEDEF: void* CFBundleRef
TYPEDEF: void* CFStringRef
TYPEDEF: void* CFURLRef
TYPEDEF: void* CFUUIDRef
TYPEDEF: bool Boolean
TYPEDEF: int CFIndex
TYPEDEF: int SInt32
TYPEDEF: double CFTimeInterval
TYPEDEF: double CFAbsoluteTime

FUNCTION: CFArrayRef CFArrayCreateMutable ( CFAllocatorRef allocator, CFIndex capacity, void* callbacks ) ;

FUNCTION: void* CFArrayGetValueAtIndex ( CFArrayRef array, CFIndex idx ) ;

FUNCTION: void CFArraySetValueAtIndex ( CFArrayRef array, CFIndex index, void* value ) ;

FUNCTION: CFIndex CFArrayGetCount ( CFArrayRef array ) ;

: kCFURLPOSIXPathStyle 0 ;

FUNCTION: CFURLRef CFURLCreateWithFileSystemPath ( CFAllocatorRef allocator, CFStringRef filePath, int pathStyle, Boolean isDirectory ) ;

FUNCTION: CFURLRef CFURLCreateWithString ( CFAllocatorRef allocator, CFStringRef string, CFURLRef base ) ;

FUNCTION: CFURLRef CFURLCopyFileSystemPath ( CFURLRef url, int pathStyle ) ;

FUNCTION: CFStringRef CFStringCreateWithCharacters ( CFAllocatorRef allocator, wchar_t* cStr, CFIndex numChars ) ;

FUNCTION: CFIndex CFStringGetLength ( CFStringRef theString ) ;

FUNCTION: void CFStringGetCharacters ( void* theString, CFIndex start, CFIndex length, void* buffer ) ;

FUNCTION: CFBundleRef CFBundleCreate ( CFAllocatorRef allocator, CFURLRef bundleURL ) ;

FUNCTION: Boolean CFBundleLoadExecutable ( CFBundleRef bundle ) ;

FUNCTION: void CFRelease ( void* cf ) ;

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

: load-framework ( name -- )
    dup <CFBundle> [
        CFBundleLoadExecutable drop
    ] [
        "Cannot load bundled named " prepend throw
    ] ?if ;
