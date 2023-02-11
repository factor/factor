USING: accessors alien continuations db db.errors db.queries db.postgresql
db.private db.tester db.tuples db.types io classes kernel math namespaces
prettyprint sequences system tools.test unicode ;

! Triggers a two line error message (ERROR + DETAIL) because two
! connections can't simultaneously use the template1 database.
! [
    ! postgresql-template1-db [
        ! postgresql-template1-db [
            ! "will_never_exist" ensure-database
        ! ] with-db
    ! ] with-db
! ] [ sql-unknown-error? ] must-fail-with

[

    { } [
        [ "drop table person;" sql-command ] ignore-errors
        "create table person (name varchar(30), country varchar(30));"
            sql-command

        "insert into person values('John', 'America');" sql-command
        "insert into person values('Jane', 'New Zealand');" sql-command
    ] unit-test

    {
        {
            { "John" "America" }
            { "Jane" "New Zealand" }
        }
    } [ "select * from person" sql-query ] unit-test

    {
        {
            { "John" "America" }
            { "Jane" "New Zealand" }
        }
    } [ "select * from person" sql-query ] unit-test

    {
    } [
        "insert into person(name, country) values('Jimmy', 'Canada')"
        sql-command
    ] unit-test

    {
        {
            { "John" "America" }
            { "Jane" "New Zealand" }
            { "Jimmy" "Canada" }
        }
    } [ "select * from person" sql-query ] unit-test

    [
        [
            "insert into person(name, country) values('Jose', 'Mexico')" sql-command
            "insert into person(name, country) values('Jose', 'Mexico')" sql-command
            "oops" throw
        ] with-transaction
    ] must-fail

    { 3 } [ "select * from person" sql-query length ] unit-test

    {
    } [
        [
            "insert into person(name, country) values('Jose', 'Mexico')"
            sql-command
            "insert into person(name, country) values('Jose', 'Mexico')"
            sql-command
        ] with-transaction
    ] unit-test

    { 5 } [ "select * from person" sql-query length ] unit-test

] test-postgresql
