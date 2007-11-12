! Copyright (C) 2004, 2005 Mackenzie Straight
! Copyright (C) 2007 Slava Pestov
! Copyright (C) 2007 Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: alien assocs init inspector kernel namespaces ;
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

TUPLE: check-ptr ;

M: check-ptr summary drop "Memory allocation failed" ;

: check-ptr ( c-ptr -- c-ptr )
    [ \ check-ptr construct-boa throw ] unless* ;

TUPLE: double-free ;

M: double-free summary drop "Free failed since memory is not allocated" ;

: double-free ( -- * )
    \ double-free construct-empty throw ;

TUPLE: realloc-error ptr size ;

M: realloc-error summary drop "Memory reallocation failed" ;

: realloc-error ( alien size -- * )
    \ realloc-error construct-boa throw ;

<PRIVATE

[ H{ } clone mallocs set-global ] "mallocs" add-init-hook

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
    swap 1 calloc swap keep free ; inline
