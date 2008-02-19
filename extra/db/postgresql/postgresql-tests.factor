! You will need to run  'createdb factor-test' to create the database.
! Set username and password in  the 'connect' word.

USING: kernel db.postgresql alien continuations io classes
prettyprint sequences namespaces tools.test db
db.tuples db.types unicode.case ;
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
            { { "Jane" TEXT } { "New Zealand" TEXT } }
            over do-bound-query

            { { "Jane" "New Zealand" } } =
            [ "test fails" throw ] unless

            { { "John" TEXT } { "America" TEXT } }
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


: with-dummy-db ( quot -- )
    >r T{ postgresql-db } db r> with-variable ;

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
    "create table puppy(id serial primary key not null, name varchar 256, age integer);"
] [
    T{ postgresql-db } db [
        puppy dup db-columns swap db-table create-table-sql >lower
    ] with-variable
] unit-test

[
    "create table kitty(id integer primary key, name text, age integer);"
] [
    T{ postgresql-db } db [
        kitty dup db-columns swap db-table create-table-sql >lower
    ] with-variable
] unit-test

[
    "create table basket(id serial primary key not null, location text);"
] [
    T{ postgresql-db } db [
        basket dup db-columns swap db-table create-table-sql >lower
    ] with-variable
] unit-test

! Create function
[
    "create function add_puppy(varchar,integer) returns bigint as 'insert into puppy(name, age) values($1, $2); select currval(''puppy_id_seq'');' language sql;"
] [
    T{ postgresql-db } db [
        puppy dup db-columns swap db-table create-function-sql >lower
    ] with-variable
] unit-test

! Drop table

[
    "drop table puppy;"
] [
    T{ postgresql-db } db [
        puppy db-table drop-table-sql >lower
    ] with-variable
] unit-test

[
    "drop table kitty;"
] [
    T{ postgresql-db } db [
        kitty db-table drop-table-sql >lower
    ] with-variable
] unit-test

[
    "drop table basket;"
] [
    T{ postgresql-db } db [
        basket db-table drop-table-sql >lower
    ] with-variable
] unit-test


! Drop function
[
    "drop function add_puppy(varchar, integer);"
] [
    T{ postgresql-db } db [
        puppy dup db-columns swap db-table drop-function-sql >lower
    ] with-variable
] unit-test

! Insert
[
    "select add_puppy($1, $2);"
    {
        T{ sql-spec f "name" "NAME" { VARCHAR 256 } { } }
        T{ sql-spec f "age" "AGE" INTEGER { } }
    }
    {
        T{ sql-spec f "id" "ID" +native-id+ { +not-null+ } +native-id+ }
    }
] [
    T{ postgresql-db } db [
        puppy dup db-columns swap db-table insert-sql* >r >r >lower r> r>
    ] with-variable
] unit-test

[
    "insert into kitty(id, name, age) values($1, $2, $3);"
    {
        T{
            sql-spec
            f
            "id"
            "ID"
            INTEGER
            { +assigned-id+ }
            +assigned-id+
        }
        T{ sql-spec f "name" "NAME" TEXT { } f }
        T{ sql-spec f "age" "AGE" INTEGER { } f }
    }
    { }
] [
    T{ postgresql-db } db [
        kitty dup db-columns swap db-table insert-sql* >r >r >lower r> r>
    ] with-variable
] unit-test

! Update
[
    "update puppy set name = $1, age = $2 where id = $3"
    {
        T{ sql-spec f "name" "NAME" { VARCHAR 256 } { } f }
        T{ sql-spec f "age" "AGE" INTEGER { } f }
        T{
            sql-spec
            f
            "id"
            "ID"
            +native-id+
            { +not-null+ }
            +native-id+
        }
    }
    { }
] [
    T{ postgresql-db } db [
        puppy dup db-columns swap db-table update-sql* >r >r >lower r> r>
    ] with-variable
] unit-test

[
    "update kitty set name = $1, age = $2 where id = $3"
    {
        T{ sql-spec f "name" "NAME" TEXT { } f }
        T{ sql-spec f "age" "AGE" INTEGER { } f }
        T{
            sql-spec
            f
            "id"
            "ID"
            INTEGER
            { +assigned-id+ }
            +assigned-id+
        }
    }
    { }
] [
    T{ postgresql-db } db [
        kitty dup db-columns swap db-table update-sql* >r >r >lower r> r>
    ] with-variable
] unit-test

! Delete
[
    "delete from puppy where id = $1"
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
    }
    { }
] [
    T{ postgresql-db } db [
        puppy dup db-columns swap db-table delete-sql* >r >r >lower r> r>
    ] with-variable
] unit-test

[
    "delete from KITTY where ID = $1"
    {
        T{
            sql-spec
            f
            "id"
            "ID"
            INTEGER
            { +assigned-id+ }
            +assigned-id+
        }
    }
    { }
] [
    T{ postgresql-db } db [
        kitty dup db-columns swap db-table delete-sql*
    ] with-variable
] unit-test

! Select
[
    "select from PUPPY ID, NAME, AGE where NAME = $1;"
    { T{ sql-spec f "name" "NAME" { VARCHAR 256 } { } f } }
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
    T{ postgresql-db } db [
        T{ puppy f f "Mr. Clunkers" }
        select-by-slots-sql
    ] with-variable
] unit-test
