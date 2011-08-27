! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien sequences alien.libraries ;
IN: windows

CONSTANT: MAX_UNICODE_PATH 32768

{
    { "advapi32"    "advapi32.dll"       stdcall }
    { "dinput"      "dinput8.dll"        stdcall }
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
    { "xinput"      "xinput1_3.dll"      stdcall }
    { "dxgi"        "dxgi.dll"           stdcall }
    { "d2d1"        "d2d1.dll"           stdcall }
    { "d3d9"        "d3d9.dll"           stdcall }
    { "d3d10"       "d3d10.dll"          stdcall }
    { "d3d10_1"     "d3d10_1.dll"        stdcall }
    { "d3d11"       "d3d11.dll"          stdcall }
    { "d3dcompiler" "d3dcompiler_42.dll" stdcall } 
    { "d3dcsx"      "d3dcsx_42.dll"      stdcall }
    { "d3dx9"       "d3dx9_42.dll"       stdcall }
    { "d3dx10"      "d3dx10_42.dll"      stdcall }
    { "d3dx11"      "d3dx11_42.dll"      stdcall }
    { "dwrite"      "dwrite.dll"         stdcall }
    { "x3daudio"    "x3daudio1_6.dll"    stdcall }
    { "xactengine"  "xactengine3_5.dll"  stdcall }
    { "xapofx"      "xapofx1_3.dll"      stdcall }
    { "xaudio2"     "xaudio2_5.dll"      stdcall }
} [ first3 add-library ] each
