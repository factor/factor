! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files kernel tools.test db db.tuples classes
db.types continuations namespaces math math.ranges
prettyprint calendar sequences db.sqlite math.intervals
db.postgresql accessors random math.bitfields.lib ;
IN: db.tuples.tests

TUPLE: person the-id the-name the-number the-real
ts date time blob factor-blob ;

: <person> ( name age real ts date time blob factor-blob -- person )
    {
        set-person-the-name
        set-person-the-number
        set-person-the-real
        set-person-ts
        set-person-date
        set-person-time
        set-person-blob
        set-person-factor-blob
    } person construct ;

: <user-assigned-person> ( id name age real ts date time blob factor-blob -- person )
    <person> [ set-person-the-id ] keep ;

SYMBOL: person1
SYMBOL: person2
SYMBOL: person3
SYMBOL: person4

: test-tuples ( -- )
    [ ] [ person recreate-table ] unit-test
    [ ] [ person ensure-table ] unit-test
    [ ] [ person drop-table ] unit-test
    [ ] [ person create-table ] unit-test
    [ person create-table ] must-fail
    [ ] [ person ensure-table ] unit-test
    
    [ ] [ person1 get insert-tuple ] unit-test

    [ 1 ] [ person1 get person-the-id ] unit-test

    [ ] [ 200 person1 get set-person-the-number ] unit-test

    [ ] [ person1 get update-tuple ] unit-test

    [ T{ person f 1 "billy" 200 3.14 } ]
    [ T{ person f 1 } select-tuple ] unit-test
    [ ] [ person2 get insert-tuple ] unit-test
    [
        {
            T{ person f 1 "billy" 200 3.14 }
            T{ person f 2 "johnny" 10 3.14 }
        }
    ] [ T{ person f f f f 3.14 } select-tuples ] unit-test
    [
        {
            T{ person f 1 "billy" 200 3.14 }
            T{ person f 2 "johnny" 10 3.14 }
        }
    ] [ T{ person f } select-tuples ] unit-test

    [
        {
            T{ person f 2 "johnny" 10 3.14 }
        }
    ] [ T{ person f f f 10 3.14 } select-tuples ] unit-test


    [ ] [ person1 get delete-tuple ] unit-test
    [ f ] [ T{ person f 1 } select-tuple ] unit-test

    [ ] [ person3 get insert-tuple ] unit-test

    [
        T{
            person
            f
            3
            "teddy"
            10
            3.14
            T{ timestamp f 2008 3 5 16 24 11 T{ duration f 0 0 0 0 0 0 } }
            T{ timestamp f 2008 11 22 f f f T{ duration f 0 0 0 0 0 0 } }
            T{ timestamp f f f f 12 34 56 T{ duration f 0 0 0 0 0 0 } }
            B{ 115 116 111 114 101 105 110 97 98 108 111 98 }
        }
    ] [ T{ person f 3 } select-tuple ] unit-test

    [ ] [ person4 get insert-tuple ] unit-test
    [
        T{
            person
            f
            4
            "eddie"
            10
            3.14
            T{ timestamp f 2008 3 5 16 24 11 T{ duration f 0 0 0 0 0 0 } }
            T{ timestamp f 2008 11 22 f f f T{ duration f 0 0 0 0 0 0 } }
            T{ timestamp f f f f 12 34 56 T{ duration f 0 0 0 0 0 0 } }
            f
            H{ { 1 2 } { 3 4 } { 5 "lol" } }
        }
    ] [ T{ person f 4 } select-tuple ] unit-test

    [ ] [ person drop-table ] unit-test ;

