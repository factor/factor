USING: io io.files io.launcher kernel namespaces
prettyprint tools.test db.sqlite db sequences
continuations db.types db.tuples unicode.case ;
IN: db.sqlite.tests

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

! TEST TUPLE DB

TUPLE: puppy id name age ;
: <puppy> ( name age -- puppy )
    { set-puppy-name set-puppy-age } puppy construct ;

puppy "PUPPY" {
    { "id" "ID" +native-id+ +not-null+ }
    { "name" "NAME" { VARCHAR 256 } }
    { "age" "AGE" INTEGER }
} define-persistent

TUPLE: kitty id name age ;
: <kitty> ( name age -- kitty )
    { set-kitty-name set-kitty-age } kitty construct ;

kitty "KITTY" {
    { "id" "ID" INTEGER +assigned-id+ }
    { "name" "NAME" TEXT }
    { "age" "AGE" INTEGER }
} define-persistent

TUPLE: basket id puppies kitties ;
basket "BASKET"
{
    { "id" "ID" +native-id+ +not-null+ }
    { "location" "LOCATION" TEXT }
    { "puppies" { +has-many+ puppy } }
    { "kitties" { +has-many+ kitty } }
} define-persistent

! Create table
[
    "create table puppy(id integer primary key not null, name varchar, age integer);"
] [
    T{ sqlite-db } db [
        puppy dup db-columns swap db-table create-sql >lower
    ] with-variable
] unit-test

[
    "create table kitty(id integer primary key, name text, age integer);"
] [
    T{ sqlite-db } db [
        kitty dup db-columns swap db-table create-sql >lower
    ] with-variable
] unit-test

[
    "create table basket(id integer primary key not null, location text);"
] [
    T{ sqlite-db } db [
        basket dup db-columns swap db-table create-sql >lower
    ] with-variable
] unit-test

! Drop table
[
    "drop table puppy;"
] [
    T{ sqlite-db } db [
        puppy db-table drop-sql >lower
    ] with-variable
] unit-test

[
    "drop table kitty;"
] [
    T{ sqlite-db } db [
        kitty db-table drop-sql >lower
    ] with-variable
] unit-test

[
    "drop table basket;"
] [
    T{ sqlite-db } db [
        basket db-table drop-sql >lower
    ] with-variable
] unit-test

! Insert
[
    "insert into puppy(name, age) values(:name, :age);"
] [
    T{ sqlite-db } db [
        puppy dup db-columns swap db-table insert-sql* >lower
    ] with-variable
] unit-test

[
    "insert into kitty(id, name, age) values(:id, :name, :age);"
] [
    T{ sqlite-db } db [
        kitty dup db-columns swap db-table insert-sql* >lower
    ] with-variable
] unit-test

! Update
[
    "update puppy set name = :name, age = :age where id = :id"
] [
    T{ sqlite-db } db [
        puppy dup db-columns swap db-table update-sql* >lower
    ] with-variable
] unit-test

[
    "update kitty set name = :name, age = :age where id = :id"
] [
    T{ sqlite-db } db [
        kitty dup db-columns swap db-table update-sql* >lower
    ] with-variable
] unit-test

! Delete
[
    "delete from puppy where id = :id"
] [
    T{ sqlite-db } db [
        puppy dup db-columns swap db-table delete-sql* >lower
    ] with-variable
] unit-test

[
    "delete from kitty where id = :id"
] [
    T{ sqlite-db } db [
        kitty dup db-columns swap db-table delete-sql* >lower
    ] with-variable
] unit-test

! Select
[
    "select from puppy id, name, age where name = :name;"
    {
        T{
            sql-spec
            f
            "id"
            "ID"
            +native-id+
            { +not-null+ }
            +native-id+
        }
        T{ sql-spec f "name" "NAME" { VARCHAR 256 } { } f }
        T{ sql-spec f "age" "AGE" INTEGER { } f }
    }
] [
    T{ sqlite-db } db [
        T{ puppy f f "Mr. Clunkers" }
        select-sql >r >lower r>
    ] with-variable
] unit-test
