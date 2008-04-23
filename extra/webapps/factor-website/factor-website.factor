! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences io.files io.sockets
db.sqlite smtp namespaces db
http.server.db
http.server.sessions
http.server.auth.login
http.server.auth.providers.db
http.server.sessions.storage.db
http.server.boilerplate
http.server.templating.chloe ;
IN: webapps.factor-website

: factor-template ( path -- template )
    "resource:extra/webapps/factor-website/" swap ".xml" 3append <chloe> ;

: test-db "todo.db" resource-path sqlite-db ;

: <factor-boilerplate> ( responder -- responder' )
    <login>
        users-in-db >>users
        allow-registration
        allow-password-recovery
        allow-edit-profile
    <boilerplate>
        "page" factor-template >>template
    <url-sessions>
        sessions-in-db >>sessions
    test-db <db-persistence> ;

: init-factor-website ( -- )
    "factorcode.org" 25 <inet> smtp-server set-global
    "todo@factorcode.org" lost-password-from set-global

    test-db [
        init-sessions-table
        init-users-table
    ] with-db ;
