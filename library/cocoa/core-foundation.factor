! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: hashtables kernel namespaces ;

! Core Foundation utilities -- will be moved elsewhere
: kCFURLPOSIXPathStyle 0 ;

: kCFStringEncodingMacRoman 0 ;

FUNCTION: void* CFURLCreateWithFileSystemPath ( void* allocator, void* filePath, int pathStyle, bool isDirectory ) ;

FUNCTION: void* CFURLCreateWithString ( void* allocator, void* string, void* base ) ;

FUNCTION: void* CFStringCreateWithCString ( void* allocator, char* cStr, int encoding ) ;

FUNCTION: void* CFBundleCreate ( void* allocator, void* bundleURL ) ;

FUNCTION: void* CFBundleGetFunctionPointerForName ( void* bundle, void* functionName ) ;

FUNCTION: bool CFBundleLoadExecutable ( void* bundle ) ;

FUNCTION: void CFRelease ( void* cf ) ;

: <CFString> ( string -- cf )
    f swap kCFStringEncodingMacRoman CFStringCreateWithCString ;

: <CFFileSystemURL> ( string dir? -- cf )
    >r <CFString> f over kCFURLPOSIXPathStyle
    r> CFURLCreateWithFileSystemPath swap CFRelease ;

: <CFURL> ( string -- cf )
    <CFString>
    [ f swap f CFURLCreateWithString ] keep
    CFRelease ;

: <CFBundle> ( string -- cf )
    t <CFFileSystemURL> f over CFBundleCreate swap CFRelease ;

! A rough framework loader.
SYMBOL: frameworks

: load-framework ( name -- )
    frameworks get [
        <CFBundle> dup CFBundleLoadExecutable drop
    ] cache drop ;

H{ } clone frameworks set-global
