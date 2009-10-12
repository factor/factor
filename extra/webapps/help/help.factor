! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors http.server.dispatchers
http.server.static furnace.actions furnace.redirection urls
validators locals io.files io.directories html.forms
html.components help.html ;
IN: webapps.help

TUPLE: help-webapp < dispatcher ;

M: result link-title title>> ;

M: result link-href href>> ;

:: <search-action> ( help-dir -- action )
    <page-action>
        { help-webapp "search" } >>template

        [
            {
                { "search" [ 1 v-min-length 50 v-max-length v-one-line ] }
            } validate-params

            help-dir [
                "search" value article-apropos "articles" set-value
                "search" value word-apropos "words" set-value
                "search" value vocab-apropos "vocabs" set-value
            ] with-directory

            { help-webapp "search" } <chloe-content>
        ] >>submit ;

: <main-action> ( -- action )
    <page-action>
        { help-webapp "help" } >>template ;

: <help-webapp> ( help-dir -- webapp )
    help-webapp new-dispatcher
        <main-action> "" add-responder
        over <search-action> "search" add-responder
        swap <static> "content" add-responder
        "resource:basis/definitions/icons/" <static> "icons" add-responder ;


