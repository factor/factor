! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.combinators db db.pools db.sqlite db.tuples
db.types destructors kernel math random threads tools.test sequences
io io.pools prettyprint db.postgresql accessors io.files.temp
namespaces fry system math.parser db.queries assocs ;
IN: db.tester

: postgresql-test-db-name ( -- string )
    cpu name>> "-" "factor-test" 3append
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
        os windows? cpu x86.64? and [
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
        <db-pool> [
            [
                10 <iota> [
                    10 [
                        test-1-tuple insert-tuple yield
                    ] times
                ] parallel-each
            ] with-pooled-db
        ] with-disposal
    ] bi ;