: db-assigned-person-schema ( -- )
    person "PERSON"
    {
        { "the-id" "ID" +db-assigned-id+ }
        { "the-name" "NAME" { VARCHAR 256 } +not-null+ }
        { "the-number" "AGE" INTEGER { +default+ 0 } }
        { "the-real" "REAL" DOUBLE { +default+ 0.3 } }
        { "ts" "TS" TIMESTAMP }
        { "date" "D" DATE }
        { "time" "T" TIME }
        { "blob" "B" BLOB }
        { "factor-blob" "FB" FACTOR-BLOB }
    } define-persistent
    "billy" 10 3.14 f f f f f <person> person1 set
    "johnny" 10 3.14 f f f f f <person> person2 set
    "teddy" 10 3.14
        T{ timestamp f 2008 3 5 16 24 11 T{ duration f 0 0 0 0 0 0 } }
        T{ timestamp f 2008 11 22 0 0 0 T{ duration f 0 0 0 0 0 0 } }
        T{ timestamp f f f f 12 34 56 T{ duration f 0 0 0 0 0 0 } }
        B{ 115 116 111 114 101 105 110 97 98 108 111 98 } f <person> person3 set
    "eddie" 10 3.14
        T{ timestamp f 2008 3 5 16 24 11 T{ duration f 0 0 0 0 0 0 } }
        T{ timestamp f 2008 11 22 0 0 0 T{ duration f 0 0 0 0 0 0 } }
        T{ timestamp f f f f 12 34 56 T{ duration f 0 0 0 0 0 0 } }
        f H{ { 1 2 } { 3 4 } { 5 "lol" } } <person> person4 set ;

: user-assigned-person-schema ( -- )
    person "PERSON"
    {
        { "the-id" "ID" INTEGER +user-assigned-id+ }
        { "the-name" "NAME" { VARCHAR 256 } +not-null+ }
        { "the-number" "AGE" INTEGER { +default+ 0 } }
        { "the-real" "REAL" DOUBLE { +default+ 0.3 } }
        { "ts" "TS" TIMESTAMP }
        { "date" "D" DATE }
        { "time" "T" TIME }
        { "blob" "B" BLOB }
        { "factor-blob" "FB" FACTOR-BLOB }
    } define-persistent
    1 "billy" 10 3.14 f f f f f <user-assigned-person> person1 set
    2 "johnny" 10 3.14 f f f f f <user-assigned-person> person2 set
    3 "teddy" 10 3.14
        T{ timestamp f 2008 3 5 16 24 11 T{ duration f 0 0 0 0 0 0 } }
        T{ timestamp f 2008 11 22 0 0 0 T{ duration f 0 0 0 0 0 0 } }
        T{ timestamp f f f f 12 34 56 T{ duration f 0 0 0 0 0 0 } }
        B{ 115 116 111 114 101 105 110 97 98 108 111 98 }
        f <user-assigned-person> person3 set
    4 "eddie" 10 3.14
        T{ timestamp f 2008 3 5 16 24 11 T{ duration f 0 0 0 0 0 0 } }
        T{ timestamp f 2008 11 22 0 0 0 T{ duration f 0 0 0 0 0 0 } }
        T{ timestamp f f f f 12 34 56 T{ duration f 0 0 0 0 0 0 } }
        f H{ { 1 2 } { 3 4 } { 5 "lol" } } <user-assigned-person> person4 set ;

TUPLE: paste n summary author channel mode contents timestamp annotations ;
TUPLE: annotation n paste-id summary author mode contents ;

: db-assigned-paste-schema ( -- )
    paste "PASTE"
    {
        { "n" "ID" +db-assigned-id+ }
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
        { "n" "ID" +db-assigned-id+ }
        { "paste-id" "PASTE_ID" INTEGER { +foreign-id+ paste "n" } }
        { "summary" "SUMMARY" TEXT }
        { "author" "AUTHOR" TEXT }
        { "mode" "MODE" TEXT }
        { "contents" "CONTENTS" TEXT }
    } define-persistent ;

