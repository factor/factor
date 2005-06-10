! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! An array is a range of memory storing pointers to other
! objects. Arrays are not used directly, and their access words
! are not bounds checked. Examples of abstractions built on
! arrays include vectors, hashtables, and tuples.

! These words are unsafe. I'd say "do not call them", but that
! Java-esque. By all means, do use arrays if you need something
! low-level... but be aware that vectors are usually a better
! choice.

IN: math
DEFER: repeat

IN: kernel-internals
USING: kernel math-internals sequences ;

DEFER: array?
BUILTIN: array 8 array? ;

: array-capacity ( a -- n ) 1 slot ; inline
: array-nth ( n a -- obj ) swap 2 fixnum+ slot ; inline
: set-array-nth ( obj n a -- ) swap 2 fixnum+ set-slot ; inline
: dispatch ( n vtable -- ) 2 slot array-nth call ;

M: array length array-capacity ;
M: array nth array-nth ;
M: array set-nth set-array-nth ;
M: array resize resize-array ;

: copy-array ( to from -- )
    dup array-capacity [
        3dup swap array-nth pick rot set-array-nth
    ] repeat 2drop ;
