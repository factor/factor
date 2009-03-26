USING: alien sequences alien.libraries ;
{
    { "advapi32" "\\windows\\coredll.dll" "stdcall" }
    { "gdi32"    "\\windows\\coredll.dll" "stdcall" }
    { "user32"   "\\windows\\coredll.dll" "stdcall" }
    { "kernel32" "\\windows\\coredll.dll" "stdcall" }
    { "winsock"  "\\windows\\ws2.dll" "stdcall" }
    { "mswsock"  "\\windows\\ws2.dll" "stdcall" }
    { "libc"     "\\windows\\coredll.dll" "stdcall"   }
    { "libm"     "\\windows\\coredll.dll" "stdcall"   }
    ! { "gl"       "libGLES_CM.dll"         "stdcall" }
    ! { "glu"      "libGLES_CM.dll"         "stdcall" }
    { "ole32"    "ole32.dll"    "stdcall" }
} [ first3 add-library ] each
