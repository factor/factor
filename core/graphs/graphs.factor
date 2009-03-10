! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces sequences sets ;
IN: graphs

SYMBOL: graph

: if-graph ( vertex edges graph quot -- )
    over
    [ graph swap with-variable ]
    [ 2drop 2drop ] if ; inline

: nest ( key -- hash )
    graph get [ drop H{ } clone ] cache ;

: add-vertex ( vertex edges graph -- )
    [ [ dupd nest set-at ] with each ] if-graph ; inline

: (add-vertex) ( key value vertex -- )
    rot nest set-at ;

: add-vertex* ( vertex edges graph -- )
    [
        swap [ (add-vertex) ] curry assoc-each
    ] if-graph ; inline

: remove-vertex ( vertex edges graph -- )
    [ [ graph get at delete-at ] with each ] if-graph ; inline

: (remove-vertex) ( key value vertex -- )
    rot graph get at delete-at drop ;

: remove-vertex* ( vertex edges graph -- )
    [
        swap [ (remove-vertex) ] curry assoc-each
    ] if-graph ; inline

SYMBOL: previous

: (closure) ( obj quot: ( elt -- assoc ) -- )
    over previous get key? [
        2drop
    ] [
        over previous get conjoin
        [ call ] keep
        [ nip (closure) ] curry assoc-each
    ] if ; inline recursive

: closure ( obj quot -- assoc )
    H{ } clone [
        previous [ (closure) ] with-variable
    ] keep ; inline
