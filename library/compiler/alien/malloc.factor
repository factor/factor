! Copyright (C) 2004, 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
IN: libc
USING: alien errors kernel math ;

LIBRARY: libc
FUNCTION: void* malloc ( ulong size ) ;
FUNCTION: void* calloc ( ulong count, ulong size ) ;
FUNCTION: void free ( void* ptr ) ;
FUNCTION: void* realloc ( void* ptr, ulong size ) ;
FUNCTION: void memcpy ( void* dst, void* src, ulong size ) ;

TUPLE: check-ptr ;
: check-ptr [ <check-ptr> throw ] unless* ;

: with-malloc ( size quot -- )
    swap 1 calloc check-ptr [ swap call ] keep free ; inline
