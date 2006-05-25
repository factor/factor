! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: graphs
USING: hashtables kernel namespaces sequences ;

: if-graph over [ bind ] [ 2drop 2drop ] if ; inline

: (add-vertex) ( vertex edges -- | edges: vertex -- seq )
    dupd call [ dupd nest set-hash ] each-with ; inline

: add-vertex ( vertex edges graph -- | edges: vertex -- seq )
    [ (add-vertex) ] if-graph ; inline

: add-vertices ( seq edges graph -- | edges: vertex -- seq )
    [
        namespace clear-hash
        swap [ swap (add-vertex) ] each-with
    ] if-graph ;

: (remove-vertex) ( vertex graph -- ) nest remove-hash ;

: remove-vertex ( vertex edges graph -- )
    [ dupd call [ nest remove-hash ] each-with ] if-graph ;
    inline

: in-edges ( vertex graph -- seq )
    ?hash dup [ hash-keys ] when ;

SYMBOL: hash-buffer

: closure, ( value key -- old )
    hash-buffer get [ hash swap ] 2keep set-hash ;

: (closure) ( key hash -- )
    tuck ?hash dup [
        [
            drop dup dup closure,
            [ 2drop ] [ swap (closure) ] if
        ] hash-each-with
    ] [
        2drop
    ] if ;

: closure ( vertex graph -- seq )
    [
        H{ } clone hash-buffer set
        (closure)
        hash-buffer get hash-keys
    ] with-scope ;
