! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel-internals
DEFER: (set-vector-length)
DEFER: vector-array
DEFER: set-vector-array

IN: vectors
USING: generic kernel lists math kernel-internals errors
math-internals ;

BUILTIN: vector 11
    [ 1 "vector-length" (set-vector-length) ]
    [ 2 vector-array set-vector-array ] ;

IN: kernel-internals

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
    [ vector-array grow-array ] keep set-vector-array ;

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
    ] ifte ;

: copy-array ( to from n -- )
    [ 3dup swap array-nth pick rot set-array-nth ] repeat 2drop ;

IN: vectors

: vector-nth ( n vec -- obj )
    >r >fixnum r> 2dup assert-bounds vector-array array-nth ;

: set-vector-nth ( obj n vec -- )
    >r >fixnum dup assert-positive r>
    2dup ensure-capacity vector-array
    set-array-nth ;

: set-vector-length ( len vec -- )
    >r >fixnum dup assert-positive r>
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
        swap >r apply swap r> tuck vector-push
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

IN: kernel-internals

: dispatch ( n vtable -- )
    #! This word is unsafe since n is not bounds-checked. Do not
    #! call it directly.
    2 slot array-nth call ;
