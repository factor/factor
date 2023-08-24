! Copyright (C) 2017 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs deques dlists kernel linked-assocs
linked-assocs.private math sequences.private ;

IN: lru-cache

TUPLE: lru-cache < linked-assoc max-size ;

: <lru-cache> ( max-size exemplar -- assoc )
    dupd new-assoc <dlist> rot lru-cache boa ;

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

TUPLE: fifo-cache < linked-assoc max-size ;

: <fifo-cache> ( max-size exemplar -- assoc )
    dupd new-assoc <dlist> rot fifo-cache boa ;

: <fifo-hash> ( max-size -- assoc )
    H{ } <fifo-cache> ;

M: fifo-cache set-at
    [ call-next-method ] keep dup max-size>> [
        over assoc>> assoc-size < [
            [ dlist>> pop-front first-unsafe ]
            [ assoc>> ]
            [ dlist>> ] tri (delete-at)
        ] [ drop ] if
    ] [ drop ] if* ;

M: fifo-cache clone
    [ assoc>> clone ] [ dlist>> clone ] [ max-size>> ] tri
    fifo-cache boa ;

TUPLE: lifo-cache < linked-assoc max-size ;

: <lifo-cache> ( max-size exemplar -- assoc )
    dupd new-assoc <dlist> rot lifo-cache boa ;

: <lifo-hash> ( max-size -- assoc )
    H{ } <lifo-cache> ;

M: lifo-cache set-at
    dup max-size>> [
        over assoc>> assoc-size <= [
            dup
            [ dlist>> pop-back first-unsafe ]
            [ assoc>> ]
            [ dlist>> ] tri (delete-at)
        ] when
    ] when* call-next-method ;

M: lifo-cache clone
    [ assoc>> clone ] [ dlist>> clone ] [ max-size>> ] tri
    lifo-cache boa ;
