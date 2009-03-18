! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alarms arrays calendar combinators
combinators.smart continuations db db.tuples debugger
http.client init io.streams.string kernel locals math
math.parser namespaces sequences site-watcher.db smtp ;
IN: site-watcher

SYMBOL: site-watcher-from
"factor-site-watcher@gmail.com" site-watcher-from set-global

SYMBOL: site-watcher-frequency
10 seconds site-watcher-frequency set-global
 
SYMBOL: running-site-watcher
[ f running-site-watcher set-global ] "site-watcher" add-init-hook

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
    [ error. ] with-string-writer >>error
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

: insert-site ( url -- site )
    <site> dup select-tuple [
        dup t >>up? insert-tuple
    ] unless ;

PRIVATE>

: select-account/site ( email url -- account site )
    [ <account> select-tuple account-id>> ]
    [ insert-site site-id>> ] bi* ;

: watch-site ( email url -- )
    select-account/site <watching-site> insert-tuple ;

: unwatch-site ( email url -- )
    select-account/site <watching-site> delete-tuples ;

: insert-account ( email -- ) <account> insert-tuple ;

: watch-sites ( -- alarm )
    [
        [ 
            f <site> select-tuples check-sites report-sites
        ] with-sqlite-db
    ] site-watcher-frequency get every ;

: run-site-watcher ( -- )
    running-site-watcher get [ 
        watch-sites running-site-watcher set-global 
    ] unless ;

: stop-site-watcher ( -- )
    running-site-watcher get [ cancel-alarm ] when* ;
