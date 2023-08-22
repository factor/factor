! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs continuations furnace.actions
furnace.boilerplate furnace.redirection help.html help.topics
html.components html.forms http.server http.server.dispatchers
http.server.static io.directories io.files.temp io.servers
kernel namespaces sequences simple-tokenizer splitting unicode
urls ;
IN: webapps.help

TUPLE: help-webapp < dispatcher ;

: fixup-words ( title href -- title' href' )
    dup "word-" head? [
        dup ".html" ?tail drop "," split1-last nip dup ":" append
        '[ " (" _ 3append ")" append _ ?head drop ] dip
    ] when ;

: links ( apropos -- seq )
    [ swap fixup-words <simple-link> ] { } assoc>map ;

: ?links ( has-links? apropos -- has-links? seq/f )
    links [ f ] [ nip t swap ] if-empty ;

: ?tokenize ( str -- str' )
    [ tokenize ] [ drop 1array ] recover ;

:: <search-action> ( help-dir -- action )
    <page-action>
        { help-webapp "search" } >>template
        [
            f "search" param [ unicode:blank? ] trim
            dup "search" set-value [
                help-dir [
                    ?tokenize concat
                    [ article-apropos ?links "articles" set-value ]
                    [ word-apropos ?links "words" set-value ]
                    [ vocab-apropos ?links "vocabs" set-value ] tri
                ] with-directory
            ] unless-empty not "empty" set-value
            help-nav "nav" set-value

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
