! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel-internals
USING: generic math-internals kernel lists vectors ;

! An array is a range of memory storing pointers to other
! objects. Arrays are not used directly, and their access words
! are not bounds checked. Examples of abstractions built on
! arrays include vectors, hashtables, and tuples.

! These words are unsafe. I'd say "do not call them", but that
! Java-esque. By all means, do use arrays if you need something
! low-level... but be aware that vectors are usually a better
! choice.

BUILTIN: array 8

: array-capacity   ( array -- n )   1 slot ; inline
: vector-array     ( vec -- array ) >vector 2 slot ; inline
: set-vector-array ( array vec -- ) >vector 2 set-slot ; inline

: array-nth ( n array -- obj )
    swap 2 fixnum+ slot ; inline

: set-array-nth ( obj n array -- )
    swap 2 fixnum+ set-slot ; inline

: (array>list) ( n i array -- list )
    pick pick fixnum<= [
        3drop [ ]
    ] [
        2dup array-nth >r >r 1 fixnum+ r> (array>list) r>
        swap cons
    ] ifte ;

: array>list ( n array -- list )
    0 swap (array>list) ;
