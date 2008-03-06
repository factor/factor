! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors new-slots sequences kernel assocs combinators
http.server http.server.validators http hashtables namespaces ;
IN: http.server.actions

SYMBOL: +path+

TUPLE: action get get-params post post-params revalidate ;

: <action>
    action construct-empty
    [ <400> ] >>get
    [ <400> ] >>post
    [ <400> ] >>revalidate ;

: extract-params ( request path -- assoc )
    >r dup method>> {
        { "GET" [ query>> ] }
        { "POST" [ post-data>> query>assoc ] }
    } case r> +path+ associate union ;

: action-params ( request path param -- error? )
    -rot extract-params validate-params ;

: get-action ( request path -- response )
    action get get-params>> action-params
    [ <400> ] [ action get get>> call ] if ;

: post-action ( request path -- response )
    action get post-params>> action-params
    [ action get revalidate>> ] [ action get post>> ] if call ;

M: action call-responder ( request path action -- response )
    action set
    over request set
    over method>>
    {
        { "GET" [ get-action ] }
        { "POST" [ post-action ] }
    } case ;
