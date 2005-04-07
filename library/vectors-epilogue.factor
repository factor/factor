! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: errors generic kernel kernel-internals lists math
math-internals sequences ;

IN: vectors

: list>vector ( list -- vector )
    dup length <vector> swap [ over push ] each ;

: vector-map ( vector code -- vector )
    #! Applies code to each element of the vector, return a new
    #! vector with the results. The code must have stack effect
    #! ( obj -- obj ).
    >r >list r> map list>vector ; inline

: vector-append ( v1 v2 -- vec )
    over length over length + <vector>
    [ rot seq-append ] keep
    [ swap seq-append ] keep ;

: vector-project ( n quot -- vector )
    #! Execute the quotation n times, passing the loop counter
    #! the quotation as it ranges from 0..n-1. Collect results
    #! in a new vector.
    project list>vector ; inline

: vector-tail ( n vector -- list )
    #! Return a new list with all elements from the nth
    #! index upwards.
    2dup length swap - [
        pick + over nth
    ] project 2nip ;

: vector-tail* ( n vector -- list )
    #! Unlike vector-tail, n is an index from the end of the
    #! vector. For example, if n=1, this returns a vector of
    #! one element.
    [ length swap - ] keep vector-tail ;
