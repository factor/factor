! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors new-slots sequences kernel assocs combinators
http.server http hashtables namespaces ;
IN: http.server.actions

SYMBOL: +path+

TUPLE: action quot params method ;

C: <action> action

: extract-params ( request path -- assoc )
    >r dup method>> {
        { "GET" [ query>> ] }
        { "POST" [ post-data>> query>assoc ] }
    } case r> +path+ associate union ;

: push-params ( assoc action -- ... )
    params>> [ first2 >r swap at r> call ] with each ;

M: action call-responder ( request path action -- response )
    pick request set
    pick method>> over method>> = [
        >r extract-params r>
        [ push-params ] keep
        quot>> call
    ] [
        3drop <400>
    ] if ;
