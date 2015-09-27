! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit db db.errors
db.errors.sqlite db.sqlite io.files.unique kernel namespaces
tools.test ;
IN: db.errors.sqlite.tests

: sqlite-error-test-db-path ( -- path )
    "sqlite" "error-test" make-unique-file ;

sqlite-error-test-db-path <sqlite-db> [

    [
        "insert into foo (id) values('1');" sql-command
    ] [
        { [ sql-table-missing? ] [ table>> "foo" = ] } 1&&
    ] must-fail-with

    [
        "create table foo(id);" sql-command
        "create table foo(id);" sql-command
    ] [
        { [ sql-table-exists? ] [ table>> "foo" = ] } 1&&
    ] must-fail-with

] with-db
