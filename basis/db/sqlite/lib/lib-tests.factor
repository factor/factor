! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: db db.sqlite db.sqlite.ffi db.sqlite.lib io.files.unique
io.pathnames kernel namespaces strings tools.test ;
IN: db.sqlite.lib.tests

{ t } [ sqlite3_libversion string? ] unit-test

{ "test.db" } [
    [
        "test.db" current-directory get prepend-path <sqlite-db>
        [ current-sqlite-filename file-name ] with-db
    ] with-test-directory
] unit-test
