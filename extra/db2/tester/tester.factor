! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.combinators db2.connections
db2.pools db2.sqlite db2.types fry io.files.temp kernel math
namespaces random threads tools.test combinators ;
IN: db2.tester
USE: multiline

: sqlite-test-db ( -- sqlite-db )
    "tuples-test.db" temp-file <sqlite-db> ;

! These words leak resources, but are useful for interactivel testing
: set-sqlite-db ( -- )
    sqlite-db db-open db-connection set ;

: test-sqlite ( quot -- )
    '[
        [ ] [ sqlite-test-db _ with-db ] unit-test
    ] call ; inline

: test-dbs ( quot -- )
    {
        [ test-sqlite ]
    } cleave ;

/*
: postgresql-test-db ( -- postgresql-db )
    <postgresql-db>
        "localhost" >>host
        "postgres" >>username
        "thepasswordistrust" >>password
        "factor-test" >>database ;

: set-postgresql-db ( -- )
    postgresql-db db-open db-connection set ;

: test-postgresql ( quot -- )
    '[
        os windows? cpu x86.64? and [
            [ ] [ postgresql-test-db _ with-db ] unit-test
        ] unless
    ] call ; inline

TUPLE: test-1 id a b c ;

test-1 "TEST1" {
   { "id" "ID" INTEGER +db-assigned-id+ }
   { "a" "A" { VARCHAR 256 } +not-null+ }
   { "b" "B" { VARCHAR 256 } +not-null+ }
   { "c" "C" { VARCHAR 256 } +not-null+ }
} define-persistent

TUPLE: test-2 id x y z ;

test-2 "TEST2" {
   { "id" "ID" INTEGER +db-assigned-id+ }
   { "x" "X" { VARCHAR 256 } +not-null+ }
   { "y" "Y" { VARCHAR 256 } +not-null+ }
   { "z" "Z" { VARCHAR 256 } +not-null+ }
} define-persistent

: db-tester ( test-db -- )
    [
        [
            test-1 ensure-table
            test-2 ensure-table
        ] with-db
    ] [
        10 [
            drop
            10 [
                dup [
                    f 100 random 100 random 100 random test-1 boa
                    insert-tuple yield
                ] with-db
            ] times
        ] with parallel-each
    ] bi ;

: db-tester2 ( test-db -- )
    [
        [
            test-1 ensure-table
            test-2 ensure-table
        ] with-db
    ] [
        <db-pool> [
            10 [
                10 [
                    f 100 random 100 random 100 random test-1 boa
                    insert-tuple yield
                ] times
            ] parallel-each
        ] with-pooled-db
    ] bi ;
*/
