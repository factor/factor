! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db.sqlite furnace.actions furnace.alloy
furnace.redirection help.html help.topics html.components
html.forms html.templates.chloe http.server
http.server.dispatchers http.server.static io.directories
io.files kernel locals namespaces sequences unicode.categories
urls ;
IN: webapps.help

TUPLE: help-webapp < dispatcher ;

M: result link-title title>> ;

M: result link-href href>> ;

:: <search-action> ( help-dir -- action )
    <page-action>
        { help-webapp "search" } >>template
        [
            "search" param [ blank? ] trim [
                help-dir [
                    [ article-apropos "articles" set-value ]
                    [ word-apropos "words" set-value ]
                    [ vocab-apropos "vocabs" set-value ] tri
                ] with-directory
            ] unless-empty

            { help-webapp "search" } <chloe-content>
        ] >>display ;

: help-url ( topic -- url )
    topic>filename "$help-webapp/content/" prepend >url ;

: <main-action> ( -- action )
    <action>
        [ "handbook" >link help-url <redirect> ] >>display ;

:: <help-webapp> ( help-dir -- webapp )
    help-webapp new-dispatcher
        <main-action> "" add-responder
        help-dir <search-action> "search" add-responder
        help-dir <static> "content" add-responder
        "resource:basis/definitions/icons/" <static> "icons" add-responder ;

: run-help-webapp ( -- )
    "resource:temp/docs" <help-webapp>
        main-responder set-global
    8080 httpd drop ;

MAIN: run-help-webapp
