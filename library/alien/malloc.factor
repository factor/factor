! Copyright (C) 2004, 2005 Mackenzie Straight.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel-internals
USING: alien errors kernel math ;

: malloc ( size -- address )
    "ulong" "libc" "malloc" [ "ulong" ] alien-invoke ;

: free ( address -- )
    "void" "libc" "free" [ "ulong" ] alien-invoke ;

: realloc ( address size -- address )
    "ulong" "libc" "realloc" [ "ulong" "ulong" ] alien-invoke ;

: memcpy ( dst src size -- )
    "void" "libc" "memcpy" [ "ulong" "ulong" "ulong" ] alien-invoke ;

: check-ptr ( ptr -- ptr )
    dup 0 number= [ "Out of memory" throw ] when ;
