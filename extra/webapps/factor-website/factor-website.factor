! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences assocs io.files io.sockets
io.server
namespaces db db.tuples db.sqlite smtp
logging.insomniac
http.server
http.server.dispatchers
furnace.alloy
furnace.auth.login
furnace.auth.providers.db
furnace.auth.features.edit-profile
furnace.auth.features.recover-password
furnace.auth.features.registration
furnace.boilerplate
webapps.blogs
webapps.pastebin
webapps.planet
webapps.todo
webapps.wiki
webapps.wee-url
webapps.user-admin ;
IN: webapps.factor-website

: test-db ( -- db params ) "resource:test.db" sqlite-db ;

: init-factor-db ( -- )
    test-db [
        init-furnace-tables

        {
            post comment
            paste annotation
            blog posting
            todo
            short-url
            article revision
        } ensure-tables
    ] with-db ;

TUPLE: factor-website < dispatcher ;

: <factor-website> ( -- responder )
    factor-website new-dispatcher
        <blogs> "blogs" add-responder
        <todo-list> "todo" add-responder
        <pastebin> "pastebin" add-responder
        <planet-factor> "planet" add-responder
        <wiki> "wiki" add-responder
        <wee-url> "wee-url" add-responder
        <user-admin> "user-admin" add-responder
    "Factor website" <login-realm>
        "Factor website" >>name
        allow-registration
        allow-password-recovery
        allow-edit-profile
    <boilerplate>
        { factor-website "page" } >>template
    test-db <alloy> ;

: init-factor-website ( -- )
    "factorcode.org" 25 <inet> smtp-server set-global
    "todo@factorcode.org" lost-password-from set-global
    "website@factorcode.org" insomniac-sender set-global
    "slava@factorcode.org" insomniac-recipients set-global
    init-factor-db
    <factor-website> main-responder set-global ;

: start-factor-website ( -- )
    test-db start-expiring
    test-db start-update-task
    httpd-insomniac
    8812 httpd ;
