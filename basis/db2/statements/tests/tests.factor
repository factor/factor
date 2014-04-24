! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations db2 db2.debug db2.errors
db2.result-sets db2.statements db2.types kernel multiline
tools.test ;
IN: db2.statements.tests

{ 1 0 } [ [ drop ] result-set-each ] must-infer-as
{ 1 1 } [ [ ] result-set-map ] must-infer-as

: create-computer-table ( -- )
    [ "drop table computer;" sql-command ] ignore-errors

    ! [ "drop table computer;" sql-command ]
    ! [ [ sql-table-missing? ] [ table>> "computer" = ] bi and ] must-fail-with

    [ "drop table computer;" sql-command ] must-fail

    [ ] [
        "create table computer(name varchar, os varchar, version integer);"
        sql-command
    ] unit-test ;

: test-sql-command ( -- )
    create-computer-table

    [ ] [
        "insert into computer (name, os) values('rocky', 'mac');"
        sql-command
    ] unit-test

    [ ] [
        <statement>
            "insert into computer (name, os) values('vio', 'opp');" >>sql
        sql-command
    ] unit-test

    [ { { "rocky" "mac" } { "vio" "opp" } } ]
    [
        <statement>
            "select name, os from computer;" >>sql
        sql-query
    ] unit-test

    ! [ "insert into" sql-command ] [ sql-syntax-error? ] must-fail-with

    ! [ "selectt" sql-query drop ] [ sql-syntax-error? ] must-fail-with

    [ "drop table default_person" sql-command ] ignore-errors

    [ ] [
        <statement>
            "create table default_person(id serial primary key, name text, birthdate timestamp, email text, homepage text)" >>sql
        sql-command
    ] unit-test ;

[ test-sql-command ] test-dbs
