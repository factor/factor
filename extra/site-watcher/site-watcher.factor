! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: db.sqlite db.types db.tuples kernel accessors
db io.files io.files.temp locals io.directories continuations
assocs sequences alarms namespaces http.client init calendar
math math.parser smtp strings io prettyprint combinators arrays
generalizations combinators.smart ;
IN: site-watcher

: ?unparse ( string/object -- string )
    dup string? [ unparse ] unless ; inline

: site-watcher-path ( -- path ) "site-watcher.db" temp-file ; inline

[ site-watcher-path delete-file ] ignore-errors

: with-sqlite-db ( quot -- )
    site-watcher-path <sqlite-db> swap with-db ; inline

TUPLE: account account-id email ;

: <account> ( email -- account )
    account new
        swap >>email ;

account "ACCOUNT" {
    { "account-id" "ACCOUNT_ID" +db-assigned-id+ }
    { "email" "EMAIL" VARCHAR }
} define-persistent

TUPLE: site site-id url up? changed? last-up error last-error ;

: <site> ( url -- site )
    site new
        swap >>url ;

site "SITE" {
    { "site-id" "SITE_ID" INTEGER +db-assigned-id+ }
    { "url" "URL" VARCHAR }
    { "up?" "UP" BOOLEAN }
    { "changed?" "CHANGED" BOOLEAN }
    { "last-up" "LAST_UP" TIMESTAMP }
    { "error" "ERROR" VARCHAR }
    { "last-error" "LAST_ERROR" TIMESTAMP }
} define-persistent

TUPLE: watching-site account-id site-id ;

: <watching-site> ( account-id site-id -- watching-site )
    watching-site new
        swap >>site-id
        swap >>account-id ;

watching-site "WATCHING_SITE" {
    { "account-id" "ACCOUNT_ID" INTEGER +user-assigned-id+ }
    { "site-id" "SITE_ID" INTEGER +user-assigned-id+ }
} define-persistent

: select-account/site ( email url -- account site )
    [ <account> select-tuple account-id>> ]
    [ <site> select-tuple site-id>> ] bi* ;
    
: watch-site ( email url -- )
    select-account/site <watching-site> insert-tuple ;

: unwatch-site ( email url -- )
    select-account/site <watching-site> delete-tuples ;

SYMBOL: site-watcher-from
"factor-site-watcher@gmail.com" site-watcher-from set-global

SYMBOL: site-watcher-frequency
10 seconds site-watcher-frequency set-global
 
SYMBOL: running-site-watcher

<PRIVATE

: set-notify-site-watchers ( site new-up? -- site )
    [ over up?>> = [ t >>changed? ] unless ] keep >>up? ;

: site-good ( site -- )
    t set-notify-site-watchers
    now >>last-up
    f >>error
    f >>last-error
    update-tuple ;

: site-bad ( site error -- )
    ?unparse >>error
    f set-notify-site-watchers
    now >>last-error
    update-tuple ;

: check-sites ( seq -- )
    [
        [ dup url>> http-get 2drop site-good ] [ site-bad ] recover
    ] each ;

: site-up-email ( email site -- email )
    last-up>> now swap time- duration>minutes 60 /mod
    [ >integer number>string ] bi@
    [ " hours, " append ] [ " minutes" append ] bi* append
    "Site was down for (at least): " prepend >>body ;

: site-down-email ( email site -- email )
    error>> >>body ;

: send-report ( site -- )
    [ <email> ] dip
    {
        [ email>> 1array >>to ]
        [ drop site-watcher-from get "factor.site.watcher@gmail.com" or >>from ]
        [ dup up?>> [ site-up-email ] [ site-down-email ] if ]
        [ [ url>> ] [ up?>> "up" "down" ? ] bi " is " glue >>subject ]
    } cleave send-email ;

: email-accounts ( seq -- )
    [ ] [ [ send-report ] each ] if-empty ;

TUPLE: reporting-site email url up? changed? last-up? error last-error ;

: report-sites ( -- )
    "select account.email, site.url, site.up, site.changed, site.last_up, site.error, site.last_error from account, site, watching_site where account.account_id = watching_site.account_id and site.site_id = watching_site.site_id and site.changed = '1'" sql-query 
    [ [ reporting-site boa ] input<sequence ] map email-accounts
    "update site set changed = 'f';" sql-command ;

PRIVATE>

: watch-sites ( -- alarm )
    [
        [ 
            f <site> select-tuples check-sites report-sites
        ] with-sqlite-db
    ] site-watcher-frequency get every ;

: watch-new-site ( url -- )
    <site> t >>up? insert-tuple ;

: insert-account ( email -- )
    <account> insert-tuple ;

: run-site-watcher ( -- )
    running-site-watcher get [ 
        watch-sites running-site-watcher set-global 
    ] unless ;

: stop-site-watcher ( -- )
    running-site-watcher get [ cancel-alarm ] when* ;

[ f running-site-watcher set-global ] "site-watcher" add-init-hook


:: fake-sites ( -- seq )
    [
        account ensure-table
        site ensure-table
        watching-site ensure-table

        "erg@factorcode.org" insert-account
        "http://asdfasdfasdfasdfqwerqqq.com" watch-new-site
        "http://fark.com" watch-new-site

        "erg@factorcode.org" "http://asdfasdfasdfasdfqwerqqq.com" watch-site
        f <site> select-tuples
    ] with-sqlite-db ;
