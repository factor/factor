! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax kernel core-foundation.strings
core-foundation core-foundation.urls ;
IN: core-foundation.urls

CONSTANT: kCFURLPOSIXPathStyle 0

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
