USING: accessors alien continuations db db.queries db.postgresql db.private
db.tester db.tuples db.types io classes kernel math namespaces prettyprint
sequences system tools.test unicode.case ;
IN: db.postgresql.tests

: nonexistant-db ( -- db )
    <postgresql-db>
        "localhost" >>host
        "fake-user" >>username
        "no-pass" >>password
        "dont-exist" >>database ;

! Don't leak connections
[ ] [
    2000 [ [ nonexistant-db [ ] with-db ] ignore-errors ] times
] unit-test

! Ensure the test database exists
[ ] [ postgresql-test-db [ ] with-db ] unit-test

[ ] [
    postgresql-test-db [
        [ "drop table person;" sql-command ] ignore-errors
        "create table person (name varchar(30), country varchar(30));"
            sql-command

        "insert into person values('John', 'America');" sql-command
        "insert into person values('Jane', 'New Zealand');" sql-command
    ] with-db
] unit-test

[
    {
        { "John" "America" }
        { "Jane" "New Zealand" }
    }
] [
    postgresql-test-db [
        "select * from person" sql-query
    ] with-db
] unit-test

[
    {
        { "John" "America" }
        { "Jane" "New Zealand" }
    }
] [ postgresql-test-db [ "select * from person" sql-query ] with-db ] unit-test

[
] [
    postgresql-test-db [
        "insert into person(name, country) values('Jimmy', 'Canada')"
        sql-command
    ] with-db
] unit-test

[
    {
        { "John" "America" }
        { "Jane" "New Zealand" }
        { "Jimmy" "Canada" }
    }
] [ postgresql-test-db [ "select * from person" sql-query ] with-db ] unit-test

[
    postgresql-test-db [
        [
            "insert into person(name, country) values('Jose', 'Mexico')" sql-command
            "insert into person(name, country) values('Jose', 'Mexico')" sql-command
            "oops" throw
        ] with-transaction
    ] with-db
] must-fail

[ 3 ] [
    postgresql-test-db [
        "select * from person" sql-query length
    ] with-db
] unit-test

[
] [
    postgresql-test-db [
        [
            "insert into person(name, country) values('Jose', 'Mexico')"
            sql-command
            "insert into person(name, country) values('Jose', 'Mexico')"
            sql-command
        ] with-transaction
    ] with-db
] unit-test

[ 5 ] [
    postgresql-test-db [
        "select * from person" sql-query length
    ] with-db
] unit-test
