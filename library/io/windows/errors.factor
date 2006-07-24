! Copyright (C) 2004 Mackenzie Straight.

IN: win32-api
USE: errors
USE: kernel
USE: io-internals
USE: math
USE: parser
USE: alien
USE: words
USE: sequences

: ERROR_SUCCESS 0 ; inline
: ERROR_HANDLE_EOF 38 ; inline
: ERROR_IO_PENDING 997 ; inline
: WAIT_TIMEOUT 258 ; inline

: FORMAT_MESSAGE_ALLOCATE_BUFFER HEX: 00000100 ;
: FORMAT_MESSAGE_IGNORE_INSERTS  HEX: 00000200 ;
: FORMAT_MESSAGE_FROM_STRING     HEX: 00000400 ;
: FORMAT_MESSAGE_FROM_HMODULE    HEX: 00000800 ;
: FORMAT_MESSAGE_FROM_SYSTEM     HEX: 00001000 ;
: FORMAT_MESSAGE_ARGUMENT_ARRAY  HEX: 00002000 ;
: FORMAT_MESSAGE_MAX_WIDTH_MASK  HEX: 000000FF ;

: MAKELANGID ( primary sub -- lang )
    10 shift bitor ;

: LANG_NEUTRAL 0 ;
: SUBLANG_DEFAULT 1 ;

: GetLastError ( -- int )
    "int" "kernel32" "GetLastError" [ ] alien-invoke ;

: win32-error-message ( id -- string )
    "char*" f "error_message" [ "int" ] alien-invoke ;

: win32-throw-error ( -- )
    GetLastError win32-error-message throw ;

