USING: accessors arrays db db.errors db.sqlite db.tuples
db.types io.directories io.files.temp kernel layouts literals
math.parser namespaces sequences sorting splitting tools.test ;

IN: db.sqlite.tests

: normalize ( str -- str' )
    " \n" split harvest join-words ;

! delete-trigger-restrict
${
    {
        "CREATE TRIGGER fkd_TREE_NODE_NODE_ID_id "
        "BEFORE DELETE ON NODE "
        "FOR EACH ROW BEGIN "
        "SELECT RAISE(ROLLBACK, "
                      "'delete on table \"NODE\" violates "
                      "foreign key constraint \"fkd_TREE_NODE_NODE_ID_id\"') "
        "WHERE (SELECT NODE FROM TREE WHERE NODE = OLD.ID) IS NOT NULL; END;"
    } concat
} [
    {
        { "table-name" "TREE" }
        { "table-id" "NODE" }
        { "foreign-table-name" "NODE" }
        { "foreign-table-id" "ID" }
    } [ delete-trigger-restrict ] with-variables
    normalize
] unit-test

! insert-trigger
${
    {
        "CREATE TRIGGER fki_TREE_NODE_NODE_ID_id "
        "BEFORE INSERT ON TREE "
        "FOR EACH ROW BEGIN "
        "SELECT RAISE(ROLLBACK, "
                      "'insert on table \"TREE\" violates "
                      "foreign key constraint \"fki_TREE_NODE_NODE_ID_id\"') "
        "WHERE (SELECT ID FROM NODE WHERE ID = NEW.NODE) IS NULL; END;"
    } concat
} [
    {
        { "table-name" "TREE" }
        { "table-id" "NODE" }
        { "foreign-table-name" "NODE" }
        { "foreign-table-id" "ID" }
    } [ insert-trigger ] with-variables normalize
] unit-test

: db-path ( -- path ) "test-" cell number>string ".db" 3append temp-file ;
: test.db ( -- sqlite-db ) db-path <sqlite-db> ;

db-path ?delete-file

{ } [
    test.db [
        "create table person (name varchar(30), country varchar(30))" sql-command
        "insert into person values('John', 'America')" sql-command
        "insert into person values('Jane', 'New Zealand')" sql-command
    ] with-db
] unit-test


{ { { "John" "America" } { "Jane" "New Zealand" } } } [
    test.db [
        "select * from person" sql-query
    ] with-db
] unit-test

{ { { "1" "John" "America" } { "2" "Jane" "New Zealand" } } }
[ test.db [ "select rowid, * from person" sql-query ] with-db ] unit-test

{ } [
    test.db [
        "insert into person(name, country) values('Jimmy', 'Canada')"
        sql-command
    ] with-db
] unit-test

{
    {
        { "1" "John" "America" }
        { "2" "Jane" "New Zealand" }
        { "3" "Jimmy" "Canada" }
    }
} [ test.db [ "select rowid, * from person" sql-query ] with-db ] unit-test

[
    test.db [
        [
            "insert into person(name, country) values('Jose', 'Mexico')" sql-command
            "insert into person(name, country) values('Jose', 'Mexico')" sql-command
            "oops" throw
        ] with-transaction
    ] with-db
] must-fail

{ 3 } [
    test.db [
        "select * from person" sql-query length
    ] with-db
] unit-test

{ } [
    test.db [
        [
            "insert into person(name, country) values('Jose', 'Mexico')"
            sql-command
            "insert into person(name, country) values('Jose', 'Mexico')"
            sql-command
        ] with-transaction
    ] with-db
] unit-test

{ 5 } [
    test.db [
        "select * from person" sql-query length
    ] with-db
] unit-test

[ \ swap ensure-table ] must-fail

! You don't need a primary key
TUPLE: things one two ;

things "THINGS" {
    { "one" "ONE" INTEGER +not-null+ }
    { "two" "TWO" INTEGER +not-null+ }
} define-persistent

{ { { 0 0 } { 0 1 } { 1 0 } { 1 1 } } } [
    test.db [
       things create-table
        0 0 things boa insert-tuple
        0 1 things boa insert-tuple
        1 1 things boa insert-tuple
        1 0 things boa insert-tuple
        f f things boa select-tuples
        [ [ one>> ] [ two>> ] bi 2array ] map sort
       things drop-table
    ] with-db
] unit-test

! Tables can have different names than the name of the tuple
TUPLE: foo slot ;
C: <foo> foo
foo "BAR" { { "slot" "SOMETHING" INTEGER +not-null+ } } define-persistent

TUPLE: hi bye try ;
C: <hi> hi
hi "HELLO" {
    { "bye" "BUHBYE" INTEGER { +foreign-id+ foo "SOMETHING" } }
    { "try" "RETHROW" INTEGER { +foreign-id+ foo "SOMETHING" } }
} define-persistent

{ T{ foo { slot 1 } } T{ hi { bye 1 } { try 1 } } } [
    test.db [
        foo create-table
        hi create-table
        1 <foo> insert-tuple
        f <foo> select-tuple
        1 1 <hi> insert-tuple
        f f <hi> select-tuple
        hi drop-table
        foo drop-table
    ] with-db
] unit-test


! Test SQLite triggers

TUPLE: show id ;
TUPLE: user username data ;
TUPLE: watch show user ;

user "USER" {
    { "username" "USERNAME" TEXT +not-null+ +user-assigned-id+ }
    { "data" "DATA" TEXT }
} define-persistent

show "SHOW" {
    { "id" "ID" +db-assigned-id+ }
} define-persistent

watch "WATCH" {
    { "user" "USER" TEXT +not-null+ +user-assigned-id+
        { +foreign-id+ user "USERNAME" } }
    { "show" "SHOW" BIG-INTEGER +not-null+ +user-assigned-id+
        { +foreign-id+ show "ID" } }
} define-persistent

{ T{ user { username "littledan" } { data "foo" } } } [
    test.db [
        user create-table
        show create-table
        watch create-table
        "littledan" "foo" user boa insert-tuple
        "mark" "bar" user boa insert-tuple
        show new insert-tuple
        show new select-tuple
        "littledan" f user boa select-tuple
        [ id>> ] [ username>> ] bi*
        watch boa insert-tuple
        watch new select-tuple
        user>> f user boa select-tuple
        user new "mark" >>username delete-tuples
    ] with-db
] unit-test

{ } [
    test.db [ [
            user ensure-table [
                "mew" "foo" user boa insert-tuple
                "denny" "kitty" user boa insert-tuple
            ] with-transaction
        ] with-transaction
    ] with-db
] unit-test

! Reported by AlexIljin
{ f } [
    TUPLE: num-test1 num ;
    num-test1 "NUM_TEST" { { "num" "NUM" INTEGER } } define-persistent
    test.db [
        num-test1 ensure-table
        num-test1 new insert-tuple
        num-test1 new select-tuple
    ] with-db num>>
] unit-test

{ f } [
    TUPLE: num-test2 num ;
    num-test2 "NUM_TEST" { { "num" "NUM" DOUBLE } } define-persistent
    test.db [
        num-test2 ensure-table
        num-test2 new insert-tuple
        num-test2 new select-tuple
    ] with-db num>>
] unit-test

{ f } [
    TUPLE: num-test3 num ;
    num-test3 "NUM_TEST" { { "num" "NUM" BOOLEAN } } define-persistent
    test.db [
        num-test3 ensure-table
        num-test3 new insert-tuple
        num-test3 new select-tuple
    ] with-db num>>
] unit-test

[
    TUPLE: no-table name ;
    no-table "NO_TABLE" { { "name" "NAME" VARCHAR } } define-persistent
    test.db [ no-table new select-tuple ] with-db
] [ sql-table-missing? ] must-fail-with
