! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel locals math math.order
sequences sequences.private shuffle ;
IN: sequences.modified

TUPLE: modified ;

GENERIC: modified-nth ( n seq -- elt )
M: modified nth modified-nth ;
M: modified nth-unsafe modified-nth ;

GENERIC: modified-set-nth ( elt n seq -- )
M: modified set-nth modified-set-nth ;
M: modified set-nth-unsafe modified-set-nth ;

INSTANCE: modified virtual-sequence

TUPLE: 1modified < modified seq ;

M: modified length seq>> length ;
M: modified set-length seq>> set-length ;

M: 1modified virtual-exemplar seq>> ;

TUPLE: scaled < 1modified c ;
C: <scaled> scaled

: scale ( seq c -- new-seq )
    dupd <scaled> swap like ;

M: scaled modified-nth ( n seq -- elt )
    [ seq>> nth ] [ c>> * ] bi ;

M:: scaled modified-set-nth ( elt n seq -- )
    ! don't set c to 0!
    elt seq c>> / n seq seq>> set-nth ;

TUPLE: offset < 1modified n ;
C: <offset> offset

: seq-offset ( seq n -- new-seq )
    dupd <offset> swap like ;

M: offset modified-nth ( n seq -- elt )
    [ seq>> nth ] [ n>> + ] bi ;

M:: offset modified-set-nth ( elt n seq -- )
    elt seq n>> - n seq seq>> set-nth ;

TUPLE: summed < modified seqs ;
C: <summed> summed

M: summed length seqs>> longest length ;

<PRIVATE
: ?+ ( x/f y/f -- sum )
    #! addition that treats f as 0
    [
        swap [ + ] when*
    ] [
        [ ] [ 0 ] if*
    ] if* ;
PRIVATE>

M: summed modified-nth ( n seq -- elt )
    seqs>> [ ?nth ?+ ] with 0 swap reduce ;

M: summed modified-set-nth ( elt n seq -- ) immutable ;

M: summed set-length ( n seq -- )
    seqs>> [ set-length ] with each ;

M: summed virtual-exemplar ( summed -- seq )
    seqs>> ?first ;

: <2summed> ( seq seq -- summed-seq ) 2array <summed> ;
: <3summed> ( seq seq seq -- summed-seq ) 3array <summed> ;
