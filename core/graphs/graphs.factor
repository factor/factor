! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
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

PRIVATE>

: closure ( vertex quot: ( vertex -- edges ) -- set )
    HS{ } clone [ swap (closure) ] keep ; inline
