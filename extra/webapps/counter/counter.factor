! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel accessors http.server http.server.dispatchers
furnace furnace.actions furnace.sessions furnace.redirection
html.components html.forms fry urls ;
IN: webapps.counter

SYMBOL: count

TUPLE: counter-app < dispatcher ;

M: counter-app init-session* drop 0 count sset ;

: <counter-action> ( quot -- action )
    <action>
        swap '[
            count _ schange
            URL" $counter-app" <redirect>
        ] >>submit ;

: <display-action> ( -- action )
    <page-action>
        [ count sget "counter" set-value ] >>init
        { counter-app "counter" } >>template ;

: <counter-app> ( -- responder )
    counter-app new-dispatcher
        [ 1 + ] <counter-action> "inc" add-responder
        [ 1 - ] <counter-action> "dec" add-responder
        <display-action> "" add-responder ;

! Deployment example
USING: db.sqlite furnace.alloy namespaces ;

: counter-db ( -- db ) "counter.db" <sqlite-db> ;

: run-counter ( -- )
    <counter-app>
        counter-db <alloy>
        main-responder set-global
    8080 httpd ;

MAIN: run-counter
