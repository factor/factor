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

: closure, ( value key -- old )
    building get [ hash swap ] 2keep set-hash ;

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
        H{ } clone building set
        (closure)
        building get hash-keys
    ] with-scope ;
