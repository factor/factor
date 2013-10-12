! Copyright (C) 2008 Chris Double. All Rights Reserved.
USING: 
    accessors
    fjsc
    furnace
    furnace.actions
    furnace.boilerplate
    furnace.redirection
    furnace.utilities
    html.forms
    http
    http.client
    http.server
    http.server.dispatchers
    http.server.responses
    http.server.static
    io
    io.pathnames
    io.streams.string
    kernel
    namespaces
    peg
    sequences
    urls 
    validators
;
IN: webapps.fjsc

TUPLE: fjsc < dispatcher ;

: absolute-url ( url -- url )
    "http://" request get "host" header append 
    over "/" head? [ "/" append ] unless 
    swap append  ;

: do-compile-url ( url -- response )
    [ 
        absolute-url http-get* 'expression' parse fjsc-compile write "();" write
    ] with-string-writer
    "application/javascript" <content> ;

: v-local ( string -- string )
    dup "http:" head? [ "Unable to compile code from remote sites" throw ] when ;

: validate-compile-url ( -- )
    {
        { "url" [ v-required v-local ] }
    } validate-params ;

: <compile-url-action> ( -- action )
    <action>
        [ validate-compile-url ] >>validate
        [ "url" value do-compile-url ] >>submit
        [ validate-compile-url "url" value do-compile-url ] >>display ;

: do-compile ( code -- response )
    [ 
        'expression' parse fjsc-compile write
    ] with-string-writer
    "application/javascript" <content> ;

: validate-compile ( -- )
    {
        { "code" [ v-required ] }
    } validate-params ;

: <compile-action> ( -- action )
    <action>
        [ validate-compile ] >>validate
        [ "code" value do-compile ] >>submit
        [ validate-compile "code" value do-compile ] >>display ;

: <main-action> ( -- action )
    <page-action>
        { fjsc "main" } >>template ;

: <fjsc> ( -- fjsc )
    dispatcher new-dispatcher
        "extra/webapps/fjsc/www" resource-path <static> "static" add-responder
        "extra/fjsc/resources" resource-path <static> "fjsc" add-responder
        fjsc new-dispatcher
            <main-action> "" add-responder
            <compile-action> "compile" add-responder
            <compile-url-action> "compile-url" add-responder
            <boilerplate>
                { fjsc "fjsc" } >>template 
         >>default ;

: activate-fjsc ( -- )
    <fjsc> main-responder set-global ;
