! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: alien arrays errors hashtables kernel namespaces
sequences ;

TYPEDEF: int CFIndex

! Core Foundation utilities -- will be moved elsewhere
: kCFURLPOSIXPathStyle 0 ;

: kCFStringEncodingUnicode HEX: 100 ;

FUNCTION: void* CFURLCreateWithFileSystemPath ( void* allocator, void* filePath, int pathStyle, bool isDirectory ) ;

FUNCTION: void* CFURLCreateWithString ( void* allocator, void* string, void* base ) ;

FUNCTION: void* CFURLCopyFileSystemPath ( void* url, int pathStyle ) ;

FUNCTION: void* CFStringCreateWithCString ( void* allocator, ushort* cStr, int encoding ) ;

FUNCTION: CFIndex CFStringGetLength ( void* theString ) ;

FUNCTION: ushort* CFStringGetCStringPtr ( void* theString, int encoding ) ;

FUNCTION: void* CFBundleCreate ( void* allocator, void* bundleURL ) ;

FUNCTION: void* CFBundleGetMainBundle ( ) ;

FUNCTION: void* CFBundleCopyExecutableURL ( void* bundle ) ;

FUNCTION: void* CFBundleGetFunctionPointerForName ( void* bundle, void* functionName ) ;

FUNCTION: bool CFBundleLoadExecutable ( void* bundle ) ;

FUNCTION: void CFRelease ( void* cf ) ;

: <CFString> ( string -- cf )
    f swap kCFStringEncodingUnicode CFStringCreateWithCString ;

: CF>string ( string -- string )
    kCFStringEncodingUnicode CFStringGetCStringPtr ;

: <CFFileSystemURL> ( string dir? -- cf )
    >r <CFString> f over kCFURLPOSIXPathStyle
    r> CFURLCreateWithFileSystemPath swap CFRelease ;

: <CFURL> ( string -- cf )
    <CFString>
    [ f swap f CFURLCreateWithString ] keep
    CFRelease ;

: <CFBundle> ( string -- cf )
    t <CFFileSystemURL> f over CFBundleCreate swap CFRelease ;

: load-framework ( name -- )
    dup <CFBundle> [
        CFBundleLoadExecutable drop
    ] [
        "Cannot load bundled named " swap append throw
    ] ?if ;

: executable ( -- path )
    CFBundleGetMainBundle CFBundleCopyExecutableURL [
        kCFURLPOSIXPathStyle CFURLCopyFileSystemPath
        [ CF>string ] keep CFRelease
    ] keep CFRelease ;

: running.app? ( -- ? )
    #! Test if we're running Factor.app.
    executable "Contents/MacOS/Factor" tail? ;

IN: kernel

: default-shell running.app? "ui" "tty" ? ;
