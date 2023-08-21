! Copyright (C) 2005, 2006 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries sequences ;
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
    { "libc"        "ucrtbase.dll"       cdecl   }
    { "libm"        "ucrtbase.dll"       cdecl   }
    { "gdiplus"     "gdiplus.dll"        stdcall }
    { "gl"          "opengl32.dll"       stdcall }
    { "glu"         "glu32.dll"          stdcall }
    { "ole32"       "ole32.dll"          stdcall }
    { "shcore"      "shcore.dll"         stdcall }
    { "usp10"       "usp10.dll"          stdcall }
    { "psapi"       "psapi.dll"          stdcall }
    { "winmm"       "winmm.dll"          stdcall }
    { "ntdll"       "ntdll.dll"          stdcall }
    { "crypt32"     "crypt32.dll"        stdcall }
    { "powrprof"    "powrprof.dll"       stdcall }
} [ first3 add-library ] each
