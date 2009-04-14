! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test db2.statements kernel db2 db2.tester
continuations db2.errors accessors db2.types ;
IN: db2.statements.tests

{ 1 0 } [ [ drop ] result-set-each ] must-infer-as
{ 1 1 } [ [ ] result-set-map ] must-infer-as

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
        "select name, os from computer;"
        f f <statement> sql-query
    ] unit-test

    [ "insert into" sql-command ]
    [ sql-syntax-error? ] must-fail-with

    [ "selectt" sql-query ]
    [ sql-syntax-error? ] must-fail-with

    [ ] [
        "insert into computer (name, os) values(?, ?);"
        { "clubber" "windows" }
        f <statement>
        sql-bind-command
    ] unit-test

    [ { { "windows" } } ] [
        "select os from computer where name = ?;"
        { "clubber" } f <statement> sql-bind-query
    ] unit-test

    [ { { "windows" } } ] [
        "select os from computer where name = ?;"
        { { VARCHAR "clubber" } }
        { VARCHAR }
        <statement> sql-bind-typed-query
    ] unit-test

    [ ] [
        "insert into computer (name, os) values(?, ?);"
        {
            { VARCHAR "clubber" }
            { VARCHAR "windows" }
        } f <statement>
        sql-bind-typed-command
    ] unit-test


    ;

[ test-sql-command ] test-dbs
