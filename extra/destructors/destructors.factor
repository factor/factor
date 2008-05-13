! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations io.backend io.nonblocking libc
kernel namespaces sequences system vectors ;
IN: destructors

SYMBOL: error-destructors
SYMBOL: always-destructors

: add-error-destructor ( obj -- )
    error-destructors get push ;

: add-always-destructor ( obj -- )
    always-destructors get push ;

: do-always-destructors ( -- )
    always-destructors get <reversed> dispose-each ;

: do-error-destructors ( -- )
    error-destructors get <reversed> dispose-each ;

: with-destructors ( quot -- )
    [
        V{ } clone always-destructors set
        V{ } clone error-destructors set
        [ do-always-destructors ]
        [ do-error-destructors ] cleanup
    ] with-scope ; inline

TUPLE: only-once object destroyed ;

M: only-once dispose
    dup destroyed>> [ drop ] [
        [ object>> dispose ] [ t >>destroyed drop ] bi
    ] if ;

: <only-once> f only-once boa ;

! Memory allocations
TUPLE: memory-destructor alien ;

C: <memory-destructor> memory-destructor

M: memory-destructor dispose ( obj -- )
    alien>> free ;

: free-always ( alien -- )
    <memory-destructor> <only-once> add-always-destructor ;

: free-later ( alien -- )
    <memory-destructor> <only-once> add-error-destructor ;

! Handles
TUPLE: handle-destructor alien ;

C: <handle-destructor> handle-destructor

M: handle-destructor dispose ( obj -- )
    alien>> close-handle ;

: close-always ( handle -- )
    <handle-destructor> <only-once> add-always-destructor ;

: close-later ( handle -- )
    <handle-destructor> <only-once> add-error-destructor ;

! Sockets
TUPLE: socket-destructor alien ;

C: <socket-destructor> socket-destructor

HOOK: destruct-socket io-backend ( obj -- )

M: socket-destructor dispose ( obj -- )
    alien>> destruct-socket ;

: close-socket-always ( handle -- )
    <socket-destructor> <only-once> add-always-destructor ;

: close-socket-later ( handle -- )
    <socket-destructor> <only-once> add-error-destructor ;
