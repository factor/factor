! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
alien.syntax arrays assocs classes.struct combinators
constructors continuations destructors forestdb.ffi
forestdb.utils fry generalizations io.directories
io.encodings.string io.encodings.utf8 io.files.temp io.pathnames
kernel libc make math math.parser math.ranges multiline
namespaces sequences tools.test ;
IN: forestdb.lib

{ } [ [ delete-test-db-0 ] ignore-errors ] unit-test
{ } [ [ delete-test-db-1 ] ignore-errors ] unit-test

! Get/set by key/value
{ "val123" } [
    delete-test-db-0
    test-db-0 [
       "key123" "val123" fdb-set-kv
       "key123" fdb-get-kv
    ] with-forestdb-path
] unit-test

{ "val12345" } [
    delete-test-db-0
    test-db-0 [
       "key123" "val12345" fdb-set-kv
       "key123" fdb-get-kv
    ] with-forestdb-path
] unit-test

! Get

{
    { "key1" "val" }
} [
    delete-test-db-1 test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        "key1" "meta" "val" [
            fdb_doc>doc [ key>> ] [ body>> ] bi 2array
        ] with-create-doc
    ] with-forestdb-path
] unit-test

{
    { "key1" f "val1" }
} [
    delete-test-db-1 test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        "key1" "no meta" "going away" [
            fdb-get
            fdb_doc>doc [ key>> ] [ meta>> ] [ body>> ] tri 3array
        ] with-create-doc
    ] with-forestdb-path
] unit-test


{
    { "key2" f "val2" }
} [
    delete-test-db-1 test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        2 <seqnum-doc> [
            fdb-get-byseq fdb_doc>doc
            [ key>> ] [ meta>> ] [ body>> ] tri 3array
        ] with-doc
    ] with-forestdb-path
] unit-test

{
    { "key2" f "val2" }
} [
    delete-test-db-1 test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        2 <seqnum-doc> [
            fdb-get-byseq fdb_doc>doc
            [ key>> ] [ meta>> ] [ body>> ] tri 3array
        ] with-doc
    ] with-forestdb-path
] unit-test


! Filename is only valid inside with-forestdb
{ f } [
    delete-test-db-0
    test-db-0 [
        fdb-get-info filename>> alien>native-string empty?
    ] with-forestdb-path
] unit-test

! Test fdb_doc_create
{ 6 9 9 } [
    delete-test-db-0
    test-db-0 [
       "key123" "meta blah" "some body" [
            [ keylen>> ] [ metalen>> ] [ bodylen>> ] tri
        ] with-create-doc
    ] with-forestdb-path
] unit-test

{ 7 8 15 } [
    delete-test-db-0
    test-db-0 [
       "key1234" "meta blah" "some body" [
            [ "new meta" "some other body" fdb-doc-update ]
            [ [ keylen>> ] [ metalen>> ] [ bodylen>> ] tri ] bi
        ] with-create-doc
    ] with-forestdb-path
] unit-test

{ 1 1 } [
    delete-test-db-1
    test-db-1 [
        1 set-kv-n
        fdb-commit-normal
        fdb-get-seqnum
        fdb-get-info doc_count>>
    ] with-forestdb-path
] unit-test

{ 6 5 } [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        5 set-kv-nth
        fdb-commit-normal
        fdb-get-seqnum
        fdb-get-info doc_count>>
    ] with-forestdb-path
] unit-test

{ 5 5 } [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        fdb-get-seqnum
        fdb-get-info doc_count>>
    ] with-forestdb-path
] unit-test

! Snapshots
{ 5 5 } [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        5 [
            fdb-get-seqnum
            fdb-get-info doc_count>>
        ] with-forestdb-snapshot
    ] with-forestdb-path
] unit-test

/*
! Snapshots can only occur on commits. If you commit five keys at once,
! and then try to open a snapshot on the second key, it should fail.

! XXX: Buggy, fails in _fdb_open with FDB_RESULT_NO_DB_INSTANCE
[
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        2 [
            fdb-get-seqnum
            fdb-get-info doc_count>>
        ] with-forestdb-snapshot
    ] with-forestdb-path
] [
    T{ fdb-error { error FDB_RESULT_NO_DB_INSTANCE } } =
] must-fail-with
*/

