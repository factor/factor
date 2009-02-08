! Copyright (C) 2004, 2005 Mackenzie Straight
! Copyright (C) 2007, 2009 Slava Pestov
! Copyright (C) 2007, 2008 Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: alien assocs continuations alien.destructors kernel
namespaces accessors sets summary ;
IN: libc

: errno ( -- int )
    "int" "factor" "err_no" { } alien-invoke ;

: clear-errno ( -- )
    "void" "factor" "clear_err_no" { } alien-invoke ;

<PRIVATE

: (malloc) ( size -- alien )
    "void*" "libc" "malloc" { "ulong" } alien-invoke ;

: (calloc) ( count size -- alien )
    "void*" "libc" "calloc" { "ulong" "ulong" } alien-invoke ;

: (free) ( alien -- )
    "void" "libc" "free" { "void*" } alien-invoke ;

: (realloc) ( alien size -- newalien )
    "void*" "libc" "realloc" { "void*" "ulong" } alien-invoke ;

SYMBOL: malloc-expiry

: mallocs ( -- assoc )
    malloc-expiry get-global expired? [
        -1 <alien> malloc-expiry set-global
        H{ } clone dup \ mallocs set-global
    ] [
        \ mallocs get-global
    ] if ;

PRIVATE>

ERROR: bad-ptr ;

M: bad-ptr summary
    drop "Memory allocation failed" ;

: check-ptr ( c-ptr -- c-ptr )
    [ bad-ptr ] unless* ;

ERROR: double-free ;

M: double-free summary
    drop "Free failed since memory is not allocated" ;

ERROR: realloc-error ptr size ;

M: realloc-error summary
    drop "Memory reallocation failed" ;

<PRIVATE

: add-malloc ( alien -- alien )
    dup mallocs conjoin ;

: delete-malloc ( alien -- )
    [
        mallocs delete-at*
        [ drop ] [ double-free ] if
    ] when* ;

: malloc-exists? ( alien -- ? )
    mallocs key? ;

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

: memcpy ( dst src size -- )
    "void" "libc" "memcpy" { "void*" "void*" "ulong" } alien-invoke ;

: strlen ( alien -- len )
    "size_t" "libc" "strlen" { "char*" } alien-invoke ;

DESTRUCTOR: free
