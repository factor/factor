! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences kernel assocs combinators http.server
validators http hashtables namespaces fry continuations locals
boxes xml.entities html.elements html.components io arrays math ;
IN: http.server.actions

SYMBOL: params

SYMBOL: rest-param

: render-validation-messages ( -- )
    validation-messages get
    dup empty? [ drop ] [
        <ul "errors" =class ul>
            [ <li> message>> escape-string write </li> ] each
        </ul>
    ] if ;

TUPLE: action rest-param init display validate submit ;

: new-action ( class -- action )
    new
        [ ] >>init
        [ <400> ] >>display
        [ ] >>validate
        [ <400> ] >>submit ;

: <action> ( -- action )
    action new-action ;

: handle-get ( action -- response )
    blank-values
    [ init>> call ]
    [ display>> call ]
    bi ;

: validation-failed ( -- * )
    request get method>> "POST" =
    [ action get display>> call ] [ <400> ] if exit-with ;

: handle-post ( action -- response )
    init-validation
    blank-values
    [ validate>> call ]
    [ submit>> call ] bi ;

: handle-rest-param ( arg -- )
    dup length 1 > action get rest-param>> not or
    [ <404> exit-with ] [
        action get rest-param>> associate rest-param set
    ] if ;

M: action call-responder* ( path action -- response )
    dup action set
    '[
        , dup empty? [ drop ] [ handle-rest-param ] if

        init-validation
        ,
        request get
        [ request-params rest-param get assoc-union params set ]
        [ method>> ] bi
        {
            { "GET" [ handle-get ] }
            { "HEAD" [ handle-get ] }
            { "POST" [ handle-post ] }
        } case
    ] with-exit-continuation ;

: param ( name -- value )
    params get at ;

: check-validation ( -- )
    validation-failed? [ validation-failed ] when ;

: validate-params ( validators -- )
    params get swap validate-values from-assoc
    check-validation ;

: validate-integer-id ( -- )
    { { "id" [ v-number ] } } validate-params ;

TUPLE: page-action < action template ;

: <page-action> ( -- page )
    page-action new-action
        dup '[ , template>> <html-content> ] >>display ;

TUPLE: feed-action < action feed ;

: <feed-action> ( -- feed )
    feed-action new
        dup '[ , feed>> call <feed-content> ] >>display ;
