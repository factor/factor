! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences kernel assocs combinators
validators http hashtables namespaces fry continuations locals
io arrays math boxes splitting urls
xml.entities
http.server
http.server.responses
furnace.utilities
furnace.redirection
furnace.conversations
furnace.chloe-tags
html.forms
html.components
html.templates.chloe
html.templates.chloe.syntax
html.templates.chloe.compiler ;
IN: furnace.actions

SYMBOL: rest

TUPLE: action rest init authorize display validate submit ;

: new-action ( class -- action )
    new [ ] >>init [ ] >>validate [ ] >>authorize ; inline

: <action> ( -- action )
    action new-action ;

: merge-forms ( form -- )
    [ form get ] dip
    [ [ errors>> ] bi@ append! drop ]
    [ [ values>> ] bi@ assoc-union! drop ]
    [ validation-failed>> >>validation-failed drop ]
    2tri ;

: set-nested-form ( form name -- )
    [
        merge-forms
    ] [
        unclip [ set-nested-form ] nest-form
    ] if-empty ;

: restore-validation-errors ( -- )
    form cget [
        nested-forms cget set-nested-form
    ] when* ;

: handle-get ( action -- response )
    '[
        _ dup display>> [
            {
                [ init>> call( -- ) ]
                [ authorize>> call( -- ) ]
                [ drop restore-validation-errors ]
                [ display>> call( -- response ) ]
            } cleave
        ] [ drop <400> ] if
    ] with-exit-continuation ;

CONSTANT: revalidate-url-key "__u"

: revalidate-url ( -- url/f )
    revalidate-url-key param
    dup [ >url ensure-port [ same-host? ] keep and ] when ;

: validation-failed ( -- * )
    post-request? revalidate-url and [
        begin-conversation
        nested-forms-key param " " split harvest nested-forms cset
        form get form cset
        <continue-conversation>
    ] [ <400> ] if*
    exit-with ;

: handle-post ( action -- response )
    '[
        _ dup submit>> [
            [ validate>> call( -- ) ]
            [ authorize>> call( -- ) ]
            [ submit>> call( -- response ) ]
            tri
        ] [ drop <400> ] if
    ] with-exit-continuation ;

: handle-rest ( path action -- )
    rest>> [ [ "/" join ] dip set-param ] [ drop ] if* ;

: init-action ( path action -- )
    begin-form
    handle-rest ;

M: action call-responder* ( path action -- response )
    [ init-action ] keep
    request get method>> {
        { "GET" [ handle-get ] }
        { "HEAD" [ handle-get ] }
        { "POST" [ handle-post ] }
        [ 2drop <405> ]
    } case ;

M: action modify-form
    drop url get revalidate-url-key hidden-form-field ;

: check-validation ( -- )
    validation-failed? [ validation-failed ] when ;

: validate-params ( validators -- )
    params get swap validate-values check-validation ;

: validate-integer-id ( -- )
    { { "id" [ v-number ] } } validate-params ;

TUPLE: page-action < action template ;

: <chloe-content> ( path -- response )
    resolve-template-path <chloe> <html-content> ;

: <page-action> ( -- page )
    page-action new-action
        dup '[ _ template>> <chloe-content> ] >>display ;
