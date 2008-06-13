! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences kernel assocs combinators
validators http hashtables namespaces fry continuations locals
io arrays math boxes splitting urls
xml.entities
http.server
http.server.responses
furnace
furnace.flash
html.elements
html.components
html.components
html.templates.chloe
html.templates.chloe.syntax ;
IN: furnace.actions

SYMBOL: params

SYMBOL: rest

: render-validation-messages ( -- )
    validation-messages get
    dup empty? [ drop ] [
        <ul "errors" =class ul>
            [ <li> message>> escape-string write </li> ] each
        </ul>
    ] if ;

CHLOE: validation-messages drop render-validation-messages ;

TUPLE: action rest authorize init display validate submit ;

: new-action ( class -- action )
    new [ ] >>init [ ] >>validate [ ] >>authorize ; inline

: <action> ( -- action )
    action new-action ;

: flashed-variables ( -- seq )
    { validation-messages named-validation-messages } ;

: handle-get ( action -- response )
    '[
        , dup display>> [
            {
                [ init>> call ]
                [ authorize>> call ]
                [ drop flashed-variables restore-flash ]
                [ display>> call ]
            } cleave
        ] [ drop <400> ] if
    ] with-exit-continuation ;

: validation-failed ( -- * )
    request get method>> "POST" = [ f ] [ <400> ] if exit-with ;

: (handle-post) ( action -- response )
    '[
        , dup submit>> [
            [ validate>> call ]
            [ authorize>> call ]
            [ submit>> call ]
            tri
        ] [ drop <400> ] if
    ] with-exit-continuation ;

: param ( name -- value )
    params get at ;

: revalidate-url-key "__u" ;

: check-url ( url -- ? )
    request get url>>
    [ [ protocol>> ] [ host>> ] [ port>> ] tri 3array ] bi@ = ;

: revalidate-url ( -- url/f )
    revalidate-url-key param dup [ >url dup check-url swap and ] when ;

: handle-post ( action -- response )
    '[
        form-nesting-key params get at " " split
        [ , (handle-post) ]
        [ swap '[ , , nest-values ] ] reduce
        call
    ] with-exit-continuation
    [
        revalidate-url
        [ flashed-variables <flash-redirect> ] [ <403> ] if*
    ] unless* ;

: handle-rest ( path action -- assoc )
    rest>> dup [ [ "/" join ] dip associate ] [ 2drop f ] if ;

: init-action ( path action -- )
    blank-values
    init-validation
    handle-rest
    request get request-params assoc-union params set ;

M: action call-responder* ( path action -- response )
    [ init-action ] keep
    request get method>> {
        { "GET" [ handle-get ] }
        { "HEAD" [ handle-get ] }
        { "POST" [ handle-post ] }
    } case ;

M: action modify-form
    drop request get url>> revalidate-url-key hidden-form-field ;

: check-validation ( -- )
    validation-failed? [ validation-failed ] when ;

: validate-params ( validators -- )
    params get swap validate-values from-object
    check-validation ;

: validate-integer-id ( -- )
    { { "id" [ v-number ] } } validate-params ;

TUPLE: page-action < action template ;

: <chloe-content> ( path -- response )
    resolve-template-path <chloe> "text/html" <content> ;

: <page-action> ( -- page )
    page-action new-action
        dup '[ , template>> <chloe-content> ] >>display ;
