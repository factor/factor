! Copyright (C) 2006 Mackenzie Straight, Doug Coleman.

IN: win32-api
USING: alien errors io-internals kernel math parser sequences words ;

: ERROR_SUCCESS 0 ; inline
: ERROR_HANDLE_EOF 38 ; inline
: ERROR_IO_PENDING 997 ; inline
: WAIT_TIMEOUT 258 ; inline

: FORMAT_MESSAGE_ALLOCATE_BUFFER HEX: 00000100 ; inline
: FORMAT_MESSAGE_IGNORE_INSERTS  HEX: 00000200 ; inline
: FORMAT_MESSAGE_FROM_STRING     HEX: 00000400 ; inline
: FORMAT_MESSAGE_FROM_HMODULE    HEX: 00000800 ; inline
: FORMAT_MESSAGE_FROM_SYSTEM     HEX: 00001000 ; inline
: FORMAT_MESSAGE_ARGUMENT_ARRAY  HEX: 00002000 ; inline
: FORMAT_MESSAGE_MAX_WIDTH_MASK  HEX: 000000FF ; inline

: MAKELANGID ( primary sub -- lang )
    10 shift bitor ;

: LANG_NEUTRAL 0 ; inline
: SUBLANG_DEFAULT 1 ; inline

FUNCTION: char* error_message ( DWORD id ) ;

: win32-throw-error ( -- * )
    GetLastError error_message throw ;

