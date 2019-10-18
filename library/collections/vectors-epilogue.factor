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

: zero-vector ( n -- vector )
    0 <repeated> >vector ;

M: general-list thaw >vector ;

M: general-list like drop >list ;

M: vector like drop >vector ;
