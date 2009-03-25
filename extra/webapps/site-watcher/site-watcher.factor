! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs db.sqlite furnace furnace.actions furnace.alloy
furnace.auth furnace.auth.features.deactivate-user
furnace.auth.features.edit-profile
furnace.auth.features.recover-password
furnace.auth.features.registration furnace.auth.login
furnace.boilerplate furnace.redirection html.forms http.server
http.server.dispatchers kernel namespaces site-watcher site-watcher.db
site-watcher.private urls validators io.sockets.secure.unix.debug
io.servers.connection db db.tuples sequences ;
QUALIFIED: assocs
IN: webapps.site-watcher

TUPLE: site-watcher-app < dispatcher ;

CONSTANT: site-list-url URL" $site-watcher-app/"

: <main-action> ( -- action )
    <page-action>
        [
            logged-in?
            [ URL" $site-watcher-app/list" <redirect> ]
            [ { site-watcher-app "main" } <chloe-content> ] if
        ] >>display ;

: <site-list-action> ( -- action )
    <page-action>
        { site-watcher-app "site-list" } >>template
        [
            ! Silly query
            username watching-sites
            "sites" set-value
        ] >>init
    <protected>
        "list watched sites" >>description ;

: <add-site-action> ( -- action )
    <action>
        [
            { { "url" [ v-url ] } } validate-params
        ] >>validate
        [
            username "url" value watch-site
            site-list-url <redirect>
        ] >>submit
    <protected>
        "add a watched site" >>description ;

: <remove-site-action> ( -- action )
    <action>
        [
            { { "url" [ v-url ] } } validate-params
        ] >>validate
        [
            username "url" value unwatch-site
            site-list-url <redirect>
        ] >>submit
    <protected>
        "remove a watched site" >>description ;

: <check-sites-action> ( -- action )
    <action>
        [
            watch-sites
            site-list-url <redirect>
        ] >>submit
    <protected>
        "check watched sites" >>description ;

: <update-notify-action> ( -- action )
    <page-action>
        [
            username f <account> select-tuple from-object
        ] >>init
        { site-watcher-app "update-notify" } >>template
        [
            {
                { "email" [ [ v-email ] v-optional ] }
                { "twitter" [ [ v-one-word ] v-optional ] }
                { "sms" [ [ v-one-line ] v-optional ] }
            } validate-params
        ] >>validate
        [
            username f <account> select-tuple
            "email" value >>email
            "twitter" value >>twitter
            "sms" value >>sms
            update-tuple
            site-list-url <redirect>
        ] >>submit
    <protected>
        "update notification details" >>description ;

: <site-watcher-app> ( -- dispatcher )
    site-watcher-app new-dispatcher
        <main-action> "" add-responder
        <site-list-action> "list" add-responder
        <add-site-action> "add" add-responder
        <remove-site-action> "remove" add-responder
        <check-sites-action> "check" add-responder
        <update-notify-action> "update-notify" add-responder ;

: <login-config> ( responder -- responder' )
    "SiteWatcher" <login-realm>
        "SiteWatcher" >>name
        allow-registration
        allow-password-recovery
        allow-edit-profile
        allow-deactivation ;

: <site-watcher-server> ( -- threaded-server )
    <http-server>
        <test-secure-config> >>secure-config
        8081 >>insecure
        8431 >>secure ;

: site-watcher-db ( -- db )
    "resource:test.db" <sqlite-db> ;

<site-watcher-app>
<login-config>
<boilerplate> { site-watcher-app "site-watcher" } >>template
site-watcher-db <alloy>
main-responder set-global

M: site-watcher-app init-user-profile
    drop
    "username" value "email" value <account> insert-tuple ;

: init-db ( -- )
    site-watcher-db [
        { site account watching-site } [ ensure-table ] each
    ] with-db ;

: start-site-watcher ( -- )
    init-db
    site-watcher-db run-site-watcher
    <site-watcher-server> start-server ;
