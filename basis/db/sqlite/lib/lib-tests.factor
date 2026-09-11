! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: db db.sqlite db.sqlite.ffi db.sqlite.lib destructors
io.files.unique io.pathnames kernel math namespaces sets strings
tools.test ;
IN: db.sqlite.lib.tests

{ t } [ sqlite3_libversion string? ] unit-test

{ "test.db" } [
    [
        "test.db" current-directory get prepend-path <sqlite-db>
        [ current-sqlite-filename file-name ] with-db
    ] with-test-directory
] unit-test

{ t } [
    [
        "test.db" <sqlite-db> [
            "create table unique_values (value integer unique)" sql-command
            "insert into unique_values values (1)" sql-command
            disposables get cardinality
            [ "insert into unique_values values (1)" sql-command ] must-fail
            disposables get cardinality =
        ] with-db
    ] with-test-directory
] unit-test

! sqlite3_open returns an allocated handle even for SQLITE_CANTOPEN.
! Repeated failures must not accumulate SQLite allocations.
{ t } [
    [
        sqlite3_memory_used
        10 [
            [ "missing/test.db" sqlite-open sqlite-close ]
            [ sqlite-error? ] must-fail-with
        ] times
        sqlite3_memory_used =
    ] with-test-directory
] unit-test
