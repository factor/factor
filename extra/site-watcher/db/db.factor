! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations db db.sqlite db.tuples db.types
io.directories io.files.temp kernel io.streams.string calendar
debugger combinators.smart sequences ;
IN: site-watcher.db

TUPLE: account account-id account-name email ;

: <account> ( account-name -- account )
    account new
        swap >>account-name ;

account "ACCOUNT" {
    { "account-id" "ACCOUNT_ID" +db-assigned-id+ }
    { "account-name" "ACCOUNT_NAME" VARCHAR }
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

TUPLE: reporting-site email url up? changed? last-up? error last-error ;

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

: sites-to-report ( -- seq )
    "select account.email, site.url, site.up, site.changed, site.last_up, site.error, site.last_error from account, site, watching_site where account.account_id = watching_site.account_id and site.site_id = watching_site.site_id and site.changed = '1'" sql-query 
    [ [ reporting-site boa ] input<sequence ] map
    "update site set changed = 'f';" sql-command ;

: insert-site ( url -- site )
    <site> dup select-tuple [
        dup t >>up? insert-tuple
    ] unless ;

: insert-account ( account-name -- ) <account> insert-tuple ;

: find-sites ( -- seq ) f <site> select-tuples ;

: select-account/site ( email url -- account site )
    [ <account> select-tuple account-id>> ]
    [ insert-site site-id>> ] bi* ;

PRIVATE>

: watch-site ( email url -- )
    select-account/site <watching-site> insert-tuple ;

: unwatch-site ( email url -- )
    select-account/site <watching-site> delete-tuples ;