! Test that we take two snapshots and their seqnums/doc counts are right.
! XXX: Buggy, want to see the first snapshot's document count at 5 too
{
    { 5 7 }
    { 7 7 }
} [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal

        6 7 set-kv-range
        fdb-commit-normal

        5 [
            fdb-get-seqnum
            fdb-get-info doc_count>> 2array
        ] with-forestdb-snapshot

        7 [
            fdb-get-seqnum
            fdb-get-info doc_count>> 2array
        ] with-forestdb-snapshot
    ] with-forestdb-path
] unit-test

! Same test as above, but with buggy behavior for now so it passes
{
    5
    7
} [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal

        6 7 set-kv-range
        fdb-commit-normal

        5 [
            fdb-get-seqnum
        ] with-forestdb-snapshot

        7 [
            fdb-get-seqnum
        ] with-forestdb-snapshot
    ] with-forestdb-path
] unit-test


! Rollback test
! Make sure the doc_count is correct after a rollback
! XXX: doc_count is wrong after rollback
{
    7
    { 5 12 }
    ! { 5 5 } ! expected
} [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal

        6 7 set-kv-range
        fdb-commit-normal

        7 [
            fdb-get-seqnum
        ] with-forestdb-snapshot

        5 fdb-rollback

        5 [
            fdb-get-seqnum
            fdb-get-info doc_count>> 2array
        ] with-forestdb-snapshot
    ] with-forestdb-path
] unit-test


! Iterators test
! No matching keys
{
    { }
} [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        [
            "omg" "nada" [
                  fdb_doc>doc [ seqnum>> ] [ key>> ] [ body>> ] tri 3array ,
            ] with-fdb-normal-iterator
        ] { } make
    ] with-forestdb-path
] unit-test

! All the keys
{
    {
        { 1 "key1" "val1" }
        { 2 "key2" "val2" }
        { 3 "key3" "val3" }
        { 4 "key4" "val4" }
        { 5 "key5" "val5" }
    }
} [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        [
            "key1" "key5" [
                  fdb_doc>doc [ seqnum>> ] [ key>> ] [ body>> ] tri 3array ,
            ] with-fdb-normal-iterator
        ] { } make
    ] with-forestdb-path
] unit-test

! Test that keys at extremes get returned
{
    {
        { 1 "key1" "val1" }
    }
} [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        [
            "key0" "key1" [
                  fdb_doc>doc [ seqnum>> ] [ key>> ] [ body>> ] tri 3array ,
            ] with-fdb-normal-iterator
        ] { } make
    ] with-forestdb-path
] unit-test

{
    {
        { 5 "key5" "val5" }
    }
} [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        [
            "key5" "key9" [
                  fdb_doc>doc [ seqnum>> ] [ key>> ] [ body>> ] tri 3array ,
            ] with-fdb-normal-iterator
        ] { } make
    ] with-forestdb-path
] unit-test


{
    {
        { 1 "key1" }
        { 2 "key2" }
        { 3 "key3" }
        { 4 "key4" }
        { 5 "key5" }
    }
} [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        [
            0 10 [
                [ seqnum>> ]
                [ [ key>> ] [ keylen>> ] bi alien/length>string ] bi 2array ,
            ] with-fdb-byseq-each
        ] { } make
    ] with-forestdb-path
] unit-test

! Test byseq mapping
{
    V{ 1 2 3 4 5 }
} [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        0 10 [
            fdb_doc>doc
        ] with-fdb-byseq-map
        [ seqnum>> ] map
    ] with-forestdb-path
] unit-test

! Deleting 5 keys gives you 5 new seqnums that are those docs, but deleted
{
    V{ { 6 t } { 7 t } { 8 t } { 9 t } { 10 t } }
} [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        5 del-kv-n
        fdb-commit-normal
        0 10 [
            fdb_doc>doc
        ] with-fdb-byseq-map
        [ [ seqnum>> ] [ deleted?>> ] bi 2array ] map
    ] with-forestdb-path
] unit-test
