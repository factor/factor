! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
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

USE: generic
USE: kernel
USE: lists
USE: math

IN: errors
DEFER: throw

IN: kernel-internals

BUILTIN: array 8

! UNSAFE!
: array-capacity   ( array -- n )   1 integer-slot ; inline
: vector-array     ( vec -- array ) 2 slot ; inline
: set-vector-array ( array vec -- ) 2 set-slot ; inline

: grow-vector-array ( len vec -- )
    [ vector-array grow-array ] keep set-vector-array ; inline

: (set-vector-length) ( len vec -- ) 1 set-integer-slot ; inline

IN: vectors

BUILTIN: vector 11

: vector-length ( vec -- len ) >vector 1 integer-slot ; inline

: set-vector-length ( len vec -- )
    >vector over 0 < [
        "Vector length must be positive" throw 2drop
    ] [
        2dup (set-vector-length) grow-vector-array
    ] ifte ; inline

: empty-vector ( len -- vec )
    #! Creates a vector with 'len' elements set to f. Unlike
    #! <vector>, which gives an empty vector with a certain
    #! capacity.
    dup <vector> dup >r set-vector-length r> ;

: vector-empty? ( obj -- ? )
    vector-length 0 = ;

: vector-push ( obj vector -- )
    #! Push a value on the end of a vector.
    dup vector-length swap set-vector-nth ;

: vector-peek ( vector -- obj )
    #! Get value at end of vector.
    dup vector-length 1 - swap vector-nth ;

: vector-pop ( vector -- obj )
    #! Get value at end of vector and remove it.
    dup vector-length 1 - ( vector top )
    2dup swap vector-nth >r swap set-vector-length r> ;

: >pop> ( stack -- stack )
    dup vector-pop drop ;

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

: vector-nappend ( v1 v2 -- )
    #! Destructively append v2 to v1.
    [ over vector-push ] vector-each drop ;

: vector-append ( v1 v2 -- vec )
    over vector-length over vector-length + <vector>
    [ rot vector-nappend ] keep
    [ swap vector-nappend ] keep ;

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
    over vector-length over vector-length min [
        pick pick >r over >r vector-nth r> r> vector-nth cons
    ] vector-project nip nip ;

: vector-clone ( vector -- vector )
    #! Shallow copy of a vector.
    [ ] vector-map ;

: list>vector ( list -- vector )
    dup length <vector> swap [ over vector-push ] each ;

: stack>list ( vector -- list )
    [ ] swap [ swons ] vector-each ;

: vector>list ( vector -- list )
    stack>list reverse ;

: vector-length= ( vec vec -- ? )
    vector-length swap vector-length number= ;

M: vector = ( obj vec -- ? )
    #! Check if two vectors are equal. Two vectors are
    #! considered equal if they have the same length and contain
    #! equal elements.
    2dup eq? [
        2drop t
    ] [
        over vector? [
            2dup vector-length= [
                swap stack>list swap stack>list =
            ] [
                2drop f
            ] ifte
        ] [
            2drop f
        ] ifte
    ] ifte ;

: ?vector-nth ( n vec -- obj/f )
    2dup vector-length >= [ 2drop f ] [ vector-nth ] ifte ;

M: vector hashcode ( vec -- n )
    0 swap 4 [
        over ?vector-nth hashcode rot bitxor swap
    ] times* drop ;

: vector-head ( n vector -- list )
    #! Return a new list with all elements up to the nth
    #! element.
    swap [ over vector-nth ] vector-project nip ;

: vector-tail ( n vector -- list )
    #! Return a new list with all elements from the nth
    #! index upwards.
    2dup vector-length swap - [
        pick + over vector-nth
    ] project nip nip ;

: vector-tail* ( n vector -- list )
    #! Unlike vector-tail, n is an index from the end of the
    #! vector. For example, if n=1, this returns a vector of
    #! one element.
    [ vector-length swap - ] keep vector-tail ;

! Find a better place for this
IN: kernel

: depth ( -- n )
    #! Push the number of elements on the datastack.
    datastack vector-length ;
