! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: graphs
USING: hashtables kernel namespaces sequences ;

: if-graph over [ bind ] [ 2drop 2drop ] if ; inline

: (add-vertex) ( vertex edges -- | edges: vertex -- seq )
    dupd call [ dupd nest set-hash ] each-with ; inline

: add-vertex ( vertex edges graph -- | edges: vertex -- seq )
    [ (add-vertex) ] if-graph ; inline

: build-graph ( seq edges graph -- | edges: vertex -- seq )
    [
        namespace clear-hash
        swap [ swap (add-vertex) ] each-with
    ] if-graph ;

: (remove-vertex) ( vertex graph -- ) nest remove-hash ;

: remove-vertex ( vertex edges graph -- )
    [
        dupd call [ namespace hash ?remove-hash ] each-with
    ] if-graph ; inline

: in-edges ( vertex graph -- seq )
    ?hash dup [ hash-keys ] when ;

SYMBOL: previous

: (closure) ( obj quot -- )
    over previous get hash-member? [
        2drop
    ] [
        over dup previous get set-hash
        [ call ] keep swap [ swap (closure) ] each-with
    ] if ; inline

: closure ( obj quot -- seq | quot: obj -- seq )
    [
        H{ } clone previous set
        (closure)
        previous get hash-keys
    ] with-scope ; inline
