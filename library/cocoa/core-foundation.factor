! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: alien arrays errors hashtables kernel math memory
namespaces sequences ;

TYPEDEF: int CFIndex

! Core Foundation utilities -- will be moved elsewhere
: kCFURLPOSIXPathStyle 0 ;

: kCFStringEncodingMacRoman HEX: 0 ;
: kCFStringEncodingUnicode HEX: 100 ;

FUNCTION: void* CFURLCreateWithFileSystemPath ( void* allocator, void* filePath, int pathStyle, bool isDirectory ) ;

FUNCTION: void* CFURLCreateWithString ( void* allocator, void* string, void* base ) ;

FUNCTION: void* CFURLCopyFileSystemPath ( void* url, int pathStyle ) ;

FUNCTION: void* CFStringCreateWithCString ( void* allocator, char* cStr, int encoding ) ;

FUNCTION: CFIndex CFStringGetLength ( void* theString ) ;

FUNCTION: bool CFStringGetCString ( void* theString, void* buffer, CFIndex bufferSize, int encoding ) ;

FUNCTION: CFIndex CFStringGetLength ( void* string ) ;

FUNCTION: void* CFBundleCreate ( void* allocator, void* bundleURL ) ;

FUNCTION: bool CFBundleLoadExecutable ( void* bundle ) ;

FUNCTION: void CFRelease ( void* cf ) ;

: <CFString> ( string -- cf )
    f swap kCFStringEncodingMacRoman CFStringCreateWithCString ;

: CF>string ( string -- string )
    dup CFStringGetLength 1+ dup <byte-array> [
        swap kCFStringEncodingMacRoman CFStringGetCString drop
    ] keep alien>string ;

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

: running.app? ( -- ? )
    #! Test if we're running Factor.app.
    "Contents/Resources" image subseq? ;
