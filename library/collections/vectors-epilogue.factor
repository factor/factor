! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: errors generic kernel kernel-internals lists math
math-internals sequences ;

IN: vectors

: empty-vector ( len -- vec )
    #! Creates a vector with 'len' elements set to f. Unlike
    #! <vector>, which gives an empty vector with a certain
    #! capacity.
    dup <vector> [ set-length ] keep ;

: >vector ( list -- vector )
    dup length <vector> [ swap nappend ] keep ;

M: vector clone ( vector -- vector )
    >vector ;

: vector-project ( n quot -- vector )
    #! Execute the quotation n times, passing the loop counter
    #! the quotation as it ranges from 0..n-1. Collect results
    #! in a new vector.
    >r 0 swap <range> >vector r> map ; inline

: zero-vector ( n -- vector )
    [ drop 0 ] vector-project ;

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

M: general-list thaw >vector ;
M: general-list freeze drop >list ;
