! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs furnace.actions furnace.boilerplate
furnace.redirection help.html help.topics html.components
html.forms http.server http.server.dispatchers
http.server.static io.directories io.files.temp io.servers
kernel namespaces sequences unicode urls ;
IN: webapps.help

TUPLE: help-webapp < dispatcher ;

: links ( apropos -- seq )
    [ swap <simple-link> ] { } assoc>map ;

: ?links ( has-links? apropos -- has-links? seq )
    links [ empty? not or ] keep ;

:: <search-action> ( help-dir -- action )
    <page-action>
        { help-webapp "search" } >>template
        [
            "search" param [ unicode:blank? ] trim [
                f swap help-dir [
                    [ article-apropos ?links "articles" set-value ]
                    [ word-apropos ?links "words" set-value ]
                    [ vocab-apropos ?links "vocabs" set-value ] tri
                ] with-directory not "empty" set-value
            ] unless-empty
            help-navbar "navbar" set-value

            { help-webapp "search" } <chloe-content>
        ] >>display
    <boilerplate>
        { help-webapp "help" } >>template ;

: help-url ( topic -- url )
    topic>filename "$help-webapp/content/" prepend >url ;

: <main-action> ( -- action )
    <action>
        [ "handbook" >link help-url <redirect> ] >>display ;

:: <help-webapp> ( help-dir -- webapp )
    help-webapp new-dispatcher
        <main-action> <secure-only> "" add-responder
        help-dir <search-action> <secure-only> "search" add-responder
        help-dir <static> <secure-only> "content" add-responder ;

: run-help-webapp ( -- )
    "docs" cache-file <help-webapp>
        main-responder set-global
    8080 httpd wait-for-server ;

MAIN: run-help-webapp
