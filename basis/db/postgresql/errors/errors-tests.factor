! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit db db.errors
db.postgresql db.postgresql.errors io.files.unique kernel
namespaces tools.test db.tester continuations ;

[

    [ "drop table foo;" sql-command ] ignore-errors
    [ "drop table ship;" sql-command ] ignore-errors

    [
        "insert into foo (id) values('1');" sql-command
    ] [
        { [ sql-table-missing? ] [ table>> "foo" = ] } 1&&
    ] must-fail-with

    [
        "create table ship(id integer);" sql-command
        "create table ship(id integer);" sql-command
    ] [
        { [ sql-table-exists? ] [ table>> "ship" = ] } 1&&
    ] must-fail-with

    [
        "create table foo(id) lol;" sql-command
    ] [
        sql-syntax-error?
    ] must-fail-with

] test-postgresql
