! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files kernel tools.test db db.tuples
db.types continuations namespaces math
prettyprint tools.walker db.sqlite calendar
math.intervals db.postgresql ;
IN: db.tuples.tests

TUPLE: person the-id the-name the-number the-real
ts date time blob factor-blob ;

: <person> ( name age real ts date time blob -- person )
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

: <assigned-person> ( id name age real ts date time blob factor-blob -- person )
    <person> [ set-person-the-id ] keep ;

SYMBOL: person1
SYMBOL: person2
SYMBOL: person3
SYMBOL: person4

: test-tuples ( -- )
    [ ] [ person ensure-table ] unit-test
    [ ] [ person drop-table ] unit-test
    [ ] [ person create-table ] unit-test
    [ person create-table ] must-fail
    [ ] [ person ensure-table ] unit-test
    
    [ ] [ person1 get insert-tuple ] unit-test

    [ 1 ] [ person1 get person-the-id ] unit-test

    200 person1 get set-person-the-number

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
            T{ timestamp f 2008 3 5 16 24 11 0 }
            T{ timestamp f 2008 11 22 f f f f }
            T{ timestamp f f f f 12 34 56 f }
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
            T{ timestamp f 2008 3 5 16 24 11 0 }
            T{ timestamp f 2008 11 22 f f f f }
            T{ timestamp f f f f 12 34 56 f }
            f
            H{ { 1 2 } { 3 4 } { 5 "lol" } }
        }
    ] [ T{ person f 4 } select-tuple ] unit-test

    [ ] [ person drop-table ] unit-test ;

: make-native-person-table ( -- )
    [ person drop-table ] [ drop ] recover
    person create-table
    T{ person f f "billy" 200 3.14 } insert-tuple
    T{ person f f "johnny" 10 3.14 } insert-tuple
    ;

: native-person-schema ( -- )
    person "PERSON"
    {
        { "the-id" "ID" +native-id+ }
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
    "teddy" 10 3.14 "2008-03-05 16:24:11" "2008-11-22" "12:34:56" B{ 115 116 111 114 101 105 110 97 98 108 111 98 } f <person> person3 set
    "eddie" 10 3.14 "2008-03-05 16:24:11" "2008-11-22" "12:34:56" f H{ { 1 2 } { 3 4 } { 5 "lol" } } <person> person4 set ;

: assigned-person-schema ( -- )
    person "PERSON"
    {
        { "the-id" "ID" INTEGER +assigned-id+ }
        { "the-name" "NAME" { VARCHAR 256 } +not-null+ }
        { "the-number" "AGE" INTEGER { +default+ 0 } }
        { "the-real" "REAL" DOUBLE { +default+ 0.3 } }
        { "ts" "TS" TIMESTAMP }
        { "date" "D" DATE }
        { "time" "T" TIME }
        { "blob" "B" BLOB }
        { "factor-blob" "FB" FACTOR-BLOB }
    } define-persistent
    1 "billy" 10 3.14 f f f f f <assigned-person> person1 set
    2 "johnny" 10 3.14 f f f f f <assigned-person> person2 set
    3 "teddy" 10 3.14 "2008-03-05 16:24:11" "2008-11-22" "12:34:56" B{ 115 116 111 114 101 105 110 97 98 108 111 98 } f <assigned-person> person3 set
    4 "eddie" 10 3.14 "2008-03-05 16:24:11" "2008-11-22" "12:34:56" f H{ { 1 2 } { 3 4 } { 5 "lol" } } <assigned-person> person4 set ;

TUPLE: paste n summary author channel mode contents timestamp annotations ;
TUPLE: annotation n paste-id summary author mode contents ;

: native-paste-schema ( -- )
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

[ native-person-schema test-tuples ] test-sqlite
[ assigned-person-schema test-tuples ] test-sqlite

! [ native-person-schema test-tuples ] test-postgresql
! [ assigned-person-schema test-tuples ] test-postgresql

TUPLE: serialize-me id data ;

: test-serialize ( -- )
    serialize-me "SERIALIZED"
    {
        { "id" "ID" +native-id+ }
        { "data" "DATA" FACTOR-BLOB }
    } define-persistent
    [ serialize-me drop-table ] [ drop ] recover
    [ ] [ serialize-me create-table ] unit-test

    [ ] [ T{ serialize-me f f H{ { 1 2 } } } insert-tuple ] unit-test
    [
        { T{ serialize-me f 1 H{ { 1 2 } } } }
    ] [ T{ serialize-me f 1 } select-tuples ] unit-test ;

[ test-serialize ] test-sqlite
! [ test-serialize ] test-postgresql

TUPLE: exam id name score ; 

: test-ranges ( -- )
    exam "EXAM"
    {
        { "id" "ID" +native-id+ }
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
        T{ exam f 3 "Kenny" 60 }
        T{ exam f 4 "Cartman" 41 }
    ] [ T{ exam f 4 f T{ interval f { 0 t } { 70 t } } } select-tuples ] unit-test
    ;

! [ test-ranges ] test-sqlite

\ insert-tuple must-infer
\ update-tuple must-infer
\ delete-tuple must-infer
\ select-tuple must-infer
\ define-persistent must-infer