! { "localhost" "postgres" "" "factor-test" } postgresql-db [
    ! [ paste drop-table ] [ drop ] recover
    ! [ annotation drop-table ] [ drop ] recover
    ! [ paste drop-table ] [ drop ] recover
    ! [ annotation drop-table ] [ drop ] recover
    ! [ ] [ paste create-table ] unit-test
    ! [ ] [ annotation create-table ] unit-test
! ] with-db

: test-sqlite ( quot -- )
    >r "tuples-test.db" temp-file sqlite-db r> with-db ;

: test-postgresql ( -- )
>r { "localhost" "postgres" "foob" "factor-test" } postgresql-db r> with-db ;

: test-repeated-insert
    [ ] [ person ensure-table ] unit-test
    [ ] [ person1 get insert-tuple ] unit-test
    [ person1 get insert-tuple ] must-fail ;

TUPLE: serialize-me id data ;

: test-serialize ( -- )
    serialize-me "SERIALIZED"
    {
        { "id" "ID" +db-assigned-id+ }
        { "data" "DATA" FACTOR-BLOB }
    } define-persistent
    [ serialize-me drop-table ] [ drop ] recover
    [ ] [ serialize-me create-table ] unit-test

    [ ] [ T{ serialize-me f f H{ { 1 2 } } } insert-tuple ] unit-test
    [
        { T{ serialize-me f 1 H{ { 1 2 } } } }
    ] [ T{ serialize-me f 1 } select-tuples ] unit-test ;

TUPLE: exam id name score ; 

: test-intervals ( -- )
    exam "EXAM"
    {
        { "id" "ID" +db-assigned-id+ }
        { "name" "NAME" TEXT }
        { "score" "SCORE" INTEGER }
    } define-persistent
    [ exam drop-table ] [ drop ] recover
    [ ] [ exam create-table ] unit-test

    [ ] [ T{ exam f f "Kyle" 100 } insert-tuple ] unit-test
    [ ] [ T{ exam f f "Stan" 80 } insert-tuple ] unit-test
    [ ] [ T{ exam f f "Kenny" 60 } insert-tuple ] unit-test
    [ ] [ T{ exam f f "Cartman" 41 } insert-tuple ] unit-test

    [
        {
            T{ exam f 3 "Kenny" 60 }
            T{ exam f 4 "Cartman" 41 }
        }
    ] [
        T{ exam f f f T{ interval f { 0 t } { 70 t } } } select-tuples
    ] unit-test

    [
        { }
    ] [
        T{ exam f T{ interval f { 3 f } { 4 f } } f } select-tuples
    ] unit-test
    [
        {
            T{ exam f 4 "Cartman" 41 }
        }
    ] [
        T{ exam f T{ interval f { 3 f } { 4 t } } f } select-tuples
    ] unit-test
    [
        {
            T{ exam f 3 "Kenny" 60 }
        }
    ] [
        T{ exam f T{ interval f { 3 t } { 4 f } } f } select-tuples
    ] unit-test
    [
        {
            T{ exam f 3 "Kenny" 60 }
            T{ exam f 4 "Cartman" 41 }
        }
    ] [
        T{ exam f T{ interval f { 3 t } { 4 t } } f } select-tuples
    ] unit-test

    [
        {
            T{ exam f 1 "Kyle" 100 }
            T{ exam f 2 "Stan" 80 }
        }
    ] [
        T{ exam f f { "Stan" "Kyle" } } select-tuples
    ] unit-test

    [
        {
            T{ exam f 1 "Kyle" 100 }
            T{ exam f 2 "Stan" 80 }
            T{ exam f 3 "Kenny" 60 }
        }
    ] [
        T{ exam f T{ range f 1 3 1 } } select-tuples
    ] unit-test

    [
        {
            T{ exam f 2 "Stan" 80 }
            T{ exam f 3 "Kenny" 60 }
            T{ exam f 4 "Cartman" 41 }
        }
    ] [
        T{ exam f T{ interval f { 2 t } { 1.0/0.0 f } } } select-tuples
    ] unit-test

    [
        {
            T{ exam f 1 "Kyle" 100 }
        }
    ] [
        T{ exam f T{ interval f { -1.0/0.0 t } { 2 f } } } select-tuples
    ] unit-test

    [
        {
            T{ exam f 1 "Kyle" 100 }
            T{ exam f 2 "Stan" 80 }
            T{ exam f 3 "Kenny" 60 }
            T{ exam f 4 "Cartman" 41 }
        }
    ] [
        T{ exam f T{ interval f { -1.0/0.0 t } { 1/0. f } } } select-tuples
    ] unit-test
    
    [
        {
            T{ exam f 1 "Kyle" 100 }
            T{ exam f 2 "Stan" 80 }
            T{ exam f 3 "Kenny" 60 }
            T{ exam f 4 "Cartman" 41 }
        }
    ] [
        T{ exam } select-tuples
    ] unit-test ;

