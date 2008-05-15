! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations io.backend libc
kernel namespaces sequences system vectors ;
IN: destructors

<PRIVATE

SYMBOL: always-destructors

SYMBOL: error-destructors

: do-always-destructors ( -- )
    always-destructors get <reversed> dispose-each ;

: do-error-destructors ( -- )
    error-destructors get <reversed> dispose-each ;

PRIVATE>

: &dispose dup always-destructors get push ; inline

: |dispose dup error-destructors get push ; inline

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

: &free ( alien -- alien )
    <memory-destructor> <only-once> &dispose ; inline

: |free ( alien -- alien )
    <memory-destructor> <only-once> |dispose ; inline
