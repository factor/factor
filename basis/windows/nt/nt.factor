USING: alien sequences alien.libraries ;
{
    { "advapi32" "advapi32.dll" "stdcall" }
    { "dinput"   "dinput8.dll"  "stdcall" }
    { "gdi32"    "gdi32.dll"    "stdcall" }
    { "user32"   "user32.dll"   "stdcall" }
    { "kernel32" "kernel32.dll" "stdcall" }
    { "winsock"  "ws2_32.dll"   "stdcall" }
    { "mswsock"  "mswsock.dll"  "stdcall" }
    { "shell32"  "shell32.dll"  "stdcall" }
    { "libc"     "msvcrt.dll"   "cdecl"   }
    { "libm"     "msvcrt.dll"   "cdecl"   }
    { "gl"       "opengl32.dll" "stdcall" }
    { "glu"      "glu32.dll"    "stdcall" }
    { "ole32"    "ole32.dll"    "stdcall" }
    { "usp10"    "usp10.dll"    "stdcall" }
} [ first3 add-library ] each
