USING: io io.files io.launcher kernel namespaces
prettyprint tools.test db.sqlite db sequences
continuations db.types ;
IN: temporary

: test.db "extra/db/sqlite/test.db" resource-path ;

[ ] [ [ test.db delete-file ] ignore-errors ] unit-test

[ ] [
    test.db [
        "create table person (name varchar(30), country varchar(30))" sql-command
        "insert into person values('John', 'America')" sql-command
        "insert into person values('Jane', 'New Zealand')" sql-command
    ] with-sqlite
] unit-test


[ { { "John" "America" } { "Jane" "New Zealand" } } ] [
    test.db [
        "select * from person" sql-query
    ] with-sqlite
] unit-test

[ { { "John" "America" } } ] [
    test.db [
        "select * from person where name = :name and country = :country"
        <simple-statement> [
            { { ":name" "Jane" TEXT } { ":country" "New Zealand" TEXT } }
            over do-bound-query

            { { "Jane" "New Zealand" } } =
            [ "test fails" throw ] unless

            { { ":name" "John" TEXT } { ":country" "America" TEXT } }
            swap do-bound-query
        ] with-disposal
    ] with-sqlite
] unit-test

[ { { "1" "John" "America" } { "2" "Jane" "New Zealand" } } ]
[ test.db [ "select rowid, * from person" sql-query ] with-sqlite ] unit-test

[ ] [
    test.db [
        "insert into person(name, country) values('Jimmy', 'Canada')"
        sql-command
    ] with-sqlite
] unit-test

[
    {
        { "1" "John" "America" }
        { "2" "Jane" "New Zealand" }
        { "3" "Jimmy" "Canada" }
    }
] [ test.db [ "select rowid, * from person" sql-query ] with-sqlite ] unit-test

[
    test.db [
        [
            "insert into person(name, country) values('Jose', 'Mexico')" sql-command
            "insert into person(name, country) values('Jose', 'Mexico')" sql-command
            "oops" throw
        ] with-transaction
    ] with-sqlite
] must-fail

[ 3 ] [
    test.db [
        "select * from person" sql-query length
    ] with-sqlite
] unit-test

[
] [
    test.db [
        [
            "insert into person(name, country) values('Jose', 'Mexico')"
            sql-command
            "insert into person(name, country) values('Jose', 'Mexico')"
            sql-command
        ] with-transaction
    ] with-sqlite
] unit-test

[ 5 ] [
    test.db [
        "select * from person" sql-query length
    ] with-sqlite
] unit-test
