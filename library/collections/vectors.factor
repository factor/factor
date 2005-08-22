! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: vectors
USING: errors generic kernel kernel-internals lists math
math-internals sequences ;

M: vector set-length ( len vec -- ) grow-length ;

M: vector nth ( n vec -- obj ) bounds-check underlying array-nth ;

M: vector set-nth ( obj n vec -- )
    growable-check 2dup ensure underlying set-array-nth ;

M: vector hashcode ( vec -- n )
    dup length 0 number= [ drop 0 ] [ first hashcode ] ifte ;

: empty-vector ( len -- vec )
    dup <vector> [ set-length ] keep ; inline

: >vector ( list -- vector )
    dup length <vector> [ swap nappend ] keep ; inline

M: object thaw >vector ;

M: vector clone ( vector -- vector ) >vector ;

M: general-list like drop >list ;

M: vector like drop >vector ;

: (1vector) [ push ] keep ; inline
: (2vector) [ swapd push ] keep (1vector) ; inline
: (3vector) [ >r rot r> push ] keep (2vector) ; inline

: 1vector ( x -- { x } ) 1 <vector> (1vector) ; flushable
: 2vector ( x y -- { x y } ) 2 <vector> (2vector) ; flushable
: 3vector ( x y z -- { x y z } ) 3 <vector> (3vector) ; flushable
