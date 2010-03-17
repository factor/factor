! Copyright (C) 2010 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables kernel vectors
math sequences ;
FROM: assocs => change-at ;
IN: sets

! Set protocol
MIXIN: set
GENERIC: adjoin ( elt set -- )
GENERIC: in? ( elt set -- ? )
GENERIC: delete ( elt set -- )
GENERIC: set-like ( set exemplar -- set' )
GENERIC: fast-set ( set -- set' )
GENERIC: members ( set -- seq )
GENERIC: union ( set1 set2 -- set )
GENERIC: intersect ( set1 set2 -- set )
GENERIC: intersects? ( set1 set2 -- ? )
GENERIC: diff ( set1 set2 -- set )
GENERIC: subset? ( set1 set2 -- ? )
GENERIC: set= ( set1 set2 -- ? )
GENERIC: duplicates ( set -- seq )
GENERIC: all-unique? ( set -- ? )

! Defaults for some methods.
! Override them for efficiency

M: set set-like drop ; inline

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

: (pruned) ( elt hash vec -- )
    3dup drop in? [ 3drop ] [
        [ drop adjoin ] [ nip push ] 3bi
    ] if ; inline

: pruned ( seq -- newseq )
    [ f fast-set ] [ length <vector> ] bi
    [ [ (pruned) ] 2curry each ] keep ;

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
    [ pruned ] keep like ;

M: sequence all-unique?
    dup pruned sequence= ;

: combine ( sets -- set )
    [ f ]
    [ [ [ members ] map concat ] [ first ] bi set-like ]
    if-empty ;

: gather ( seq quot -- newseq )
    map concat members ; inline

: adjoin-at ( value key assoc -- )
    [ [ f fast-set ] unless* [ adjoin ] keep ] change-at ;

: within ( seq set -- subseq )
    fast-set [ in? ] curry filter ;

: without ( seq set -- subseq )
    fast-set [ in? not ] curry filter ;

! Temporarily for compatibility

: unique ( seq -- assoc )
    [ dup ] H{ } map>assoc ;
: conjoin ( elt assoc -- )
    dupd set-at ;
: conjoin-at ( value key assoc -- )
    [ dupd ?set-at ] change-at ;
