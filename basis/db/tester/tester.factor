! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs concurrency.combinators db db.pools
db.postgresql db.queries db.sqlite db.tuples db.types
destructors io.files.temp io.pools kernel math math.parser
namespaces random sequences system threads tools.test ;
IN: db.tester

: postgresql-test-db-name ( -- string )
    os name>> cpu name>> "-" glue "-factor-test" append
    H{ { CHAR: - CHAR: _ } { CHAR: . CHAR: _ } } substitute ;

: postgresql-test-db ( -- postgresql-db )
    \ postgresql-db get-global clone postgresql-test-db-name >>database ;

: postgresql-template1-db ( -- postgresql-db )
    \ postgresql-db get-global clone "template1" >>database ;

: sqlite-test-db ( -- sqlite-db )
    cpu name>> "tuples-test." ".db" surround
    temp-file <sqlite-db> ;

! These words leak resources, but are useful for interactive testing
: set-sqlite-db ( -- )
    sqlite-db db-open db-connection set ;

: set-postgresql-db ( -- )
    postgresql-db db-open db-connection set ;


: test-sqlite ( quot -- )
    '[
        [ ] [ sqlite-test-db _ with-db ] unit-test
    ] call ; inline

: test-postgresql ( quot -- )
    '[
        ! disable on windows-x86-32
        os windows? cpu x86.32? and [
            postgresql-template1-db [
                postgresql-test-db-name ensure-database
            ] with-db
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

: test-1-tuple ( -- tuple )
    f 100 random 100 random 100 random [ number>string ] tri@
    test-1 boa ;

: db-tester ( test-db -- )
    [
        [
            test-1 ensure-table
            test-2 ensure-table
        ] with-db
    ] [
        10 <iota> [
            drop
            10 [
                dup [
                    test-1-tuple insert-tuple yield
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
        [
            pool get [
                10 <iota> [
                    10 [
                        test-1-tuple insert-tuple yield
                    ] times
                ] parallel-each
            ] with-db-pooled-connection
        ] with-db-pool
    ] bi ;
