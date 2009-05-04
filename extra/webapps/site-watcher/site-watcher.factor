! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs db.sqlite furnace furnace.actions
furnace.alloy furnace.auth furnace.auth.features.deactivate-user
furnace.auth.features.edit-profile
furnace.auth.features.recover-password
furnace.auth.features.registration furnace.auth.login
furnace.boilerplate furnace.redirection html.forms http.server
http.server.dispatchers kernel namespaces site-watcher site-watcher.db
site-watcher.private urls validators io.sockets.secure.unix.debug
io.servers.connection io.files.temp db db.tuples sequences
webapps.site-watcher.common webapps.site-watcher.watching
webapps.site-watcher.spidering ;
QUALIFIED: assocs
IN: webapps.site-watcher

: <main-action> ( -- action )
    <page-action>
        { site-watcher-app "main" } >>template ;

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
        <watch-list-action> "watch-list" add-responder
        <add-watched-site-action> "add-watch" add-responder
        <remove-watched-site-action> "remove-watch" add-responder
        <check-sites-action> "check" add-responder
        <spider-list-action> "spider-list" add-responder
        <add-spidered-site-action> "add-spider" add-responder
        <remove-spidered-site-action> "remove-spider" add-responder
        <spider-sites-action> "spider" add-responder
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
    "test.db" temp-file <sqlite-db> ;

<site-watcher-app>
<login-config>
<boilerplate> { site-watcher-app "site-watcher" } >>template
site-watcher-db <alloy>
main-responder set-global

M: site-watcher-app init-user-profile
    drop "username" value "email" value <account> insert-tuple ;

: init-db ( -- )
    site-watcher-db [
        { site account watching-site spidering-site }
        [ ensure-table ] each
    ] with-db ;

: start-site-watcher ( -- )
    init-db
    site-watcher-db run-site-watcher
    <site-watcher-server> start-server ;
