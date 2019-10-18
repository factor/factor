! Copyright (C) 2004, 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel-internals
USING: alien errors kernel math ;

LIBRARY: libc
FUNCTION: ulong malloc ( ulong size ) ;
FUNCTION: ulong calloc ( ulong count, ulong size ) ;
FUNCTION: void free ( ulong ptr ) ;
FUNCTION: ulong realloc ( ulong ptr, ulong size ) ;
FUNCTION: void memcpy ( ulong dst, ulong src, ulong size ) ;

: check-ptr dup zero? [ "Out of memory" throw ] when ;
