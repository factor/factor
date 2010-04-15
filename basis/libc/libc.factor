! Copyright (C) 2004, 2005 Mackenzie Straight
! Copyright (C) 2007, 2010 Slava Pestov
! Copyright (C) 2007, 2008 Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax assocs continuations
alien.destructors kernel namespaces accessors sets summary
destructors destructors.private ;
IN: libc

LIBRARY: factor

FUNCTION-ALIAS: errno
    int err_no ( ) ;

FUNCTION-ALIAS: set-errno
    void set_err_no ( int err-no ) ;

: clear-errno ( -- )
    0 set-errno ;

: preserve-errno ( quot -- )
    errno [ call ] dip set-errno ; inline

LIBRARY: libc

FUNCTION-ALIAS: (malloc)
    void* malloc ( ulong size ) ;

FUNCTION-ALIAS: (calloc)
    void* calloc ( ulong count,  ulong size ) ;

FUNCTION-ALIAS: (free)
    void free ( void* alien ) ;

FUNCTION-ALIAS: (realloc)
    void* realloc ( void* alien, ulong size ) ;

<PRIVATE

! We stick malloc-ptr instances in the global disposables set
TUPLE: malloc-ptr value continuation ;

M: malloc-ptr hashcode* value>> hashcode* ;

M: malloc-ptr equal?
    over malloc-ptr? [ [ value>> ] bi@ = ] [ 2drop f ] if ;

: <malloc-ptr> ( value -- malloc-ptr )
    malloc-ptr new swap >>value ;

PRIVATE>

ERROR: bad-ptr ;

M: bad-ptr summary
    drop "Memory allocation failed" ;

: check-ptr ( c-ptr -- c-ptr )
    [ bad-ptr ] unless* ;

ERROR: realloc-error ptr size ;

M: realloc-error summary
    drop "Memory reallocation failed" ;

<PRIVATE

: add-malloc ( alien -- alien )
    dup <malloc-ptr> register-disposable ;

: delete-malloc ( alien -- )
    [ <malloc-ptr> unregister-disposable ] when* ;

: malloc-exists? ( alien -- ? )
    <malloc-ptr> disposables get key? ;

PRIVATE>

: malloc ( size -- alien )
    (malloc) check-ptr add-malloc ;

: calloc ( count size -- alien )
    (calloc) check-ptr add-malloc ;

: realloc ( alien size -- newalien )
    [ >c-ptr ] dip
    over malloc-exists? [ realloc-error ] unless
    [ drop ] [ (realloc) check-ptr ] 2bi
    [ delete-malloc ] [ add-malloc ] bi* ;

: free ( alien -- )
    >c-ptr [ delete-malloc ] [ (free) ] bi ;

FUNCTION: void memcpy ( void* dst, void* src, ulong size ) ;

FUNCTION: int memcmp ( void* a, void* b, ulong size ) ;

: memory= ( a b size -- ? )
    memcmp 0 = ;

FUNCTION: size_t strlen ( c-string alien ) ;

DESTRUCTOR: free
DESTRUCTOR: (free)
