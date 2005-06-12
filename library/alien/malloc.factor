! Copyright (C) 2004, 2005 Mackenzie Straight.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel-internals
USING: alien errors kernel ;

LIBRARY: libc
FUNCTION: ulong malloc ( ulong size ) ;
FUNCTION: ulong free ( ulong ptr ) ;
FUNCTION: ulong realloc ( ulong ptr, ulong size ) ;
FUNCTION: void memcpy ( ulong dst, ulong src, ulong size ) ;

: check-ptr dup 0 = [ "Out of memory" throw ] when ;
