! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: graphs
USING: assocs hashtables kernel namespaces sequences ;

: if-graph over [ bind ] [ 2drop 2drop ] if ; inline

: nest ( key -- hash ) namespace [ drop H{ } clone ] cache ;

: (add-vertex) ( vertex edges -- )
    dupd call [ dupd nest set-at ] each-with ; inline

: add-vertex ( vertex edges graph -- )
    [ (add-vertex) ] if-graph ; inline

: build-graph ( seq edges graph -- )
    [
        namespace clear-assoc
        swap [ swap (add-vertex) ] each-with
    ] if-graph ;

: (remove-vertex) ( vertex graph -- ) nest delete-at ;

: remove-vertex ( vertex edges graph -- )
    [
        dupd call [ namespace at delete-at ] each-with
    ] if-graph ; inline

: in-edges ( vertex graph -- seq )
    at dup [ keys ] when ;

SYMBOL: previous

: (closure) ( obj quot -- )
    over previous get key? [
        2drop
    ] [
        over dup previous get set-at
        [ call ] keep swap [ swap (closure) ] each-with
    ] if ; inline

: closure ( obj quot -- seq )
    [
        H{ } clone previous set
        (closure)
        previous get keys
    ] with-scope ; inline
