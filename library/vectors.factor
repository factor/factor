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

IN: vectors
USE: kernel
USE: lists
USE: math
USE: stack
USE: combinators

: 2vector-nth ( n vec vec -- obj obj )
    >r over >r vector-nth r> r> vector-nth ;

: empty-vector ( len -- vec )
    #! Creates a vector with 'len' elements set to f. Unlike
    #! <vector>, which gives an empty vector with a certain
    #! capacity.
    dup <vector> dup >r set-vector-length r> ;

: vector-empty? ( obj -- ? )
    vector-length 0 = ;

: vector-clear ( vector -- )
    #! Clears a vector.
    0 swap set-vector-length ;

: vector-push ( obj vector -- )
    #! Push a value on the end of a vector.
    dup vector-length swap set-vector-nth ;

: vector-peek ( vector -- obj )
    #! Get value at end of vector without removing it.
    dup vector-length pred swap vector-nth ;

: vector-pop ( vector -- obj )
    #! Get value at end of vector and remove it.
    dup vector-length pred ( vector top )
    2dup swap vector-nth >r swap set-vector-length r> ;

: >pop> ( stack -- stack )
    dup vector-pop drop ;

DEFER: vector-map

: vector-clone ( vector -- vector )
    #! Shallow copy of a vector.
    [ ] vector-map ;

: ?vector= ( n vec vec -- ? )
    #! Reached end?
    drop vector-length number= ;

: (vector=) ( n vec vec -- ? )
    3dup ?vector= [
        3drop t ( reached end without any unequal elts )
    ] [
        3dup 2vector-nth = [
            >r >r succ r> r> (vector=)
        ] [
            3drop f
        ] ifte
    ] ifte ;

: vector-length= ( vec vec -- ? )
    vector-length swap vector-length number= ;

: vector= ( obj vec -- ? )
    #! Check if two vectors are equal. Two vectors are
    #! considered equal if they have the same length and contain
    #! equal elements.
    2dup eq? [
        2drop t
    ] [
        over vector? [
            2dup vector-length= [
                0 -rot (vector=)
            ] [
                2drop f
            ] ifte
        ] [
            2drop f
        ] ifte
    ] ifte ;

: ?vector-nth ( n vec -- obj/f )
    2dup vector-length >= [ 2drop f ] [ vector-nth ] ifte ;

: vector-hashcode ( vec -- n )
    0 swap 4 [
        over ?vector-nth hashcode rot bitxor swap
    ] times* drop ;
