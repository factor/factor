! Copyright (C) 2010 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel math sequences vectors ;
IN: sets

! Set protocol
MIXIN: set

GENERIC: adjoin ( elt set -- )
GENERIC: ?adjoin ( elt set -- ? )
GENERIC: in? ( elt set -- ? )
GENERIC: delete ( elt set -- )
GENERIC: ?delete ( elt set -- ? )
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
GENERIC: null? ( set -- ? )
GENERIC: cardinality ( set -- n )
GENERIC: clear-set ( set -- )

M: f members drop f ;

M: f cardinality drop 0 ;

M: f delete 2drop ;

M: f clear-set drop ; inline

! Defaults for some methods.
! Override them for efficiency

M: set ?adjoin 2dup in? [ 2drop f ] [ adjoin t ] if ;

M: set ?delete 2dup in? [ delete t ] [ 2drop f ] if ;

M: set null? cardinality 0 = ; inline

M: set cardinality members length ;

M: set clear-set [ members ] keep [ delete ] curry each ;

M: set set-like drop ; inline

<PRIVATE

: ?members ( set -- seq )
    dup sequence? [ members ] unless ; inline

: (union) ( set1 set2 -- seq )
    [ ?members ] bi@ append ; inline

PRIVATE>

M: set union [ (union) ] keep set-like ;

<PRIVATE

: tester ( set -- quot )
    fast-set [ in? ] curry ; inline

: sequence/tester ( set1 set2 -- set1' quot )
    [ members ] [ tester ] bi* ; inline

: small/large ( set1 set2 -- set1' set2' )
    2dup [ cardinality ] bi@ > [ swap ] when ; inline

: (intersect) ( set1 set2 -- seq )
    small/large sequence/tester filter ; inline

: (diff) ( set1 set2 -- seq )
    sequence/tester reject ; inline

PRIVATE>

M: set intersect [ (intersect) ] keep set-like ;

M: set diff [ (diff) ] keep set-like ;

M: set intersects?
    small/large sequence/tester any? ;

<PRIVATE

: (subset?) ( set1 set2 -- ? )
    sequence/tester all? ; inline

PRIVATE>

M: set subset?
    2dup [ cardinality ] bi@ > [ 2drop f ] [ (subset?) ] if ;

M: set set=
    2dup [ cardinality ] bi@ = [ (subset?) ] [ 2drop f ] if ;

M: set fast-set ;

M: set duplicates drop f ;

M: set all-unique? drop t ;

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
    f fast-set [ ?adjoin ] curry filter ;

M: sequence null?
    empty? ; inline

M: sequence cardinality
    fast-set cardinality ;

M: sequence clear-set
    delete-all ; inline

: combine ( sets -- set/f )
    [ f ]
    [ [ [ ?members ] map concat ] [ first ] bi set-like ]
    if-empty ;

: intersection ( sets -- set/f )
    [ f ] [ [ ] [ intersect ] map-reduce ] if-empty ;

: refine ( sets -- set/f )
    [ f ] [ [ ] [ intersect ] map-reduce ] if-empty ;

: gather ( ... seq quot: ( ... elt -- ... elt' ) -- ... newseq )
    map concat members ; inline

: adjoin-at ( value key assoc -- )
    [ [ f fast-set ] unless* [ adjoin ] keep ] change-at ;

: within ( seq set -- subseq )
    tester filter ;

: without ( seq set -- subseq )
    tester reject ;

: adjoin-all ( seq set -- )
    [ adjoin ] curry each ;

: union! ( set1 set2 -- set1 )
    ?members over adjoin-all ;

: diff! ( set1 set2 -- set1 )
    dupd sequence/tester [ dup ] prepose pick
    [ delete ] curry [ [ drop ] if ] curry compose each ;

: intersect! ( set1 set2 -- set1 )
    dupd sequence/tester [ dup ] prepose [ not ] compose pick
    [ delete ] curry [ [ drop ] if ] curry compose each ;
