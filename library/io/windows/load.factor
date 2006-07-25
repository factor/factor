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
    "io"
    "errors"
    "winsock"
    "io-internals"
    "stream"
    "server"
    "io-last"
} [ "/library/io/windows/" swap ".factor" append3 run-resource ] each

IN: kernel
: default-shell "ui" ;
