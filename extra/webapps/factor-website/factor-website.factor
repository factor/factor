! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences assocs io.files io.sockets
io.server
namespaces db db.sqlite smtp
http.server
http.server.dispatchers
furnace.db
furnace.flows
furnace.sessions
furnace.auth.login
furnace.auth.providers.db
furnace.boilerplate
webapps.pastebin
webapps.planet
webapps.todo
webapps.wiki
webapps.user-admin ;
IN: webapps.factor-website

: test-db "resource:test.db" sqlite-db ;

: init-factor-db ( -- )
    test-db [
        init-users-table
        init-sessions-table

        init-pastes-table
        init-annotations-table

        init-blog-table
        init-postings-table

        init-todo-table

        init-articles-table
        init-revisions-table
    ] with-db ;

TUPLE: factor-website < dispatcher ;

: <factor-website> ( -- responder )
    factor-website new-dispatcher 
        <todo-list> "todo" add-responder
        <pastebin> "pastebin" add-responder
        <planet-factor> "planet" add-responder
        <wiki> "wiki" add-responder
        <user-admin> "user-admin" add-responder
    <login>
        users-in-db >>users
        allow-registration
        allow-password-recovery
        allow-edit-profile
    <boilerplate>
        { factor-website "page" } >>template
    <flows>
    <sessions>
    test-db <db-persistence> ;

: init-factor-website ( -- )
    "factorcode.org" 25 <inet> smtp-server set-global
    "todo@factorcode.org" lost-password-from set-global

    init-factor-db

    <factor-website> main-responder set-global ;

: start-factor-website ( -- )
    test-db start-expiring-sessions
    test-db start-update-task
    8812 httpd ;
