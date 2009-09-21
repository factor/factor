! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences assocs io.files io.pathnames
io.sockets io.sockets.secure io.servers.connection
namespaces db db.tuples db.sqlite smtp urls
logging.insomniac
html.templates.chloe
http.server
http.server.dispatchers
http.server.redirection
http.server.static
http.server.cgi
furnace.alloy
furnace.auth.login
furnace.auth.providers.db
furnace.auth.features.edit-profile
furnace.auth.features.recover-password
furnace.auth.features.registration
furnace.auth.features.deactivate-user
furnace.boilerplate
furnace.redirection
webapps.pastebin
webapps.planet
webapps.wiki
webapps.user-admin
webapps.help
webapps.mason ;
IN: websites.concatenative

: test-db ( -- db ) "resource:test.db" <sqlite-db> ;

: init-factor-db ( -- )
    test-db [
        init-furnace-tables

        {
            paste annotation
            blog posting
            article revision
        } ensure-tables
    ] with-db ;

TUPLE: factor-website < dispatcher ;

: <factor-boilerplate> ( responder -- responder' )
    <boilerplate>
        { factor-website "page" } >>template ;

: <login-config> ( responder -- responder' )
    "Factor website" <login-realm>
        "Factor website" >>name
        allow-registration
        allow-password-recovery
        allow-edit-profile
        allow-deactivation ;

: <factor-website> ( -- responder )
    factor-website new-dispatcher
        URL" /wiki/view/Front Page" <redirect-responder> "" add-responder ;

SYMBOL: key-password
SYMBOL: key-file
SYMBOL: dh-file

: common-configuration ( -- )
    "concatenative.org" 25 <inet> smtp-server set-global
    "noreply@concatenative.org" lost-password-from set-global
    "website@concatenative.org" insomniac-sender set-global
    { "slava@factorcode.org" } insomniac-recipients set-global
    init-factor-db ;

: init-testing ( -- )
    "vocab:openssl/test/dh1024.pem" dh-file set-global
    "vocab:openssl/test/server.pem" key-file set-global
    "password" key-password set-global
    common-configuration
    <factor-website>
        <wiki> <login-config> <factor-boilerplate> "wiki" add-responder
        <user-admin> <login-config> <factor-boilerplate> "user-admin" add-responder
        <pastebin> <login-config> <factor-boilerplate> "pastebin" add-responder
        <planet> <login-config> <factor-boilerplate> "planet" add-responder
        "/tmp/docs/" <help-webapp> "docs" add-responder
    test-db <alloy>
    main-responder set-global ;

: <gitweb> ( path -- responder )
    <dispatcher>
        swap <static> enable-cgi >>default
        URL" /gitweb.cgi" <redirect-responder> "" add-responder ;

: init-production ( -- )
    common-configuration
    <vhost-dispatcher>
        <factor-website>
            <wiki> "wiki" add-responder
            <user-admin> "user-admin" add-responder
        <login-config> <factor-boilerplate> test-db <alloy> "concatenative.org" add-responder
        <pastebin> <login-config> <factor-boilerplate> test-db <alloy> "paste.factorcode.org" add-responder
        <planet> <login-config> <factor-boilerplate> test-db <alloy> "planet.factorcode.org" add-responder
        home "docs" append-path <help-webapp> test-db <alloy> "docs.factorcode.org" add-responder
        home "cgi" append-path <gitweb> "gitweb.factorcode.org" add-responder
        <mason-app> "builds.factorcode.org" add-responder
    main-responder set-global ;

: <factor-secure-config> ( -- config )
    <secure-config>
        key-file get >>key-file
        dh-file get >>dh-file
        key-password get >>password ;

: <factor-website-server> ( -- threaded-server )
    <http-server>
        <factor-secure-config> >>secure-config
        8080 >>insecure
        8431 >>secure ;

: start-website ( -- )
    test-db start-expiring
    test-db start-update-task
    http-insomniac
    <factor-website-server> start-server ;
