! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations db db.sqlite db.tuples db.types
io.directories io.files.temp kernel ;
IN: site-watcher.db

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
