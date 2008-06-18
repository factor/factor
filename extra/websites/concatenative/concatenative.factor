! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences assocs io.files io.sockets
io.sockets.secure io.servers.connection
namespaces db db.tuples db.sqlite smtp urls
logging.insomniac
http.server
http.server.dispatchers
http.server.redirection
furnace.alloy
furnace.auth.login
furnace.auth.providers.db
furnace.auth.features.edit-profile
furnace.auth.features.recover-password
furnace.auth.features.registration
furnace.auth.features.deactivate-user
furnace.boilerplate
furnace.redirection
webapps.blogs
webapps.pastebin
webapps.planet
webapps.todo
webapps.wiki
webapps.wee-url
webapps.user-admin ;
IN: websites.concatenative

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
        URL" /wiki/view/Front Page" <redirect-responder> "" add-responder
    "Factor website" <login-realm>
        "Factor website" >>name
        allow-registration
        allow-password-recovery
        allow-edit-profile
        allow-deactivation
    <boilerplate>
        { factor-website "page" } >>template
    test-db <alloy> ;

: init-factor-website ( -- )
    "factorcode.org" 25 <inet> smtp-server set-global
    "noreply@concatenative.org" lost-password-from set-global
    "website@concatenative.org" insomniac-sender set-global
    "slava@factorcode.org" insomniac-recipients set-global
    init-factor-db
    <factor-website> main-responder set-global ;

: <factor-secure-config> ( -- config )
    <secure-config>
        "resource:extra/openssl/test/server.pem" >>key-file
        "resource:extra/openssl/test/dh1024.pem" >>dh-file
        "password" >>password ;

: <factor-website-server> ( -- threaded-server )
    <http-server>
        <factor-secure-config> >>secure-config
        8080 >>insecure
        8431 >>secure ;

: start-factor-website ( -- )
    test-db start-expiring
    test-db start-update-task
    http-insomniac
    <factor-website-server> start-server ;
