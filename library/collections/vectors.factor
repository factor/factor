! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: errors generic kernel kernel-internals lists math
math-internals sequences ;

IN: kernel-internals
DEFER: set-vector-length
DEFER: vector-array
DEFER: set-vector-array

: assert-positive ( fx -- )
    0 fixnum<
    [ "Vector index must be positive" throw ] when ; inline

: assert-bounds ( fx seq -- )
    over assert-positive
    length fixnum>=
    [ "Vector index out of bounds" throw ] when ; inline

IN: vectors

BUILTIN: vector 11
    [ 1 length set-vector-length ]
    [ 2 vector-array set-vector-array ] ;

: empty-vector ( len -- vec )
    #! Creates a vector with 'len' elements set to f. Unlike
    #! <vector>, which gives an empty vector with a certain
    #! capacity.
    dup <vector> [ set-length ] keep ;

IN: kernel-internals

: grow-capacity ( len vec -- )
    #! If the vector cannot accomodate len elements, resize it
    #! to exactly len.
    [ vector-array grow-array ] keep set-vector-array ;

M: vector ensure-capacity ( n vec -- )
    #! If n is beyond the vector's length, increase the length,
    #! growing the array if necessary, with an optimistic
    #! doubling of its size.
    2dup length fixnum>= [
        >r 1 fixnum+ r>
        2dup vector-array length fixnum> [
            over 2 fixnum* over grow-capacity
        ] when
        set-vector-length
    ] [
        2drop
    ] ifte ;

M: vector hashcode ( vec -- n )
    dup length 0 number= [
        drop 0
    ] [
        0 swap nth hashcode
    ] ifte ;

M: vector set-length ( len vec -- )
    >r >fixnum dup assert-positive r>
    2dup grow-capacity set-vector-length ;

M: vector nth ( n vec -- obj )
    >r >fixnum r> 2dup assert-bounds vector-array array-nth ;

M: vector set-nth ( obj n vec -- )
    >r >fixnum dup assert-positive r>
    2dup ensure-capacity vector-array
    set-array-nth ;

: copy-array ( to from n -- )
    [ 3dup swap array-nth pick rot set-array-nth ] repeat 2drop ;

M: vector clone ( vector -- vector )
    dup length dup empty-vector [
        vector-array rot vector-array rot copy-array
    ] keep ;

IN: vectors

: vector-length ( deprecated ) length ;
: vector-nth ( deprecated ) nth ;
: set-vector-nth ( deprecated ) set-nth ;
