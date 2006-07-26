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
    "gdi32"
    "kernel32"
    "user32"
    "opengl32"
    "utils"
    "ui"
    "clipboard"

} [ "/library/ui/windows/" swap ".factor" append3 run-resource ] each
    
IN: kernel
: default-shell "tty" ;