TUPLE: bignum-test id m n o ;
: <bignum-test> ( m n o -- obj )
    bignum-test new
        swap >>o
        swap >>n
        swap >>m ;

: test-bignum
    bignum-test "BIGNUM_TEST"
    {
        { "id" "ID" +db-assigned-id+ }
        { "m" "M" BIG-INTEGER }
        { "n" "N" UNSIGNED-BIG-INTEGER }
        { "o" "O" SIGNED-BIG-INTEGER }
    } define-persistent
    [ bignum-test drop-table ] ignore-errors
    [ ] [ bignum-test ensure-table ] unit-test
    [ ] [ 63 2^ 1- dup dup <bignum-test> insert-tuple ] unit-test ;

    ! sqlite only
    ! [ T{ bignum-test f 1
        ! -9223372036854775808 9223372036854775808 -9223372036854775808 } ]
    ! [ T{ bignum-test f 1 } select-tuple ] unit-test ;

TUPLE: secret n message ;
C: <secret> secret

: test-random-id
    secret "SECRET"
    {
        { "n" "ID" +random-id+ system-random-generator }
        { "message" "MESSAGE" TEXT }
    } define-persistent

    [ ] [ secret recreate-table ] unit-test

    [ t ] [ f "kilroy was here" <secret> [ insert-tuple ] keep n>> integer? ] unit-test

    [ ] [ f "kilroy was here2" <secret> insert-tuple ] unit-test

    [ ] [ f "kilroy was here3" <secret> insert-tuple ] unit-test

    [ t ] [
        T{ secret } select-tuples
        first message>> "kilroy was here" head?
    ] unit-test

    [ t ] [
        T{ secret } select-tuples length 3 =
    ] unit-test ;

[ db-assigned-person-schema test-tuples ] test-sqlite
[ user-assigned-person-schema test-tuples ] test-sqlite
[ user-assigned-person-schema test-repeated-insert ] test-sqlite
[ test-bignum ] test-sqlite
[ test-serialize ] test-sqlite
[ test-intervals ] test-sqlite
[ test-random-id ] test-sqlite

[ db-assigned-person-schema test-tuples ] test-postgresql
[ user-assigned-person-schema test-tuples ] test-postgresql
[ user-assigned-person-schema test-repeated-insert ] test-postgresql
[ test-bignum ] test-postgresql
[ test-serialize ] test-postgresql
[ test-intervals ] test-postgresql
[ test-random-id ] test-postgresql

TUPLE: does-not-persist ;

[
    [ does-not-persist create-sql-statement ]
    [ class \ not-persistent = ] must-fail-with
] test-sqlite

[
    [ does-not-persist create-sql-statement ]
    [ class \ not-persistent = ] must-fail-with
] test-postgresql

! Don't comment these out. These words must infer
\ bind-tuple must-infer
\ insert-tuple must-infer
\ update-tuple must-infer
\ delete-tuple must-infer
\ select-tuple must-infer
\ define-persistent must-infer
\ ensure-table must-infer
\ create-table must-infer
\ drop-table must-infer
