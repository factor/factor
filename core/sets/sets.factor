! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel sequences vectors ;
IN: sets

: (prune) ( elt hash vec -- )
    3dup drop key?
    [ [ drop dupd set-at ] [ nip push ] [ ] 3tri ] unless
    3drop ; inline

: prune ( seq -- newseq )
    [ ] [ length <hashtable> ] [ length <vector> ] tri
    [ [ (prune) ] 2curry each ] keep ;

: unique ( seq -- assoc )
    [ dup ] H{ } map>assoc ;

: (all-unique?) ( elt hash -- ? )
    2dup key? [ 2drop f ] [ dupd set-at t ] if ;

: all-unique? ( seq -- ? )
    dup length <hashtable> [ (all-unique?) ] curry all? ;

: intersect ( seq1 seq2 -- newseq )
    unique [ key? ] curry filter ;

: diff ( seq1 seq2 -- newseq )
    unique [ key? not ] curry filter ;

: union ( seq1 seq2 -- newseq )
    append prune ;

: subset? ( seq1 seq2 -- ? )
    unique [ key? ] curry all? ;

: set= ( seq1 seq2 -- ? )
    [ unique ] bi@ = ;
