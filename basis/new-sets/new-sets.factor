! Copyright (C) 2010 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables kernel
math sequences parser prettyprint.custom ;
FROM: sets => prune ;
IN: new-sets
! The vocab is called new-sets for now, but only until it gets into core
! All the code here is in the style that could be put in core

! Set protocol
MIXIN: set
GENERIC: adjoin ( elt set -- )
GENERIC: in? ( elt set -- ? )
GENERIC: delete ( elt set -- )
GENERIC: set-like ( set exemplar -- set' )
GENERIC: fast-set ( set -- set' )
GENERIC: members ( set -- sequence )
GENERIC: union ( set1 set2 -- set )
GENERIC: intersect ( set1 set2 -- set )
GENERIC: intersects? ( set1 set2 -- ? )
GENERIC: diff ( set1 set2 -- set )
GENERIC: subset? ( set1 set2 -- ? )
GENERIC: set= ( set1 set2 -- ? )

! Defaults for some methods.
! Override them for efficiency

M: set union
    [ [ members ] bi@ append ] keep set-like ;

<PRIVATE

: sequence/tester ( set1 set2 -- set1' quot )
    [ members ] [ fast-set [ in? ] curry ] bi* ; inline

PRIVATE>

M: set intersect
    [ sequence/tester filter ] keep set-like ;

M: set diff
    [ sequence/tester [ not ] compose filter ] keep set-like ;

M: set intersects?
    sequence/tester any? ;

M: set subset?
    sequence/tester all? ;
    
M: set set=
    2dup subset? [ swap subset? ] [ 2drop f ] if ;

M: set fast-set ;

! Sequences are sets
INSTANCE: sequence set
M: sequence in? member? ; inline
M: sequence adjoin [ delete ] [ push ] 2bi ;
M: sequence delete remove! drop ; inline
M: sequence set-like
    [ dup sequence? [ prune ] [ members ] if ] dip like ;
M: sequence members fast-set members ;

USE: vocabs.loader
"hash-sets" require

: combine ( sets -- set )
    f [ union ] reduce ;
