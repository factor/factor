! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: vectors
USING: errors generic kernel kernel-internals lists math
math-internals sequences sequences-internals ;

M: vector set-length ( len vec -- ) grow-length ;

M: vector nth-unsafe ( n vec -- obj ) underlying array-nth ;

M: vector nth ( n vec -- obj ) bounds-check nth-unsafe ;

M: vector set-nth-unsafe ( obj n vec -- )
    underlying set-array-nth ;

M: vector set-nth ( obj n vec -- )
    growable-check 2dup ensure set-nth-unsafe ;

M: vector hashcode ( vec -- n )
    dup length 0 number= [ drop 0 ] [ first hashcode ] ifte ;

: >vector ( list -- vector )
    dup length <vector> [ swap nappend ] keep ; inline

M: object thaw >vector ;

M: vector clone ( vector -- vector ) clone-growable ;

M: general-list like drop >list ;

M: vector like drop dup vector? [ >vector ] unless ;

: 1vector ( x -- { x } )
    1 empty-vector [ 0 swap set-nth ] keep ; flushable

: 2vector ( x y -- { x y } )
    2 empty-vector
    [ 1 swap set-nth ] keep
    [ 0 swap set-nth ] keep ; flushable

: 3vector ( x y z -- { x y z } )
    3 empty-vector
    [ 2 swap set-nth ] keep
    [ 1 swap set-nth ] keep
    [ 0 swap set-nth ] keep ; flushable
