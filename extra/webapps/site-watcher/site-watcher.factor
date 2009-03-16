! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions furnace.alloy furnace.redirection
html.forms http.server http.server.dispatchers namespaces site-watcher
site-watcher.private kernel urls validators db.sqlite assocs ;
IN: webapps.site-watcher

TUPLE: site-watcher-app < dispatcher ;

CONSTANT: site-list-url URL" $site-watcher-app/"

: <site-list-action> ( -- action )
    <page-action>
        { site-watcher-app "site-list" } >>template
        [
            begin-form
            sites get values "sites" set-value
        ] >>init ;

: <add-site-action> ( -- action )
    <action>
        [
            { { "url" [ v-url ] } { "email" [ v-email ] } } validate-params
        ] >>validate
        [
            "email" value "url" value watch-site
            site-list-url <redirect>
        ] >>submit ;

: <remove-site-action> ( -- action )
    <action>
        [
            { { "url" [ v-url ] } } validate-params
        ] >>validate
        [
            "url" value delete-site
            site-list-url <redirect>
        ] >>submit ;

: <check-sites-action> ( -- action )
    <action>
        [
            sites get [ check-sites ] [ report-sites ] bi
            site-list-url <redirect>
        ] >>submit ;

: <site-watcher-app> ( -- dispatcher )
    site-watcher-app new-dispatcher
        <site-list-action> "" add-responder
        <add-site-action> "add" add-responder
        <remove-site-action> "remove" add-responder
        <check-sites-action> "check" add-responder ;

<site-watcher-app> "resource:test.db" <sqlite-db> <alloy> main-responder set-global