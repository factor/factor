! Copyright (C) 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs couchdb hashtables kernel namespaces
random.data sequences strings tools.test ;
IN: couchdb.tests

! You must have a CouchDB server (currently only the version from svn will
! work) running on localhost and listening on the default port for these tests
! to work.

<default-server> "factor-test" <db> [
    [ ] [ couch get ensure-db ] unit-test
    [ couch get create-db ] must-fail
    [ ] [ couch get delete-db ] unit-test
    [ couch get delete-db ] must-fail
    [ ] [ couch get ensure-db ] unit-test
    [ ] [ couch get ensure-db ] unit-test
    [ 0 ] [ couch get db-info "doc_count" of ] unit-test
    [ ] [ couch get compact-db ] unit-test
    [ t ] [ couch get server>> next-uuid string? ] unit-test
    [ ] [ H{
            { "Subject" "I like Planktion" }
            { "Tags" { "plankton" "baseball" "decisions" } }
            { "Body"
              "I decided today that I don't like baseball. I like plankton." }
            { "Author" "Rusty" }
            { "PostedDate" "2006-08-15T17:30:12Z-04:00" }
           } save-doc ] unit-test
    [ t ] [ couch get all-docs "rows" of first "id" of dup "id" set string? ] unit-test
    [ t ] [ "id" get dup load-doc id> = ] unit-test
    [ ] [ "id" get load-doc save-doc ] unit-test
    [ "Rusty" ] [ "id" get load-doc "Author" of ] unit-test
    [ ] [ "id" get load-doc "Alex" "Author" pick set-at save-doc ] unit-test
    [ "Alex" ] [ "id" get load-doc "Author" of ] unit-test
    [ 1 ] [ "function(doc) { emit(null, doc) }" temp-view-map "total_rows" of ] unit-test
    [ ] [ H{
         { "_id" "_design/posts" }
         { "language" "javascript" }
         { "views" H{
             { "all" H{ { "map" "function(doc) { emit(null, doc) }" } } }
           }
         }
       } save-doc ] unit-test
    [ t ] [ "id" get load-doc delete-doc string? ] unit-test
    [ "id" get load-doc ] must-fail

    { t } [
        "oga" "boga" associate
        couch get db-url 10 random-string append
        couch-put "ok" of
    ] unit-test

    [ ] [ couch get delete-db ] unit-test
] with-couch
