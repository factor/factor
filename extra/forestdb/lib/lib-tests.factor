! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings arrays
assocs combinators continuations destructors forestdb.ffi fry
io.directories io.files.temp io.pathnames kernel libc make
math.parser math.ranges multiline namespaces sequences
tools.test classes.struct ;
IN: forestdb.lib

: test-db-0 ( -- path ) "0.forestdb.0" temp-file ;
: test-db-1 ( -- path ) "1.forestdb.0" temp-file ;

: delete-test-db-0 ( -- ) [ test-db-0 delete-file ] ignore-errors ;
: delete-test-db-1 ( -- ) [ test-db-1 delete-file ] ignore-errors ;

: make-kv-nth ( n -- key val )
    number>string [ "key" prepend ] [ "val" prepend ] bi ;

: make-kv-n ( n -- seq )
    [1,b] [ make-kv-nth ] { } map>assoc ;

: make-kv-range ( a b -- seq )
    [a,b] [ make-kv-nth ] { } map>assoc ;

: set-kv-n ( n -- )
    make-kv-n [ fdb-set-kv ] assoc-each ;

: set-kv-nth ( n -- )
    make-kv-nth fdb-set-kv ;

: set-kv-range ( a b -- )
    make-kv-range [ fdb-set-kv ] assoc-each ;


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
        fdb-info filename>> alien>native-string empty?
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

! Snapshots

{ 1 1 } [
    delete-test-db-1
    test-db-1 [
        1 set-kv-n
        fdb-commit-normal
        fdb-info [ last_seqnum>> ] [ doc_count>> ] bi
    ] with-forestdb-path
] unit-test

{ 6 5 } [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        5 set-kv-nth
        fdb-commit-normal
        fdb-info [ last_seqnum>> ] [ doc_count>> ] bi
    ] with-forestdb-path
] unit-test

{ 5 5 } [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        fdb-info [ last_seqnum>> ] [ doc_count>> ] bi
    ] with-forestdb-path
] unit-test

{ 5 5 } [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        5 fdb-open-snapshot [
            fdb-info [ last_seqnum>> ] [ doc_count>> ] bi
        ] with-forestdb-snapshot
    ] with-forestdb-path
] unit-test


! Snapshots can only occur on commits. If you commit five keys at once,
! and then try to open a snapshot on the second key, it should fail.
[
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal
        2 fdb-open-snapshot [
            fdb-info [ last_seqnum>> ] [ doc_count>> ] bi
        ] with-forestdb-snapshot
    ] with-forestdb-path
] [
    T{ fdb-error { error FDB_RESULT_NO_DB_INSTANCE } } =
] must-fail-with

! Test that we take two snapshots and their seqnums/doc counts are right.
! XXX: We test this to make sure the forestdb doesn't change.
! Bug in forestdb? doc_count>> should be 5 at snapshot 5
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

        5 fdb-open-snapshot [
            fdb-info [ last_seqnum>> ] [ doc_count>> ] bi 2array
        ] with-forestdb-snapshot

        7 fdb-open-snapshot [
            fdb-info [ last_seqnum>> ] [ doc_count>> ] bi 2array
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

        5 fdb-open-snapshot [
            fdb-info last_seqnum>>
        ] with-forestdb-snapshot

        7 fdb-open-snapshot [
            fdb-info last_seqnum>>
        ] with-forestdb-snapshot
    ] with-forestdb-path
] unit-test


! Rollback test
! Make sure the doc_count is correct after a rollback
{
    7
    { 5 5 }
} [
    delete-test-db-1
    test-db-1 [
        5 set-kv-n
        fdb-commit-normal

        6 7 set-kv-range
        fdb-commit-normal

        7 fdb-open-snapshot [
            fdb-info last_seqnum>>
        ] with-forestdb-snapshot

        5 fdb-rollback

        5 fdb-open-snapshot [
            fdb-info [ last_seqnum>> ] [ doc_count>> ] bi 2array
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
            ] with-fdb-byseq-iterator
        ] { } make
    ] with-forestdb-path
] unit-test
