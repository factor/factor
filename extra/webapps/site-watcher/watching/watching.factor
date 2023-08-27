! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions furnace.auth
furnace.redirection html.forms site-watcher site-watcher.db
validators webapps.site-watcher.common urls ;
IN: webapps.site-watcher.watching

CONSTANT: site-list-url URL" $site-watcher-app/watch-list"

: <watch-list-action> ( -- action )
    <page-action>
        { site-watcher-app "site-list" } >>template
        [
            ! Silly query
            username watching-sites
            "sites" set-value
        ] >>init
    <protected>
        "list watched sites" >>description ;

: <add-watched-site-action> ( -- action )
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

: <remove-watched-site-action> ( -- action )
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
