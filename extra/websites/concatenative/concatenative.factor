! Copyright (c) 2008, 2010 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences assocs io.files io.pathnames
io.sockets io.sockets.secure io.servers
namespaces db db.tuples db.sqlite smtp urls
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

: website-db ( -- db ) "~/website.db" <sqlite-db> ;

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

SYMBOLS: factor-recaptcha-site-key factor-recaptcha-secret-key ;

: <factor-recaptcha> ( responder -- responder' )
    <recaptcha>
        "concatenative.org" >>domain
        factor-recaptcha-site-key get >>site-key
        factor-recaptcha-secret-key get >>secret-key ;

: <concatenative-website> ( -- responder )
    concatenative-website new-dispatcher
        "resource:extra/websites/concatenative" <static> >>default
        URL" /wiki/view/Front Page" <redirect-responder> "" add-responder ;

SYMBOLS: key-password key-file dh-file ;

: common-configuration ( -- )
    "noreply@concatenative.org" lost-password-from set-global
    init-factor-db ;

: init-testing ( -- )
    "vocab:openssl/test/dh1024.pem" dh-file set-global
    "vocab:openssl/test/server.pem" key-file set-global
    "password" key-password set-global
    common-configuration
    <concatenative-website>
        <wiki> <factor-recaptcha> <login-config> <factor-boilerplate> "wiki" add-responder
        <user-admin> <login-config> <factor-boilerplate> "user-admin" add-responder
        <pastebin> <factor-recaptcha> <login-config> <factor-boilerplate> "pastebin" add-responder
        <planet> <login-config> <factor-boilerplate> "planet" add-responder
        <mason-app> <login-config> <factor-boilerplate> "mason" add-responder
        "/tmp/docs/" <help-webapp> "docs" add-responder
    website-db <alloy>
    main-responder set-global ;

: <gitweb> ( path -- responder )
    <dispatcher>
        swap <static> enable-cgi >>default
        URL" /gitweb.cgi" <redirect-responder> "" add-responder
        URL" /github-sync.cgi" <redirect-responder> "github-sync" add-responder ;

TUPLE: cgit < file-responder ;

: <cgit> ( root -- responder )
    cgit new
        swap >>root
        [ (serve-static) ] >>hook
        H{ } clone >>special
    enable-cgi ;

M: cgit call-responder*
    dup file-responder set
    over [ f ] [ "/" join serving-path file-exists? ] if-empty [
        url get
            rot "/" join "url" set-query-param
            "cgit.cgi" >>path drop { "cgit.cgi" } swap
    ] unless call-next-method ;

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
        "~/docs" <help-webapp> "docs.factorcode.org" add-responder
        "~/gitweb" <gitweb> "gitweb.factorcode.org" add-responder
        "~/cgit" <cgit> "cgit.factorcode.org" add-responder
        "~/re" <static> "re.factorcode.org" add-responder
        "~/erg" <static> "erg.factorcode.org" add-responder
        "~/blogs" <static> "blogs.factorcode.org" add-responder
        "~/irclogs" <static> t >>allow-listings "irclogs.factorcode.org" add-responder
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
