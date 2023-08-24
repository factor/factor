! Copyright (C) 2006, 2007 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs kernel sequences sets ;
IN: graphs

<PRIVATE

: nest ( vertex graph -- edges )
    [ drop HS{ } clone ] cache ; inline

PRIVATE>

: add-vertex ( vertex edges graph -- )
    [ nest adjoin ] curry with each ; inline

: remove-vertex ( vertex edges graph -- )
    [ at delete ] curry with each ; inline

<PRIVATE

: (closure) ( vertex set quot: ( vertex -- edges ) -- )
    2over ?adjoin [
        [ dip ] keep [ (closure) ] 2curry each
    ] [ 3drop ] if ; inline recursive

: new-empty-set-like ( exemplar -- set )
    f swap set-like clone ; inline

PRIVATE>

: closure-as ( vertex quot: ( vertex -- edges ) exemplar -- set )
    new-empty-set-like [ swap (closure) ] keep ; inline

: closure ( vertex quot: ( vertex -- edges ) -- set )
    HS{ } closure-as ; inline
