! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel sequences sets ;
IN: graphs

<PRIVATE

: if-graph ( vertex edges graph quot -- )
    dupd [ 3drop ] if ; inline

: nest ( key graph -- hash )
    [ drop H{ } clone ] cache ; inline

PRIVATE>

: add-vertex ( vertex edges graph -- )
    [ [ nest dupd set-at ] curry with each ] if-graph ; inline

: add-vertex* ( vertex edges graph -- )
    [
        swapd [ [ rot ] dip nest set-at ] 2curry assoc-each
    ] if-graph ; inline

: remove-vertex ( vertex edges graph -- )
    [ [ at delete-at ] curry with each ] if-graph ; inline

: remove-vertex* ( vertex edges graph -- )
    [
        swapd [ [ rot ] dip at delete-at drop ] 2curry assoc-each
    ] if-graph ; inline

<PRIVATE

: (closure) ( obj assoc quot: ( elt -- assoc ) -- )
    2over key? [
        3drop
    ] [
        2over conjoin [ dip ] keep
        [ [ drop ] 3dip (closure) ] 2curry assoc-each
    ] if ; inline recursive

PRIVATE>

: closure ( obj quot -- assoc )
    H{ } clone [ swap (closure) ] keep ; inline
