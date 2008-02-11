USING: io.files kernel tools.test db db.sqlite db.tuples ;
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


: test-tuples ( -- )
    f "billy" 100 person construct-boa dup insert-tuple

    [ 1 ] [ dup person-id ] unit-test

    200 over set-person-the-number

    [ ] [ dup update-tuple ] unit-test

    [ ] [ delete-tuple ] unit-test ;

: test-sqlite ( -- )
    "tuples-test.db" resource-path <sqlite-db> [
        test-tuples
    ] with-db ;

test-sqlite

! : test-postgres ( -- )
    ! resource-path <postgresql-db> [
        ! test-tuples
    ! ] with-db ;
