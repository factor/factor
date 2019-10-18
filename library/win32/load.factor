USING: alien io kernel parser sequences ;

"kernel32" "kernel32.dll" "stdcall" add-library
"user32"   "user32.dll"   "stdcall" add-library
"gdi32"    "gdi32.dll"    "stdcall" add-library
"winsock"  "ws2_32.dll"   "stdcall" add-library
"mswsock"  "mswsock.dll"  "stdcall" add-library
"libc"     "msvcrt.dll"   "cdecl"   add-library

[
    "/library/win32/win32-io.factor"
    "/library/win32/win32-errors.factor"
    "/library/win32/winsock.factor"
    "/library/win32/win32-io-internals.factor"
    "/library/win32/win32-stream.factor"
    "/library/win32/win32-server.factor"
    "/library/bootstrap/win32-io.factor"
] [
    run-resource
] each
