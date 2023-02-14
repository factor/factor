! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar combinators.smart db db.sqlite
db.tuples db.types debugger io.files.temp io.streams.string
kernel sequences ;
IN: site-watcher.db

TUPLE: account account-name email twitter sms ;

: <account> ( account-name email -- account )
    account new
        swap >>email
        swap >>account-name ;

account "ACCOUNT" {
    { "account-name" "ACCOUNT_NAME" VARCHAR +user-assigned-id+ }
    { "email" "EMAIL" VARCHAR }
    { "twitter" "TWITTER" VARCHAR }
    { "sms" "SMS" VARCHAR }
} define-persistent

TUPLE: site site-id url up? changed? last-up error last-error ;

: <site> ( url -- site )
    site new
        swap >>url ;

: site-with-url ( url -- site )
    <site> select-tuple ;

: site-with-id ( id -- site )
    site new swap >>site-id select-tuple ;

site "SITE" {
    { "site-id" "SITE_ID" INTEGER +db-assigned-id+ }
    { "url" "URL" VARCHAR }
    { "up?" "UP" BOOLEAN }
    { "changed?" "CHANGED" BOOLEAN }
    { "last-up" "LAST_UP" TIMESTAMP }
    { "error" "ERROR" VARCHAR }
    { "last-error" "LAST_ERROR" TIMESTAMP }
} define-persistent

TUPLE: watching-site account-name site-id ;

: <watching-site> ( account-name site-id -- watching-site )
    watching-site new
        swap >>site-id
        swap >>account-name ;

watching-site "WATCHING_SITE" {
    { "account-name" "ACCOUNT_NAME" VARCHAR +user-assigned-id+ }
    { "site-id" "SITE_ID" INTEGER +user-assigned-id+ }
} define-persistent

TUPLE: spidering-site < watching-site max-depth max-count ;

C: <spidering-site> spidering-site

SLOT: site

M: watching-site site>>
    site-id>> site-with-id ;

SLOT: account

M: watching-site account>>
    account-name>> account new swap >>account-name select-tuple ;

spidering-site "SPIDERING_SITE" {
    { "max-depth" "MAX_DEPTH" INTEGER }
    { "max-count" "MAX_COUNT" INTEGER }
} define-persistent

: spidering-sites ( username -- sites )
    spidering-site new swap >>account-name select-tuples ;

: insert-site ( url -- site )
    <site> [ select-tuple ] [ dup t >>up? insert-tuple ] ?unless ;

: select-account/site ( username url -- account site )
    insert-site site-id>> ;

: add-spidered-site ( username url -- )
    select-account/site 10 10 <spidering-site> insert-tuple ;

: remove-spidered-site ( username url -- )
    select-account/site 10 10 <spidering-site> delete-tuples ;

TUPLE: reporting-site site-id email url up? changed? last-up? error last-error ;

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
    "select users.email, site.url, site.up, site.changed, site.last_up, site.error, site.last_error from users, site, watching_site where users.username = watching_site.account_name and site.site_id = watching_site.site_id and site.changed = '1'" sql-query
    [ [ reporting-site boa ] input<sequence ] map
    "update site set changed = 0;" sql-command ;

: insert-account ( account-name email -- ) <account> insert-tuple ;

: find-sites ( -- seq ) f <site> select-tuples ;

: watch-site ( username url -- )
    select-account/site <watching-site> insert-tuple ;

: unwatch-site ( username url -- )
    select-account/site <watching-site> delete-tuples ;

: watching-sites ( username -- sites )
    f <watching-site> select-tuples
    [ site-id>> site new swap >>site-id select-tuple ] map ;

: site-watcher-path ( -- path ) "site-watcher.db" cache-file ; inline

: with-site-watcher-db ( quot -- )
    site-watcher-path <sqlite-db> swap with-db ; inline
