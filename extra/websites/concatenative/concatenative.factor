! Copyright (c) 2008, 2010 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences assocs io.files io.pathnames
io.sockets io.sockets.secure io.servers
namespaces smtp urls
db2.connections
orm.tuples
sqlite.db2
logging.insomniac calendar timers
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
furnace.recaptcha
webapps.pastebin
webapps.planet
webapps.wiki
webapps.user-admin
webapps.help
webapps.mason
webapps.mason.backend
webapps.mason.backend.watchdog
websites.factorcode ;
IN: websites.concatenative

: website-db ( -- db ) home "website.db" append-path <sqlite-db> ;

: init-factor-db ( -- )
    mason-db [ init-mason-db ] with-db

    website-db [
        init-furnace-tables

        {
            paste-state annotation
            blog posting
            article revision
        } ensure-tables
    ] with-db ;

TUPLE: concatenative-website < dispatcher ;

: <factor-boilerplate> ( responder -- responder' )
    <boilerplate>
        { concatenative-website "page" } >>template ;

: <login-config> ( responder -- responder' )
    "Factor website" <login-realm>
        allow-registration
        allow-password-recovery
        allow-edit-profile
        allow-deactivation ;

SYMBOLS: factor-recaptcha-public-key factor-recaptcha-private-key ;

: <factor-recaptcha> ( responder -- responder' )
    <recaptcha>
        "concatenative.org" >>domain
        factor-recaptcha-public-key get >>public-key
        factor-recaptcha-private-key get >>private-key ;

: <concatenative-website> ( -- responder )
    concatenative-website new-dispatcher
        URL" /wiki/view/Front Page" <redirect-responder> "" add-responder ;

SYMBOLS: key-password key-file dh-file ;

: common-configuration ( -- )
    "noreply@concatenative.org" lost-password-from set-global
    init-factor-db ;

: <gitweb> ( path -- responder )
    <dispatcher>
        swap <static> enable-cgi >>default
        URL" /gitweb.cgi" <redirect-responder> "" add-responder ;

: init-testing-concatenative ( -- )
    "vocab:openssl/test/dh1024.pem" dh-file set-global
    "vocab:openssl/test/server.pem" key-file set-global
    "password" key-password set-global
    common-configuration
    <dispatcher>
        <concatenative-website>
            <wiki> <factor-recaptcha> "wiki" add-responder
            <user-admin> "user-admin" add-responder
        <login-config> <factor-boilerplate> website-db <alloy> "concatenative" add-responder
        <pastebin> <factor-recaptcha> <login-config> <factor-boilerplate> website-db <alloy> "paste" add-responder
        <planet> <login-config> <factor-boilerplate> website-db <alloy> "planet" add-responder
        <mason-app> <login-config> <factor-boilerplate> website-db <alloy> "builds" add-responder
        home "docs" append-path <help-webapp> "docs" add-responder
        home "cgi" append-path <gitweb> "gitweb" add-responder
    main-responder set-global ;

: init-production ( -- )
    common-configuration
    <vhost-dispatcher>
        <concatenative-website>
            <wiki> <factor-recaptcha> "wiki" add-responder
            <user-admin> "user-admin" add-responder
        <login-config> <factor-boilerplate> website-db <alloy> "concatenative.org" add-responder
        <pastebin> <factor-recaptcha> <login-config> <factor-boilerplate> website-db <alloy> "paste.factorcode.org" add-responder
        <planet> <login-config> <factor-boilerplate> website-db <alloy> "planet.factorcode.org" add-responder
        <mason-app> <login-config> <factor-boilerplate> website-db <alloy> "builds.factorcode.org" add-responder
        home "docs" append-path <help-webapp> "docs.factorcode.org" add-responder
        home "cgi" append-path <gitweb> "gitweb.factorcode.org" add-responder
    main-responder set-global ;

: <factor-secure-config> ( -- config )
    <secure-config>
        key-file get >>key-file
        dh-file get >>dh-file
        key-password get >>password ;

: <concatenative-website-server> ( -- threaded-server )
    <http-server>
        <factor-secure-config> >>secure-config
        8080 >>insecure
        8431 >>secure ;

: start-watchdog ( -- )
    [ check-builders ] 6 hours every drop ;

: start-website ( -- server )
    website-db start-expiring
    website-db start-update-task
    http-insomniac
    start-watchdog
    <concatenative-website-server> start-server ;
