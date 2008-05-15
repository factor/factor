! Copyright (C) 2004, 2005 Mackenzie Straight
! Copyright (C) 2007, 2008 Slava Pestov
! Copyright (C) 2007, 2008 Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: alien assocs continuations destructors init kernel
namespaces accessors ;
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

SYMBOL: mallocs

PRIVATE>

ERROR: bad-ptr ;

: check-ptr ( c-ptr -- c-ptr )
    [ bad-ptr ] unless* ;

ERROR: double-free ;

ERROR: realloc-error ptr size ;

<PRIVATE

[ H{ } clone mallocs set-global ] "libc" add-init-hook

: add-malloc ( alien -- )
    dup mallocs get-global set-at ;

: delete-malloc ( alien -- )
    [
        mallocs get-global delete-at*
        [ double-free ] unless drop
    ] when* ;

: malloc-exists? ( alien -- ? )
    mallocs get-global key? ;

PRIVATE>

: malloc ( size -- alien )
    (malloc) check-ptr
    dup add-malloc ;

: calloc ( count size -- alien )
    (calloc) check-ptr
    dup add-malloc ;

: realloc ( alien size -- newalien )
    over malloc-exists? [ realloc-error ] unless
    dupd (realloc) check-ptr
    swap delete-malloc
    dup add-malloc ;

: free ( alien -- )
    dup delete-malloc
    (free) ;

: memcpy ( dst src size -- )
    "void" "libc" "memcpy" { "void*" "void*" "ulong" } alien-invoke ;

: with-malloc ( size quot -- )
    swap 1 calloc [ swap keep ] [ free ] [ ] cleanup ; inline

: strlen ( alien -- len )
    "size_t" "libc" "strlen" { "char*" } alien-invoke ;

<PRIVATE

! Memory allocations
TUPLE: memory-destructor alien ;

M: memory-destructor dispose* alien>> free ;

PRIVATE>

: &free ( alien -- alien )
    dup memory-destructor boa &dispose drop ; inline

: |free ( alien -- alien )
    dup memory-destructor boa |dispose drop ; inline
