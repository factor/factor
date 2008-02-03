USING: io io.files io.launcher kernel namespaces
prettyprint tools.test db.sqlite db db.sql sequences
continuations ;
IN: temporary

! "sqlite3 -init test.txt test.db"

IN: scratchpad
: test.db "extra/db/sqlite/test.db" resource-path ;

IN: temporary
: (create-db) ( -- str )
    [
        "sqlite3 -init " %
        test.db %
        " " %
        test.db %
    ] "" make ;

: create-db ( -- ) (create-db) run-process drop ;

[ ] [ test.db delete-file ] unit-test

[ ] [ create-db ] unit-test

[
    {
        { "John" "America" }
        { "Jane" "New Zealand" }
    }
] [
    test.db [
        "select * from person" sql-query
    ] with-sqlite
] unit-test

[
    { { "John" "America" } }
] [
    test.db [
        "select * from person where name = :name and country = :country"
        <simple-statement> [
            { { ":name" "Jane" } { ":country" "New Zealand" } }
            over do-bound-query

            { { "Jane" "New Zealand" } } =
            [ "test fails" throw ] unless

            { { ":name" "John" } { ":country" "America" } }
            swap do-bound-query
        ] with-disposal
    ] with-sqlite
] unit-test

[
    {
        { "1" "John" "America" }
        { "2" "Jane" "New Zealand" }
    }
] [ test.db [ "select rowid, * from person" sql-query ] with-sqlite ] unit-test

[
] [
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
] unit-test-fails

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
