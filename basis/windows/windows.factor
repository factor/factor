! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.data alien.libraries arrays kernel math
sequences ;
QUALIFIED-WITH: alien.c-types c
IN: windows

CONSTANT: MAX_UNICODE_PATH 32768

{
    { "advapi32"    "advapi32.dll"       stdcall }
    { "gdi32"       "gdi32.dll"          stdcall }
    { "user32"      "user32.dll"         stdcall }
    { "kernel32"    "kernel32.dll"       stdcall }
    { "winsock"     "ws2_32.dll"         stdcall }
    { "mswsock"     "mswsock.dll"        stdcall }
    { "shell32"     "shell32.dll"        stdcall }
    { "iphlpapi"    "iphlpapi.dll"       stdcall }
    { "libc"        "msvcrt.dll"         cdecl   }
    { "libm"        "msvcrt.dll"         cdecl   }
    { "gdiplus"     "gdiplus.dll"        stdcall }
    { "gl"          "opengl32.dll"       stdcall }
    { "glu"         "glu32.dll"          stdcall }
    { "ole32"       "ole32.dll"          stdcall }
    { "usp10"       "usp10.dll"          stdcall }
    { "psapi"       "psapi.dll"          stdcall }
} [ first3 add-library ] each

: lo-word ( wparam -- lo ) c:short <ref> c:short deref ; inline
: hi-word ( wparam -- hi ) -16 shift lo-word ; inline
: >lo-hi ( WORD -- array ) [ lo-word ] [ hi-word ] bi 2array ; inline
