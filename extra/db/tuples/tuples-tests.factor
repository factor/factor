! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files kernel tools.test db db.sqlite db.tuples
db.types continuations namespaces ;
IN: temporary

TUPLE: person the-id the-name the-number real ;
: <person> ( name age -- person )
    {
        set-person-the-name
        set-person-the-number
        set-person-real
    } person construct ;

: <assigned-person> ( id name number real -- obj )
    <person> [ set-person-the-id ] keep ;

SYMBOL: the-person

: test-tuples ( -- )
    [ person drop-table ] [ drop ] recover
    [ ] [ person create-table ] unit-test
    
    [  ] [ the-person get insert-tuple ] unit-test

    [ 1 ] [ the-person get person-the-id ] unit-test

    200 the-person get set-person-the-number

    [ ] [ the-person get update-tuple ] unit-test

    [ ] [ the-person get delete-tuple ] unit-test ;

: test-sqlite ( -- )
    "tuples-test.db" resource-path <sqlite-db> [
        test-tuples
    ] with-db ;

! : test-postgres ( -- )
    ! resource-path <postgresql-db> [
        ! test-tuples
    ! ] with-db ;

person "PERSON"
{
    { "the-id" "ROWID" INTEGER +native-id+ }
    { "the-name" "NAME" { VARCHAR 256 } +not-null+ }
    { "the-number" "AGE" INTEGER { +default+ 0 } }
    { "real" "REAL" DOUBLE { +default+ 0.3 } }
} define-persistent

"billy" 10 3.14 <person> the-person set

test-sqlite
! test-postgres

person "PERSON"
{
    { "the-id" "ROWID" INTEGER +assigned-id+ }
    { "the-name" "NAME" { VARCHAR 256 } +not-null+ }
    { "the-number" "AGE" INTEGER { +default+ 0 } }
    { "real" "REAL" DOUBLE { +default+ 0.3 } }
} define-persistent

1 "billy" 20 6.28 <assigned-person> the-person set

test-sqlite
! test-postgres
