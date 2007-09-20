! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax alien.c-types arrays combinators
io io.nonblocking kernel math namespaces parser prettyprint
sequences windows.errors windows.types windows.kernel32 words ;
IN: windows

: lo-word ( wparam -- lo ) <short> *short ; inline
: hi-word ( wparam -- hi ) -16 shift lo-word ; inline

! You must LocalFree the return value!
FUNCTION: void* error_message ( DWORD id ) ;

: (win32-error-string) ( n -- string )
    error_message
    dup alien>u16-string
    swap LocalFree drop ;

: win32-error-string ( -- str )
    GetLastError (win32-error-string) ;

: (win32-error) ( n -- )
    dup zero? [
        drop
    ] [
        win32-error-string throw
    ] if ;

: win32-error ( -- )
    GetLastError (win32-error) ;

: win32-error=0/f { 0 f } member? [ win32-error ] when ;
: win32-error>0 0 > [ win32-error ] when ;
: win32-error<0 0 < [ win32-error ] when ;
: win32-error<>0 zero? [ win32-error ] unless ;

: invalid-handle? ( handle -- )
    INVALID_HANDLE_VALUE = [
        win32-error-string throw
    ] when ;

: (expected-io-error?) ( error-code -- ? )
    ERROR_SUCCESS
    ERROR_IO_INCOMPLETE
    ERROR_IO_PENDING
    WAIT_TIMEOUT 4array member? ;

: expected-io-error? ( error-code -- )
    dup (expected-io-error?) [
        drop
    ] [
        (win32-error-string) throw
    ] if ;

: io-error ( return-value -- )
    { 0 f } member? [ GetLastError expected-io-error? ] when ;

: overlapped-error? ( port n -- ? )
    zero? [
        GetLastError
        {
            { [ dup (expected-io-error?) ] [ 2drop t ] }
            { [ dup ERROR_HANDLE_EOF = ] [ drop t swap set-port-eof? f ] }
            { [ t ] [ (win32-error-string) throw ] }
        } cond
    ] [
        drop t
    ] if ;
