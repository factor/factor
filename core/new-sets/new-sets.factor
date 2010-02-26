! Copyright (C) 2010 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables kernel vectors
math sequences ;
IN: new-sets

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
GENERIC: duplicates ( set -- sequence )
GENERIC: all-unique? ( set -- ? )

! Defaults for some methods.
! Override them for efficiency

M: set union
    [ [ members ] bi@ append ] keep set-like ;

<PRIVATE

: tester ( set -- quot )
    fast-set [ in? ] curry ; inline

: sequence/tester ( set1 set2 -- set1' quot )
    [ members ] [ tester ] bi* ; inline

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

M: set duplicates drop f ;

M: set all-unique? drop t ;

<PRIVATE

: (prune) ( elt hash vec -- )
    3dup drop key? [ 3drop ] [
        [ drop dupd set-at ] [ nip push ] 3bi
    ] if ; inline

: prune ( seq -- newseq )
    [ ] [ length <hashtable> ] [ length <vector> ] tri
    [ [ (prune) ] 2curry each ] keep ;

PRIVATE>

! Sequences are sets
INSTANCE: sequence set

M: sequence in?
    member? ; inline

M: sequence adjoin
    [ delete ] [ push ] 2bi ;

M: sequence delete
    remove! drop ; inline

M: sequence set-like
    [ members ] dip like ;

M: sequence members
    [ prune ] keep like ;

M: sequence all-unique?
    dup prune sequence= ;

! Some sequence methods are defined using hash-sets
USE: vocabs.loader
"hash-sets" require

: combine ( sets -- set )
    f [ union ] reduce ;
