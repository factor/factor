! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien errors io kernel math namespaces parser prettyprint words ;
IN: win32-api

! You must LocalFree the return value!
FUNCTION: void* error_message ( DWORD id ) ;

: (win32-error) ( n -- )
    dup zero? [
        drop
    ] [
        error_message
        dup alien>u16-string
        swap LocalFree drop
        throw
    ] if ;
    

: win32-error ( -- )
    GetLastError (win32-error) ;

: win32-error=0/f dup zero? swap f = or [ win32-error ] when ;
: win32-error>0 0 > [ win32-error ] when ;
: win32-error<0 0 < [ win32-error ] when ;
: win32-error<>0 zero? [ win32-error ] unless ;

: lo-word ( wparam -- lo ) HEX: ffff bitand ;
: hi-word ( wparam -- hi ) -16 shift ;

: msgbox ( str -- )
    f swap "DebugMsg" MB_OK MessageBox drop ;
