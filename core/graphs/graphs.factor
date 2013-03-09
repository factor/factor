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

: (closure) ( obj set quot: ( elt -- seq ) -- )
    2over ?adjoin [
        [ dip ] keep [ (closure) ] 2curry each
    ] [ 3drop ] if ; inline recursive

PRIVATE>

: closure ( obj quot -- set )
    HS{ } clone [ swap (closure) ] keep ; inline
