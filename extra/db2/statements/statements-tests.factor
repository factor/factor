! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test db2.statements kernel db2 db2.tester
continuations db2.errors accessors db2.types ;
IN: db2.statements.tests

{ 1 0 } [ [ drop ] statement-each ] must-infer-as
{ 1 1 } [ [ ] statement-map ] must-infer-as

: create-computer-table ( -- )
    [ "drop table computer;" sql-command ] ignore-errors

    [ "drop table computer;" sql-command ]
    [ [ sql-table-missing? ] [ table>> "computer" = ] bi and ] must-fail-with

    [ ] [
        "create table computer(name varchar, os varchar);"
        sql-command
    ] unit-test ;


: test-sql-command ( -- )
    create-computer-table
    
    [ ] [
        "insert into computer (name, os) values('rocky', 'mac');"
        sql-command
    ] unit-test
    
    [ { { "rocky" "mac" } } ]
    [
        "select name, os from computer;" sql-query
    ] unit-test

    [ "insert into" sql-command ]
    [ sql-syntax-error? ] must-fail-with

    [ "selectt" sql-query ]
    [ sql-syntax-error? ] must-fail-with

    [ ] [
        { "clubber" "windows" }
        "insert into computer (name, os) values(?, ?);"
        sql-bind-command*
    ] unit-test

    [ { { "windows" } } ] [
        { "clubber" }
        "select os from computer where name = ?;" sql-bind-query*
    ] unit-test

    [ { { "windows" } } ] [
        { { VARCHAR "clubber" } }
        "select os from computer where name = ?;" sql-bind-typed-query*
    ] unit-test

    [ ] [
        {
            { VARCHAR "clubber" }
            { VARCHAR "windows" }
        }
        "insert into computer (name, os) values(?, ?);"
        sql-bind-typed-command*
    ] unit-test


    ;

[ test-sql-command ] test-dbs
