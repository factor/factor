! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors concurrency.combinators db2 db2.pools db2.types
fry io io.files.temp kernel math math.parser multiline
namespaces postgresql.db2 prettyprint random sequences
sqlite.db2 system threads tools.test ;
IN: db2.tester

/*
TUPLE: test-1 id a b c ;

test-1 "TEST1" {
   { "id" "ID" INTEGER +db-assigned-id+ }
   { "a" "A" { VARCHAR 256 } +not-null+ }
   { "b" "B" { VARCHAR 256 } +not-null+ }
   { "c" "C" { VARCHAR 256 } +not-null+ }
} make-persistent

TUPLE: test-2 id x y z ;

test-2 "TEST2" {
   { "id" "ID" INTEGER +db-assigned-id+ }
   { "x" "X" { VARCHAR 256 } +not-null+ }
   { "y" "Y" { VARCHAR 256 } +not-null+ }
   { "z" "Z" { VARCHAR 256 } +not-null+ }
} make-persistent

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
        10 iota [
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
            10 iota [
                10 [
                    test-1-tuple insert-tuple yield
                ] times
            ] parallel-each
        ] with-pooled-db
    ] bi ;
*/
