! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.combinators db.pools db.sqlite db.tuples
db.types kernel math random threads tools.test db sequences
io prettyprint ;
IN: db.tester

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

: sqlite-test-db ( -- db ) "test.db" <sqlite-db> ;
: test-db ( -- db ) "test.db" <sqlite-db> ;

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
