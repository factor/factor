! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors new-slots sequences kernel assocs combinators
http.server http.server.validators http hashtables namespaces
combinators.cleave fry continuations ;
IN: http.server.actions

SYMBOL: +path+

SYMBOL: params

TUPLE: action init display submit get-params post-params ;

: <action>
    action construct-empty
        [ ] >>init
        [ <400> ] >>display
        [ <400> ] >>submit ;

: validate-param ( name validator assoc -- error? )
    swap pick
    >r >r at r> with-validator swap r> set ;

: action-params ( validators -- error? )
    [ params get validate-param ] { } assoc>map [ ] contains? ;

: handle-get ( -- response )
    action get get-params>> action-params [ <400> ] [
        action get [ init>> call ] [ display>> call ] bi
    ] if ;

: handle-post ( -- response )
    action get post-params>> action-params
    [ <400> ] [ action get submit>> call ] if ;

: validation-failed ( -- * )
    action get display>> call exit-with ;

M: action call-responder ( path action -- response )
    [ +path+ associate request-params union params set ]
    [ action set ] bi*
    request get method>> {
        { "GET" [ handle-get ] }
        { "HEAD" [ handle-get ] }
        { "POST" [ handle-post ] }
    } case ;
