! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel sequences vectors ;
IN: sets

: adjoin ( elt seq -- ) [ remove! drop ] [ push ] 2bi ;

: conjoin ( elt assoc -- ) dupd set-at ;

: conjoin-at ( value key assoc -- )
    [ dupd ?set-at ] change-at ;

: (prune) ( elt hash vec -- )
    3dup drop key? [ 3drop ] [
        [ drop conjoin ] [ nip push ] 3bi
    ] if ; inline

: prune ( seq -- newseq )
    [ ] [ length <hashtable> ] [ length <vector> ] tri
    [ [ (prune) ] 2curry each ] keep ;

: duplicates ( seq -- newseq )
    H{ } clone [ [ key? ] [ conjoin ] 2bi ] curry filter ;

: gather ( seq quot -- newseq )
    map concat prune ; inline

: unique ( seq -- assoc )
    [ dup ] H{ } map>assoc ;

: (all-unique?) ( elt hash -- ? )
    2dup key? [ 2drop f ] [ conjoin t ] if ;

: all-unique? ( seq -- ? )
    dup length <hashtable> [ (all-unique?) ] curry all? ;

<PRIVATE

: tester ( seq -- quot ) unique [ key? ] curry ; inline

PRIVATE>

: intersect ( seq1 seq2 -- newseq )
    tester filter ;

: intersects? ( seq1 seq2 -- ? )
    tester any? ;

: diff ( seq1 seq2 -- newseq )
    tester [ not ] compose filter ;

: union ( seq1 seq2 -- newseq )
    append prune ;

: subset? ( seq1 seq2 -- ? )
    tester all? ;

: set= ( seq1 seq2 -- ? )
    [ unique ] bi@ = ;
