! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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

IN: vectors
USE: kernel
USE: lists
USE: math

: vector-each ( vector code -- )
    #! Execute the code, with each element of the vector
    #! pushed onto the stack.
    over vector-length [
        -rot 2dup >r >r >r vector-nth r> call r> r>
    ] times* 2drop ; inline

: vector-map ( vector code -- vector )
    #! Applies code to each element of the vector, return a new
    #! vector with the results. The code must have stack effect
    #! ( obj -- obj ).
    over vector-length <vector> rot [
        swap >r apply r> tuck vector-push
    ] vector-each nip ; inline

: vector-and ( vector -- ? )
    #! Logical and of all elements in the vector.
    t swap [ and ] vector-each ;

: vector-all? ( vector pred -- ? )
    vector-map vector-and ; inline

: vector-append ( v1 v2 -- )
    #! Destructively append v2 to v1.
    [ over vector-push ] vector-each drop ;

: vector-project ( n quot -- accum )
    #! Execute the quotation n times, passing the loop counter
    #! the quotation as it ranges from 0..n-1. Collect results
    #! in a new vector.
    over <vector> rot [
        -rot 2dup >r >r slip vector-push r> r>
    ] times* nip ; inline

: vector-zip ( v1 v2 -- v )
    #! Make a new vector with each pair of elements from the
    #! first two in a pair.
    over vector-length [
        pick pick >r over >r vector-nth r> r> vector-nth cons
    ] vector-project nip nip ;

: vector-2map ( v1 v2 quot -- v )
    #! Apply a quotation with stack effect ( obj obj -- obj ) to
    #! each pair of elements from v1 and v2, collecting them
    #! into a new list. Behavior is undefined if vector lengths
    #! differ.
    -rot vector-zip [
        swap dup >r >r uncons r> call r> swap
    ] vector-map nip ; inline
