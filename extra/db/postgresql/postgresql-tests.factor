! You will need to run  'createdb factor-test' to create the database.
! Set username and password in  the 'connect' word.

USING: kernel db.postgresql alien continuations io prettyprint
sequences namespaces tools.test db ;
IN: temporary

IN: scratchpad
: test-db ( -- postgresql-db )
    "localhost" "postgres" "" "factor-test" <postgresql-db> ;
IN: temporary

[ ] [ test-db [ ] with-db ] unit-test

[ ] [
    test-db [
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
    test-db [
        "select * from person" sql-query
    ] with-db
] unit-test

[
    { { "John" "America" } }
] [
    test-db [
        "select * from person where name = $1 and country = $2"
        <simple-statement> [
            { "Jane" "New Zealand" }
            over do-bound-query

            { { "Jane" "New Zealand" } } =
            [ "test fails" throw ] unless

            { "John" "America" }
            swap do-bound-query
        ] with-disposal
    ] with-db
] unit-test

[
    {
        { "John" "America" }
        { "Jane" "New Zealand" }
    }
] [ test-db [ "select * from person" sql-query ] with-db ] unit-test

[
] [
    test-db [
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
] [ test-db [ "select * from person" sql-query ] with-db ] unit-test

[
    test-db [
        [
            "insert into person(name, country) values('Jose', 'Mexico')" sql-command
            "insert into person(name, country) values('Jose', 'Mexico')" sql-command
            "oops" throw
        ] with-transaction
    ] with-db
] must-fail

[ 3 ] [
    test-db [
        "select * from person" sql-query length
    ] with-db
] unit-test

[
] [
    test-db [
        [
            "insert into person(name, country) values('Jose', 'Mexico')"
            sql-command
            "insert into person(name, country) values('Jose', 'Mexico')"
            sql-command
        ] with-transaction
    ] with-db
] unit-test

[ 5 ] [
    test-db [
        "select * from person" sql-query length
    ] with-db
] unit-test
