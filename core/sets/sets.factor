! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel sequences vectors ;
IN: sets

: adjoin ( elt seq -- ) [ delete ] [ push ] 2bi ;

: conjoin ( elt assoc -- ) dupd set-at ;

: (prune) ( elt hash vec -- )
    3dup drop key? [ 3drop ] [
        [ drop conjoin ] [ nip push ] 3bi
    ] if ; inline

: prune ( seq -- newseq )
    [ ] [ length <hashtable> ] [ length <vector> ] tri
    [ [ (prune) ] 2curry each ] keep ;

: unique ( seq -- assoc )
    [ dup ] H{ } map>assoc ;

: (all-unique?) ( elt hash -- ? )
    2dup key? [ 2drop f ] [ conjoin t ] if ;

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
