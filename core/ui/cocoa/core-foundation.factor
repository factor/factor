! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: alien arrays errors hashtables kernel math memory
namespaces sequences ;

TYPEDEF: int CFIndex

FUNCTION: void* CFArrayCreateMutable ( void* allocator, CFIndex capacity, void* callbacks ) ;

FUNCTION: void* CFArrayGetValueAtIndex ( void* array, CFIndex idx ) ;

FUNCTION: void CFArraySetValueAtIndex ( void* array, CFIndex index, void* value ) ;

FUNCTION: CFIndex CFArrayGetCount ( void* array ) ;

: kCFURLPOSIXPathStyle 0 ;

FUNCTION: void* CFURLCreateWithFileSystemPath ( void* allocator, void* filePath, int pathStyle, bool isDirectory ) ;

FUNCTION: void* CFURLCreateWithString ( void* allocator, void* string, void* base ) ;

FUNCTION: void* CFURLCopyFileSystemPath ( void* url, int pathStyle ) ;

FUNCTION: void* CFStringCreateWithCharacters ( void* allocator, ushort* cStr, CFIndex numChars ) ;

FUNCTION: CFIndex CFStringGetLength ( void* theString ) ;

FUNCTION: void CFStringGetCharacters ( void* theString, CFIndex start, CFIndex length, void* buffer ) ;

FUNCTION: CFIndex CFStringGetLength ( void* string ) ;

FUNCTION: void* CFBundleCreate ( void* allocator, void* bundleURL ) ;

FUNCTION: bool CFBundleLoadExecutable ( void* bundle ) ;

FUNCTION: void CFRelease ( void* cf ) ;

: CF>array ( alien -- array )
    dup CFArrayGetCount [ CFArrayGetValueAtIndex ] map-with ;

: <CFArray> ( seq -- array )
    [ f swap length f CFArrayCreateMutable ] keep
    [ length ] keep
    [ >r dupd r> CFArraySetValueAtIndex ] 2each ;

: <CFString> ( string -- cf )
    f swap dup length CFStringCreateWithCharacters ;

: CF>string ( string -- string )
    dup CFStringGetLength 1+ "ushort" <c-array> [
        >r 0 over CFStringGetLength r> CFStringGetCharacters
    ] keep alien>u16-string ;

: CF>string-array ( alien -- seq )
    CF>array [ CF>string ] map ;

: <CFFileSystemURL> ( string dir? -- cf )
    >r <CFString> f over kCFURLPOSIXPathStyle
    r> CFURLCreateWithFileSystemPath swap CFRelease ;

: <CFURL> ( string -- cf )
    <CFString>
    [ f swap f CFURLCreateWithString ] keep
    CFRelease ;

: <CFBundle> ( string -- cf )
    t <CFFileSystemURL> [
        f swap CFBundleCreate
    ] keep CFRelease ;

: load-framework ( name -- )
    dup <CFBundle> [
        CFBundleLoadExecutable drop
    ] [
        "Cannot load bundled named " swap append throw
    ] ?if ;
