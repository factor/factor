! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces sequences ;
IN: graphs

SYMBOL: graph

: if-graph ( vertex edges graph quot -- )
    over
    [ graph swap with-variable ]
    [ 2drop 2drop ] if ; inline

: nest ( key -- hash )
    graph get [ drop H{ } clone ] cache ;

: add-vertex ( vertex edges graph -- )
    [ [ dupd nest set-at ] curry* each ] if-graph ; inline

: remove-vertex ( vertex edges graph -- )
    [ [ graph get at delete-at ] curry* each ] if-graph ; inline

SYMBOL: previous

: (closure) ( obj quot -- )
    over previous get key? [
        2drop
    ] [
        over dup previous get set-at
        dup slip
        [ nip (closure) ] curry assoc-each
    ] if ; inline

: closure ( obj quot -- assoc )
    H{ } clone [
        previous [ (closure) ] with-variable
    ] keep ; inline
