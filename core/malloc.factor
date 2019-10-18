! Copyright (C) 2004, 2005 Mackenzie Straight
! Copyright (C) 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: libc
USING: errors kernel ;

LIBRARY: libc
FUNCTION: void* malloc ( ulong size ) ;
FUNCTION: void* calloc ( ulong count, ulong size ) ;
FUNCTION: void free ( void* ptr ) ;
FUNCTION: void* realloc ( void* ptr, ulong size ) ;
FUNCTION: void memcpy ( void* dst, void* src, ulong size ) ;

TUPLE: check-ptr ;

: check-ptr ( c-ptr -- c-ptr ) [ <check-ptr> throw ] unless* ;

: with-malloc ( size quot -- )
    swap 1 calloc check-ptr swap keep free ; inline
