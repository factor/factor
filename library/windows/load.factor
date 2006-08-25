IN: scratchpad
USING: alien compiler kernel namespaces parser sequences words ;

{
    { "gdi32"    "gdi32.dll"    "stdcall" }
    { "user32"   "user32.dll"   "stdcall" }
    { "kernel32" "kernel32.dll" "stdcall" }
    { "winsock"  "ws2_32.dll"   "stdcall" }
    { "mswsock"  "mswsock.dll"  "stdcall" }
    { "libc"     "msvcrt.dll"   "cdecl"   }
} [ first3 add-library ] each

{ 
    "windows-messages"
    "types"
    "gdi32-constants"
    "gdi32"
    "kernel32-constants"
    "kernel32-structs"
    "kernel32-types"
    "kernel32"
    "user32-constants"
    "user32-structs"
    "user32-types"
    "user32"
    "opengl32"
    "utils"
} [ "/library/windows/" swap ".factor" append3 run-resource ] each
    
IN: command-line
: default-shell "tty" ;
