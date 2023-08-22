! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit db db.errors
db.sqlite kernel locals tools.test ;

[| path |

    path <sqlite-db> [

        [
            "insert into foo (id) values('1');" sql-command
        ] [
            { [ sql-table-missing? ] [ table>> "foo" = ] } 1&&
        ] must-fail-with

        "create table foo(id);" sql-command

        [
            "create table foo(id);" sql-command
        ] [
            { [ sql-table-exists? ] [ table>> "foo" = ] } 1&&
        ] must-fail-with

        "create index main_index on foo(id);" sql-command

        [
            "create index main_index on foo(id);" sql-command
        ] [
            { [ sql-index-exists? ] [ name>> "main_index" = ] } 1&&
        ] must-fail-with

    ] with-db
] with-test-file
