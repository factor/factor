! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004, 2005 Slava Pestov.
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
USE: generic
USE: kernel
USE: lists
USE: math
USE: kernel-internals
USE: errors
USE: math-internals

BUILTIN: vector 11

: vector-length ( vec -- len ) >vector 1 slot ; inline

IN: kernel-internals

: (set-vector-length) ( len vec -- ) 1 set-slot ; inline

: assert-positive ( fx -- )
    0 fixnum<
    [ "Vector index must be positive" throw ] when ; inline

: assert-bounds ( fx vec -- )
    over assert-positive
    vector-length fixnum>=
    [ "Vector index out of bounds" throw ] when ; inline

: grow-capacity ( len vec -- )
    #! If the vector cannot accomodate len elements, resize it
    #! to exactly len.
    [ vector-array grow-array ] keep set-vector-array ; inline

: ensure-capacity ( n vec -- )
    #! If n is beyond the vector's length, increase the length,
    #! growing the array if necessary, with an optimistic
    #! doubling of its size.
    2dup vector-length fixnum>= [
        >r 1 fixnum+ r>
        2dup vector-array array-capacity fixnum> [
            over 2 fixnum* over grow-capacity
        ] when
        (set-vector-length)
    ] [
        2drop
    ] ifte ; inline

: copy-array ( to from n -- )
    [ 3dup swap array-nth pick rot set-array-nth ] repeat 2drop ;

IN: vectors

: vector-nth ( n vec -- obj )
    swap >fixnum swap >vector
    2dup assert-bounds vector-array array-nth ;

: set-vector-nth ( obj n vec -- )
    swap >fixnum dup assert-positive swap >vector
    2dup ensure-capacity vector-array
    set-array-nth ;

: set-vector-length ( len vec -- )
    swap >fixnum dup assert-positive swap >vector
    2dup grow-capacity (set-vector-length) ;

: empty-vector ( len -- vec )
    #! Creates a vector with 'len' elements set to f. Unlike
    #! <vector>, which gives an empty vector with a certain
    #! capacity.
    dup <vector> dup >r set-vector-length r> ;

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

: vector>list ( vec -- list )
    dup vector-length swap vector-array array>list ;

: vector-each ( vector quotation -- )
    #! Execute the quotation with each element of the vector
    #! pushed onto the stack.
    >r vector>list r> each ; inline

: vector-map ( vector code -- vector )
    #! Applies code to each element of the vector, return a new
    #! vector with the results. The code must have stack effect
    #! ( obj -- obj ).
    over vector-length <vector> rot [
        swap >r apply r> tuck vector-push
    ] vector-each nip ; inline

: vector-nappend ( v1 v2 -- )
    #! Destructively append v2 to v1.
    [ over vector-push ] vector-each drop ;

: vector-append ( v1 v2 -- vec )
    over vector-length over vector-length + <vector>
    [ rot vector-nappend ] keep
    [ swap vector-nappend ] keep ;

: list>vector ( list -- vector )
    dup length <vector> swap [ over vector-push ] each ;

: vector-project ( n quot -- vector )
    #! Execute the quotation n times, passing the loop counter
    #! the quotation as it ranges from 0..n-1. Collect results
    #! in a new vector.
    project list>vector ; inline

M: vector clone ( vector -- vector )
    dup vector-length dup empty-vector [
        vector-array rot vector-array rot copy-array
    ] keep ;

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
                swap vector>list swap vector>list =
            ] [
                2drop f
            ] ifte
        ] [
            2drop f
        ] ifte
    ] ifte ;

M: vector hashcode ( vec -- n )
    dup vector-length 0 number= [
        drop 0
    ] [
        0 swap vector-nth hashcode
    ] ifte ;

: vector-tail ( n vector -- list )
    #! Return a new list with all elements from the nth
    #! index upwards.
    2dup vector-length swap - [
        pick + over vector-nth
    ] project 2nip ;

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
