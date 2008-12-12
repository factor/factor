! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel core-foundation.strings
core-foundation ;
IN: core-foundation.urls

: kCFURLPOSIXPathStyle 0 ; inline

TYPEDEF: void* CFURLRef

FUNCTION: CFURLRef CFURLCreateWithFileSystemPath ( CFAllocatorRef allocator, CFStringRef filePath, int pathStyle, Boolean isDirectory ) ;

FUNCTION: CFURLRef CFURLCreateWithString ( CFAllocatorRef allocator, CFStringRef string, CFURLRef base ) ;

FUNCTION: CFURLRef CFURLCopyFileSystemPath ( CFURLRef url, int pathStyle ) ;

: <CFFileSystemURL> ( string dir? -- url )
    [ <CFString> f over kCFURLPOSIXPathStyle ] dip
    CFURLCreateWithFileSystemPath swap CFRelease ;

: <CFURL> ( string -- url )
    <CFString>
    [ f swap f CFURLCreateWithString ] keep
    CFRelease ;
