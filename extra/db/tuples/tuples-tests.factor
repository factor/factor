USING: io.files kernel tools.test db db.sqlite db.tuples
db.types continuations namespaces ;
IN: temporary

TUPLE: person the-id the-name the-number ;
: <person> ( name age -- person )
    { set-person-the-name set-person-the-number } person construct ;

person "PERSON"
{
    { "the-id" "ROWID" INTEGER +native-id+ }
    { "the-name" "NAME" { VARCHAR 256 } +not-null+ } 
    { "the-number" "AGE" INTEGER { +default+ 0 } }
} define-persistent


SYMBOL: the-person

: test-tuples ( -- )
    [ person drop-table ] [ ] recover
    person create-table
    f "billy" 100 person construct-boa
    the-person set
    
    [  ] [ the-person get insert-tuple ] unit-test

    [ 1 ] [ the-person get person-the-id ] unit-test

    200 the-person get set-person-the-number

    [ ] [ the-person get update-tuple ] unit-test

    [ ] [ the-person get delete-tuple ] unit-test ;

: test-sqlite ( -- )
    "tuples-test.db" resource-path <sqlite-db> [
        test-tuples
    ] with-db ;

test-sqlite

! : test-postgres ( -- )
    ! resource-path <postgresql-db> [
        ! test-tuples
    ! ] with-db ;
