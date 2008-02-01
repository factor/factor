USING: io io.files io.launcher kernel namespaces
prettyprint tools.test db.sqlite db db.sql sequences
continuations ;
IN: temporary

! "sqlite3 -init test.txt test.db"

: test.db "extra/db/sqlite/test.db" resource-path ;

: (create-db) ( -- str )
    [
        "sqlite3 -init " %
        "extra/db/sqlite/test.txt" resource-path %
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
] [ test.db [ "select * from person" do-simple-query ] with-sqlite ] unit-test

[
    { { "John" "America" } }
] [
    test.db [
        "select * from person where name = :name and country = :country"
        { { ":name" "Jane" } { ":country" "New Zealand" } }
        <bound-statement> dup [ sql-row ] query-map

        { { "Jane" "New Zealand" } } = [ "test fails" throw ] unless
        { { ":name" "John" } { ":country" "America" } } over bind-statement

        dup [ sql-row ] query-map swap dispose
    ] with-sqlite
] unit-test

[
    {
        { "1" "John" "America" }
        { "2" "Jane" "New Zealand" }
    }
] [ test.db [ "select rowid, * from person" do-simple-query ] with-sqlite ] unit-test

[
] [
    "extra/db/sqlite/test.db" resource-path [
        "insert into person(name, country) values('Jimmy', 'Canada')"
        do-simple-command
    ] with-sqlite
] unit-test

[
    {
        { "1" "John" "America" }
        { "2" "Jane" "New Zealand" }
        { "3" "Jimmy" "Canada" }
    }
] [ test.db [ "select rowid, * from person" do-simple-query ] with-sqlite ] unit-test

[
    "extra/db/sqlite/test.db" resource-path [
        [
            "insert into person(name, country) values('Jose', 'Mexico')" do-simple-command
            "insert into person(name, country) values('Jose', 'Mexico')" do-simple-command
            "oops" throw
        ] with-transaction
    ] with-sqlite
] unit-test-fails

[ 3 ] [
    "extra/db/sqlite/test.db" resource-path [
        "select * from person" do-simple-query length
    ] with-sqlite
] unit-test

[
] [
    "extra/db/sqlite/test.db" resource-path [
        [
            "insert into person(name, country) values('Jose', 'Mexico')" do-simple-command
            "insert into person(name, country) values('Jose', 'Mexico')" do-simple-command
        ] with-transaction
    ] with-sqlite
] unit-test

[ 5 ] [
    "extra/db/sqlite/test.db" resource-path [
        "select * from person" do-simple-query length
    ] with-sqlite
] unit-test
