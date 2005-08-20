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
