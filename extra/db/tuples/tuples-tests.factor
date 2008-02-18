! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files kernel tools.test db db.sqlite db.tuples
db.types continuations namespaces db.postgresql math ;
! tools.time ;
IN: temporary

TUPLE: person the-id the-name the-number real ;
: <person> ( name age real -- person )
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

    [ ] [ the-person get delete-tuple ] unit-test
    ; ! 1 [ ] [ person drop-table ] unit-test ;

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
    { "the-id" "ID" SERIAL +native-id+ }
    { "the-name" "NAME" { VARCHAR 256 } +not-null+ }
    { "the-number" "AGE" INTEGER { +default+ 0 } }
    { "real" "REAL" DOUBLE { +default+ 0.3 } }
} define-persistent

"billy" 10 3.14 <person> the-person set

! test-sqlite
! test-postgresql

! person "PERSON"
! {
    ! { "the-id" "ID" INTEGER +assigned-id+ }
    ! { "the-name" "NAME" { VARCHAR 256 } +not-null+ }
    ! { "the-number" "AGE" INTEGER { +default+ 0 } }
    ! { "real" "REAL" DOUBLE { +default+ 0.3 } }
! } define-persistent

! 1 "billy" 20 6.28 <assigned-person> the-person set

! test-sqlite
! test-postgresql

TUPLE: paste n summary author channel mode contents timestamp annotations ;
TUPLE: annotation n paste-id summary author mode contents ;

paste "PASTE"
{
    { "n" "ID" SERIAL +native-id+ }
    { "summary" "SUMMARY" TEXT }
    { "author" "AUTHOR" TEXT }
    { "channel" "CHANNEL" TEXT }
    { "mode" "MODE" TEXT }
    { "contents" "CONTENTS" TEXT }
    { "date" "DATE" TIMESTAMP }
    { "annotations" { +has-many+ annotation } }
} define-persistent

! n
    ! NO: drop insert
    ! YES: create update delete select
! annotations
    ! NO: create drop insert update delete
    ! YES: select

annotation "ANNOTATION"
{
    { "n" "ID" SERIAL +native-id+ }
    { "paste-id" "PASTE_ID" INTEGER { +foreign-key+ paste "n" } }
    { "summary" "SUMMARY" TEXT }
    { "author" "AUTHOR" TEXT }
    { "mode" "MODE" TEXT }
    { "contents" "CONTENTS" TEXT }
} define-persistent

"localhost" "postgres" "" "factor-test" <postgresql-db> [
    ! paste drop-table
    ! annotation drop-table
    paste create-table
    annotation create-table
] with-db
