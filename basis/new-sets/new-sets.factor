! Copyright (C) 2010 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables kernel
math sequences parser prettyprint.custom ;
QUALIFIED: sets
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

! Hash sets
! In a better implementation, less memory would be used
TUPLE: hash-set { table hashtable read-only } ;

: <hash-set> ( members -- hash-set )
    sets:unique hash-set boa ;

INSTANCE: hash-set set
M: hash-set in? table>> key? ; inline
M: hash-set adjoin table>> dupd set-at ; inline
M: hash-set delete table>> delete-at ; inline
M: hash-set members table>> keys ; inline
M: hash-set set-like
    drop dup hash-set? [ members <hash-set> ] unless ;
M: hash-set clone
    table>> clone hash-set boa ;

SYNTAX: HS{
    \ } [ <hash-set> ] parse-literal ;

M: hash-set pprint* pprint-object ;
M: hash-set pprint-delims drop \ HS{ \ } ;
M: hash-set >pprint-sequence members ;

! Sequences are sets
INSTANCE: sequence set
M: sequence in? member? ; inline
M: sequence adjoin sets:adjoin ; inline
M: sequence delete remove! drop ; inline
M: sequence set-like
    [ dup sequence? [ sets:prune ] [ members ] if ] dip
    like ;
M: sequence members ;
M: sequence fast-set <hash-set> ;
