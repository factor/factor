! Copyright (C) 2017 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs deques dlists fry kernel linked-assocs
linked-assocs.private math sequences.private ;

IN: lru-cache

TUPLE: lru-cache < linked-assoc max-size ;

: <lru-cache> ( max-size exemplar -- assoc )
    0 swap new-assoc <dlist> rot lru-cache boa ;

: <lru-hash> ( max-size -- assoc )
    H{ } <lru-cache> ;

M: lru-cache at*
    [ assoc>> at* ] [ dlist>> dup ] bi '[
        [
            [ _ delete-node ]
            [ _ push-node-back ]
            [ obj>> second-unsafe ] tri
        ] when
    ] keep ;

M: lru-cache set-at
    [ call-next-method ] keep dup max-size>> [
        over assoc>> assoc-size < [
            [ dlist>> pop-front first-unsafe ]
            [ assoc>> ]
            [ dlist>> ] tri (delete-at)
        ] [ drop ] if
    ] [ drop ] if* ;

M: lru-cache clone
    [ assoc>> clone ] [ dlist>> clone ] [ max-size>> ] tri
    lru-cache boa ;
