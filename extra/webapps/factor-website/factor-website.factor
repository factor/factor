! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences assocs io.files io.sockets
namespaces db db.sqlite smtp
http.server
http.server.db
http.server.flows
http.server.sessions
http.server.auth.login
http.server.auth.providers.db
http.server.sessions.storage.db
http.server.boilerplate
http.server.templating.chloe
webapps.pastebin
webapps.planet
webapps.todo ;
IN: webapps.factor-website

: test-db "test.db" resource-path sqlite-db ;

: factor-template ( path -- template )
    "resource:extra/webapps/factor-website/" swap ".xml" 3append <chloe> ;

: init-factor-db ( -- )
    test-db [
        init-users-table
        init-sessions-table

        init-pastes-table
        init-annotations-table

        init-blog-table

        init-todo-table
    ] with-db ;

: <factor-website> ( -- responder )
    <dispatcher>
        <todo-list> "todo" add-responder
        <pastebin> "pastebin" add-responder
        <planet-factor> "planet" add-responder
    <login>
        users-in-db >>users
        allow-registration
        allow-password-recovery
        allow-edit-profile
    <boilerplate>
        "page" factor-template >>template
    <flows>
    <url-sessions>
        sessions-in-db >>sessions
    test-db <db-persistence> ;

: init-factor-website ( -- )
    "factorcode.org" 25 <inet> smtp-server set-global
    "todo@factorcode.org" lost-password-from set-global

    init-factor-db

    <factor-website> main-responder set-global ;

: start-factor-website
    test-db start-expiring-sessions
    "planet" main-responder get responders>> at test-db start-update-task
    8812 httpd ;
