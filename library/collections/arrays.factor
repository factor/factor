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

IN: sequences-internals
USING: kernel kernel-internals math-internals sequences ;

: array-capacity ( a -- n ) 1 slot ; inline
: array-nth ( n a -- obj ) swap 2 fixnum+ slot ; inline
: set-array-nth ( obj n a -- ) swap 2 fixnum+ set-slot ; inline

M: array clone (clone) ;
M: array length array-capacity ;
M: array nth bounds-check array-nth ;
M: array set-nth bounds-check set-array-nth ;
M: array nth-unsafe array-nth ;
M: array set-nth-unsafe set-array-nth ;
M: array resize resize-array ;

M: byte-array clone (clone) ;
M: byte-array length array-capacity ;
M: byte-array resize resize-array ;

IN: kernel-internals

: make-tuple ( class size -- tuple )
    #! Internal allocation function. Do not call it directly,
    #! since you can fool the runtime and corrupt memory by
    #! specifying an incorrect size. Note that this word is also
    #! handled specially by the compiler's type inferencer.
    <tuple> [ 2 set-slot ] keep ; flushable
