! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test db2.statements kernel db2 db2.tester
continuations db2.errors ;
IN: db2.statements.tests

{ 1 0 } [ [ drop ] statement-each ] must-infer-as
{ 1 1 } [ [ ] statement-map ] must-infer-as


: test-sql-command ( -- )
    [ "drop table computer;" sql-command ] ignore-errors

    [ ] [
        "create table computer(name varchar, os varchar);"
        sql-command
    ] unit-test
    
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

    ;

[ test-sql-command ] test-dbs

