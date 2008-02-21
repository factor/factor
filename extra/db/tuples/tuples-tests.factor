! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files kernel tools.test db db.sqlite db.tuples
db.types continuations namespaces db.postgresql math
prettyprint tools.walker ;
IN: temporary

TUPLE: person the-id the-name the-number the-real ;
: <person> ( name age real -- person )
    {
        set-person-the-name
        set-person-the-number
        set-person-the-real
    } person construct ;

: <assigned-person> ( id name number the-real -- obj )
    <person> [ set-person-the-id ] keep ;

SYMBOL: the-person

: test-tuples ( -- )
    [ person drop-table ] [ drop ] recover
    [ ] [ person create-table ] unit-test
    
    [  ] [ the-person get insert-tuple ] unit-test

    [ 1 ] [ the-person get person-the-id ] unit-test

    200 the-person get set-person-the-number

    [ ] [ the-person get update-tuple ] unit-test

    ! T{ person f f f 200 f } select-tuples

    [ ] [ the-person get delete-tuple ] unit-test
    [ ] [ person drop-table ] unit-test ;

: test-sqlite ( -- )
    "tuples-test.db" resource-path <sqlite-db> [
        test-tuples
    ] with-db ;

: test-postgresql ( -- )
    "localhost" "postgres" "" "factor-test" <postgresql-db> [
        test-tuples
    ] with-db ;

person "PERSON"
{
    { "the-id" "ID" +native-id+ }
    { "the-name" "NAME" { VARCHAR 256 } +not-null+ }
    { "the-number" "AGE" INTEGER { +default+ 0 } }
    { "the-real" "REAL" DOUBLE { +default+ 0.3 } }
} define-persistent

"billy" 10 3.14 <person> the-person set

! test-sqlite
test-postgresql

! person "PERSON"
! {
    ! { "the-id" "ID" INTEGER +assigned-id+ }
    ! { "the-name" "NAME" { VARCHAR 256 } +not-null+ }
    ! { "the-number" "AGE" INTEGER { +default+ 0 } }
    ! { "the-real" "REAL" DOUBLE { +default+ 0.3 } }
! } define-persistent

! 1 "billy" 20 6.28 <assigned-person> the-person set

! test-sqlite
! test-postgresql

TUPLE: paste n summary author channel mode contents timestamp annotations ;
TUPLE: annotation n paste-id summary author mode contents ;

paste "PASTE"
{
    { "n" "ID" +native-id+ }
    { "summary" "SUMMARY" TEXT }
    { "author" "AUTHOR" TEXT }
    { "channel" "CHANNEL" TEXT }
    { "mode" "MODE" TEXT }
    { "contents" "CONTENTS" TEXT }
    { "date" "DATE" TIMESTAMP }
    { "annotations" { +has-many+ annotation } }
} define-persistent

annotation "ANNOTATION"
{
    { "n" "ID" +native-id+ }
    { "paste-id" "PASTE_ID" INTEGER { +foreign-id+ paste "n" } }
    { "summary" "SUMMARY" TEXT }
    { "author" "AUTHOR" TEXT }
    { "mode" "MODE" TEXT }
    { "contents" "CONTENTS" TEXT }
} define-persistent

! "localhost" "postgres" "" "factor-test" <postgresql-db> [
    ! [ paste drop-table ] [ drop ] recover
    ! [ annotation drop-table ] [ drop ] recover
    ! [ paste drop-table ] [ drop ] recover
    ! [ annotation drop-table ] [ drop ] recover
    ! [ ] [ paste create-table ] unit-test
    ! [ ] [ annotation create-table ] unit-test
! ] with-db
