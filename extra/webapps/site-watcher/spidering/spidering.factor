! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions furnace.auth
furnace.redirection html.forms validators webapps.site-watcher.common
site-watcher.db site-watcher.spider kernel urls sequences ;
IN: webapps.site-watcher.spidering

CONSTANT: site-list-url URL" $site-watcher-app/spider-list"

: <spider-list-action> ( -- action )
    <page-action>
        { site-watcher-app "spider-list" } >>template
        [
            ! Silly query
            username spidering-sites [ site>> ] map
            "sites" set-value
        ] >>init
    <protected>
        "list spidered sites" >>description ;

: <add-spidered-site-action> ( -- action )
    <action>
        [
            { { "url" [ v-url ] } } validate-params
        ] >>validate
        [
            username "url" value add-spidered-site
            site-list-url <redirect>
        ] >>submit
    <protected>
        "add a spidered site" >>description ;

: <remove-spidered-site-action> ( -- action )
    <action>
        [
            { { "url" [ v-url ] } } validate-params
        ] >>validate
        [
            username "url" value remove-spidered-site
            site-list-url <redirect>
        ] >>submit
    <protected>
        "remove a spidered site" >>description ;

: <spider-sites-action> ( -- action )
    <action>
        [
            spider-sites
            site-list-url <redirect>
        ] >>submit
    <protected>
        "spider sites" >>description ;
