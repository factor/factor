! Copyright (C) 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math sequences sequences.private ;
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

M: 1modified length seq>> length ;
M: 1modified set-length seq>> set-length ;
M: 1modified virtual-exemplar seq>> ;

TUPLE: scaled < 1modified c ;

C: <scaled> scaled

: scale ( seq c -- new-seq )
    dupd <scaled> swap like ;

M: scaled modified-nth
    [ seq>> nth ] [ c>> * ] bi ;

M: scaled modified-set-nth
    ! don't set c to 0!
    [ nip c>> / ] [ seq>> set-nth ] 2bi ;

TUPLE: offset < 1modified n ;

C: <offset> offset

: seq-offset ( seq n -- new-seq )
    dupd <offset> swap like ;

M: offset modified-nth
    [ seq>> nth ] [ n>> + ] bi ;

M: offset modified-set-nth
    [ nip n>> - ] [ seq>> set-nth ] 2bi ;

TUPLE: summed < modified seqs ;

C: <summed> summed

M: summed length seqs>> longest length ;

M: summed modified-nth
    seqs>> [ ?nth [ + ] when* ] with 0 swap reduce ;

M: summed modified-set-nth immutable ;

M: summed set-length
    seqs>> [ set-length ] with each ;

M: summed virtual-exemplar
    seqs>> ?first ;

: <2summed> ( seq seq -- summed-seq ) 2array <summed> ;

: <3summed> ( seq seq seq -- summed-seq ) 3array <summed> ;
