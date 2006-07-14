IN: scratchpad
USING: alien compiler kernel namespaces parser sequences words ;

{
    { "gdi32" "gdi32" }
    { "user32" "user32" }
    { "kernel32" "kernel32" }
    { "winsock" "ws2_32" }
    { "mswsock" "mswsock" }
} [ first2 add-simple-library ] each
"libc"     "msvcrt.dll"   "cdecl"   add-library

{ 
    "windows-messages"
    "types"
    "gdi32"
    "kernel32"
    "user32"
    "opengl32"
    "utils"

    "io"
    "errors"
    "winsock"
    "io-internals"
    "stream"
    "server"
} [ "/library/io/windows/" swap ".factor" append3 run-resource ] each
    
"native-io" get [
    "/library/bootstrap/win32-io.factor" run-resource
] when

IN: kernel
: default-shell "ui" ;
