! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences kernel assocs combinators
http.server http.server.validators http hashtables namespaces
fry continuations locals ;
IN: http.server.actions

SYMBOL: +path+

SYMBOL: params

TUPLE: action init display submit get-params post-params ;

: <action>
    action new
        [ ] >>init
        [ <400> ] >>display
        [ <400> ] >>submit ;

:: validate-param ( name validator assoc -- )
    name assoc at validator with-validator name set ; inline

: action-params ( validators -- error? )
    validation-failed? off
    params get '[ , validate-param ] assoc-each
    validation-failed? get ;

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
    '[
        , [ CHAR: / = ] right-trim empty? [
            , action set
            request-params params set
            request get method>> {
                { "GET" [ handle-get ] }
                { "HEAD" [ handle-get ] }
                { "POST" [ handle-post ] }
            } case
        ] [
            <404>
        ] if
    ] with-exit-continuation ;
