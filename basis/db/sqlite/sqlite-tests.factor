USING: io io.files io.files.temp io.directories io.launcher
kernel namespaces prettyprint tools.test db.sqlite db sequences
continuations db.types db.tuples unicode.case ;
IN: db.sqlite.tests

: db-path ( -- path ) "test.db" temp-file ;
: test.db ( -- sqlite-db ) db-path <sqlite-db> ;

[ ] [ [ db-path delete-file ] ignore-errors ] unit-test

[ ] [
    test.db [
        "create table person (name varchar(30), country varchar(30))" sql-command
        "insert into person values('John', 'America')" sql-command
        "insert into person values('Jane', 'New Zealand')" sql-command
    ] with-db
] unit-test


[ { { "John" "America" } { "Jane" "New Zealand" } } ] [
    test.db [
        "select * from person" sql-query
    ] with-db
] unit-test

[ { { "1" "John" "America" } { "2" "Jane" "New Zealand" } } ]
[ test.db [ "select rowid, * from person" sql-query ] with-db ] unit-test

[ ] [
    test.db [
        "insert into person(name, country) values('Jimmy', 'Canada')"
        sql-command
    ] with-db
] unit-test

[
    {
        { "1" "John" "America" }
        { "2" "Jane" "New Zealand" }
        { "3" "Jimmy" "Canada" }
    }
] [ test.db [ "select rowid, * from person" sql-query ] with-db ] unit-test

[
    test.db [
        [
            "insert into person(name, country) values('Jose', 'Mexico')" sql-command
            "insert into person(name, country) values('Jose', 'Mexico')" sql-command
            "oops" throw
        ] with-transaction
    ] with-db
] must-fail

[ 3 ] [
    test.db [
        "select * from person" sql-query length
    ] with-db
] unit-test

[ ] [
    test.db [
        [
            "insert into person(name, country) values('Jose', 'Mexico')"
            sql-command
            "insert into person(name, country) values('Jose', 'Mexico')"
            sql-command
        ] with-transaction
    ] with-db
] unit-test

[ 5 ] [
    test.db [
        "select * from person" sql-query length
    ] with-db
] unit-test

! You don't need a primary key
USING: accessors arrays sorting ;
TUPLE: things one two ;

things "THINGS" {
    { "one" "ONE" INTEGER +not-null+ }
    { "two" "TWO" INTEGER +not-null+ }
} define-persistent

[ { { 0 0 } { 0 1 } { 1 0 } { 1 1 } } ] [
    test.db [
       things create-table
        0 0 things boa insert-tuple
        0 1 things boa insert-tuple
        1 1 things boa insert-tuple
        1 0 things boa insert-tuple
        f f things boa select-tuples
        [ [ one>> ] [ two>> ] bi 2array ] map natural-sort
       things drop-table
    ] with-db
] unit-test
