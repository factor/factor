! :folding=none:collapseFolds=1:

! $Id$
!
! Copyright (C) 2005 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: kernel-internals
USE: generic
USE: math-internals
USE: kernel
USE: lists
USE: vectors

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
