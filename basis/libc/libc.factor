! Copyright (C) 2004, 2005 Mackenzie Straight
! Copyright (C) 2007, 2008 Slava Pestov
! Copyright (C) 2007, 2008 Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: alien assocs continuations destructors kernel
namespaces accessors sets summary ;
IN: libc

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

: add-malloc ( alien -- )
    mallocs conjoin ;

: delete-malloc ( alien -- )
    [
        mallocs delete-at*
        [ double-free ] unless drop
    ] when* ;

: malloc-exists? ( alien -- ? )
    mallocs key? ;

PRIVATE>

: malloc ( size -- alien )
    (malloc) check-ptr
    dup add-malloc ;

: calloc ( count size -- alien )
    (calloc) check-ptr
    dup add-malloc ;

: realloc ( alien size -- newalien )
    [ >c-ptr ] dip
    over malloc-exists? [ realloc-error ] unless
    dupd (realloc) check-ptr
    swap delete-malloc
    dup add-malloc ;

: free ( alien -- )
    >c-ptr [ delete-malloc ] [ (free) ] bi ;

: memcpy ( dst src size -- )
    "void" "libc" "memcpy" { "void*" "void*" "ulong" } alien-invoke ;

: strlen ( alien -- len )
    "size_t" "libc" "strlen" { "char*" } alien-invoke ;

<PRIVATE

! Memory allocations
TUPLE: memory-destructor alien disposed ;

M: memory-destructor dispose* alien>> free ;

PRIVATE>

: &free ( alien -- alien )
    dup f memory-destructor boa &dispose drop ; inline

: |free ( alien -- alien )
    dup f memory-destructor boa |dispose drop ; inline
