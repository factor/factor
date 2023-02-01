! Copyright (C) 2008 Doug Coleman.
! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar calendar.parser classes continuations
db.tester db.tuples db.types kernel math math.intervals ranges
namespaces random sequences sorting strings tools.test urls ;
IN: db.tuples.tests

TUPLE: person the-id the-name the-number the-real
    ts date time blob factor-blob url ;

: <person> ( name age real ts date time blob factor-blob url -- person )
    person new
        swap >>url
        swap >>factor-blob
        swap >>blob
        swap >>time
        swap >>date
        swap >>ts
        swap >>the-real
        swap >>the-number
        swap >>the-name ;

: <user-assigned-person> ( id name age real ts date time blob factor-blob url -- person )
    <person>
        swap >>the-id ;

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

    [ 1 ] [ person1 get the-id>> ] unit-test

    [ ] [ person1 get 200 >>the-number drop ] unit-test

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


    [ ] [ person1 get delete-tuples ] unit-test
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
            T{ timestamp f 2008 11 22 0 0 0 T{ duration f 0 0 0 0 0 0 } }
            T{ duration f 0 0 0 12 34 56 }
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
            T{ timestamp f 2008 11 22 0 0 0 T{ duration f 0 0 0 0 0 0 } }
            T{ duration f 0 0 0 12 34 56 }
            f
            H{ { 1 2 } { 3 4 } { 5 "lol" } }
            URL" https://www.google.com/search?hl=en&q=trailer+park+boys&btnG=Google+Search"
        }
    ] [ T{ person f 4 } select-tuple ] unit-test

    [ ] [ person drop-table ] unit-test ;

: teddy-data ( -- name age real ts date time blob factor-blob url )
    "teddy" 10 3.14
    "2008-03-05 16:24:11" ymdhms>timestamp
    "2008-11-22 00:00:00" ymdhms>timestamp
    "12:34:56" hms>duration
    B{ 115 116 111 114 101 105 110 97 98 108 111 98 } f f ;

: eddie-data ( -- name age real ts date time blob factor-blob url )
    "eddie" 10 3.14
    "2008-03-05 16:24:11" ymdhms>timestamp
    "2008-11-22 00:00:00" ymdhms>timestamp
    "12:34:56" hms>duration
    f H{ { 1 2 } { 3 4 } { 5 "lol" } }
    URL" https://www.google.com/search?hl=en&q=trailer+park+boys&btnG=Google+Search" ;

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
        { "url" "U" URL }
    } define-persistent
    "billy" 10 3.14 f f f f f f <person> person1 set
    "johnny" 10 3.14 f f f f f f <person> person2 set
    teddy-data <person> person3 set
    eddie-data <person> person4 set ;

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
        { "url" "U" URL }
    } define-persistent
    1 "billy" 10 3.14 f f f f f f <user-assigned-person> person1 set
    2 "johnny" 10 3.14 f f f f f f <user-assigned-person> person2 set
    3 teddy-data <user-assigned-person> person3 set
    4 eddie-data <user-assigned-person> person4 set ;

TUPLE: paste n summary author channel mode contents timestamp annotations ;
TUPLE: annotation n paste-id summary author mode contents ;

paste "PASTE"
{
    { "n" "ID" +db-assigned-id+ }
    { "summary" "SUMMARY" TEXT }
    { "author" "AUTHOR" TEXT }
    { "channel" "CHANNEL" TEXT }
    { "mode" "MODE" TEXT }
    { "contents" "CONTENTS" TEXT }
    { "timestamp" "DATE" TIMESTAMP }
    { "annotations" { +has-many+ annotation } }
} define-persistent

: annotation-schema-foreign-key ( -- )
    annotation "ANNOTATION"
    {
        { "n" "ID" +db-assigned-id+ }
        { "paste-id" "PASTE_ID" INTEGER { +foreign-id+ paste "ID" } }
        { "summary" "SUMMARY" TEXT }
        { "author" "AUTHOR" TEXT }
        { "mode" "MODE" TEXT }
        { "contents" "CONTENTS" TEXT }
    } define-persistent ;

: annotation-schema-foreign-key-not-null ( -- )
    annotation "ANNOTATION"
    {
        { "n" "ID" +db-assigned-id+ }
        { "paste-id" "PASTE_ID" INTEGER { +foreign-id+ paste "ID" } +not-null+ }
        { "summary" "SUMMARY" TEXT }
        { "author" "AUTHOR" TEXT }
        { "mode" "MODE" TEXT }
        { "contents" "CONTENTS" TEXT }
    } define-persistent ;

: annotation-schema-cascade ( -- )
    annotation "ANNOTATION"
    {
        { "n" "ID" +db-assigned-id+ }
        { "paste-id" "PASTE_ID" INTEGER { +foreign-id+ paste "ID" }
            +on-delete+ +cascade+ }
        { "summary" "SUMMARY" TEXT }
        { "author" "AUTHOR" TEXT }
        { "mode" "MODE" TEXT }
        { "contents" "CONTENTS" TEXT }
    } define-persistent ;

: annotation-schema-restrict ( -- )
    annotation "ANNOTATION"
    {
        { "n" "ID" +db-assigned-id+ }
        { "paste-id" "PASTE_ID" INTEGER { +foreign-id+ paste "ID" } }
        { "summary" "SUMMARY" TEXT }
        { "author" "AUTHOR" TEXT }
        { "mode" "MODE" TEXT }
        { "contents" "CONTENTS" TEXT }
    } define-persistent ;

: test-paste-schema ( -- )
    [ ] [ paste ensure-table ] unit-test
    [ ] [ annotation ensure-table ] unit-test
    [ ] [ annotation drop-table ] unit-test
    [ ] [ paste drop-table ] unit-test
    [ ] [ paste create-table ] unit-test
    [ ] [ annotation create-table ] unit-test

    [ ] [
        paste new
            "summary1" >>summary
            "erg" >>author
            "#lol" >>channel
            "contents1" >>contents
            now >>timestamp
        insert-tuple
    ] unit-test

    [ ] [
        annotation new
            1 >>paste-id
            "annotation1" >>summary
            "erg" >>author
            "annotation contents" >>contents
        insert-tuple
    ] unit-test ;

: test-foreign-key ( -- )
    [ ] [ annotation-schema-foreign-key ] unit-test
    test-paste-schema
    [ paste new 1 >>n delete-tuples ] must-fail ;

: test-foreign-key-not-null ( -- )
    [ ] [ annotation-schema-foreign-key-not-null ] unit-test
    test-paste-schema
    [ paste new 1 >>n delete-tuples ] must-fail ;

: test-cascade ( -- )
    [ ] [ annotation-schema-cascade ] unit-test
    test-paste-schema
    [ ] [ paste new 1 >>n delete-tuples ] unit-test
    [ 0 ] [ paste new select-tuples length ] unit-test ;

: test-restrict ( -- )
    [ ] [ annotation-schema-restrict ] unit-test
    test-paste-schema
    [ paste new 1 >>n delete-tuples ] must-fail ;

[ test-foreign-key ] test-sqlite
[ test-foreign-key-not-null ] test-sqlite
[ test-cascade ] test-sqlite
[ test-restrict ] test-sqlite

[ test-foreign-key ] test-postgresql
[ test-foreign-key-not-null ] test-postgresql
[ test-cascade ] test-postgresql
[ test-restrict ] test-postgresql

: test-repeated-insert ( -- )
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
    [ ] [ serialize-me recreate-table ] unit-test

    [ ] [ T{ serialize-me f f H{ { 1 2 } } } insert-tuple ] unit-test
    [
        { T{ serialize-me f 1 H{ { 1 2 } } } }
    ] [ T{ serialize-me f 1 } select-tuples ] unit-test ;

TUPLE: exam id name score ;

: random-exam ( -- exam )
        f
        6 [ CHAR: a CHAR: z [a..b] random ] replicate >string
        100 random
    exam boa ;

: test-intervals ( -- )
    [
        exam "EXAM"
        {
            { "idd" "ID" +db-assigned-id+ }
            { "named" "NAME" TEXT }
            { "score" "SCORE" INTEGER }
        } define-persistent
    ] [
        seq>> { "idd" "named" } =
    ] must-fail-with

    exam "EXAM"
    {
        { "id" "ID" +db-assigned-id+ }
        { "name" "NAME" TEXT }
        { "score" "SCORE" INTEGER }
    } define-persistent
    [ ] [ exam recreate-table ] unit-test

    [ ] [ T{ exam f f "Kyle" 100 } insert-tuple ] unit-test
    [ ] [ T{ exam f f "Stan" 80 } insert-tuple ] unit-test
    [ ] [ T{ exam f f "Kenny" 60 } insert-tuple ] unit-test
    [ ] [ T{ exam f f "Cartman" 41 } insert-tuple ] unit-test

    [ 4 ]
    [ T{ exam { name IGNORE } { score IGNORE } } select-tuples length ] unit-test

    [ f ]
    [ T{ exam { name IGNORE } { score IGNORE } } select-tuples first score>> ] unit-test

    [ T{ exam { name IGNORE } { score IGNORE } { id IGNORE } } select-tuples first score>> ] [ class>> "EXAM" = ] must-fail-with

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
        T{ exam f T{ interval f { 2 t } { 1/0. f } } } select-tuples
    ] unit-test

    [
        {
            T{ exam f 1 "Kyle" 100 }
        }
    ] [
        T{ exam f T{ interval f { -1/0. t } { 2 f } } } select-tuples
    ] unit-test

    [
        {
            T{ exam f 1 "Kyle" 100 }
            T{ exam f 2 "Stan" 80 }
            T{ exam f 3 "Kenny" 60 }
            T{ exam f 4 "Cartman" 41 }
        }
    ] [
        T{ exam f T{ interval f { -1/0. t } { 1/0. f } } } select-tuples
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
    ] unit-test

    [ 4 ] [ T{ exam } count-tuples ] unit-test

    [ ] [ T{ exam { score 10 } } insert-tuple ] unit-test

    [ 10 ]
    [ T{ exam { name NULL } } select-tuples first score>> ] unit-test ;

TUPLE: bignum-test id m n o ;
: <bignum-test> ( m n o -- obj )
    bignum-test new
        swap >>o
        swap >>n
        swap >>m ;

: test-bignum ( -- )
    bignum-test "BIGNUM_TEST"
    {
        { "id" "ID" +db-assigned-id+ }
        { "m" "M" BIG-INTEGER }
        { "n" "N" UNSIGNED-BIG-INTEGER }
        { "o" "O" SIGNED-BIG-INTEGER }
    } define-persistent
    [ ] [ bignum-test recreate-table ] unit-test
    [ ] [ 63 2^ 1 - dup dup <bignum-test> insert-tuple ] unit-test ;

    ! sqlite only
    ! [ T{ bignum-test f 1
        ! -9223372036854775808 9223372036854775808 -9223372036854775808 } ]
    ! [ T{ bignum-test f 1 } select-tuple ] unit-test ;

TUPLE: secret n message ;
C: <secret> secret

: test-random-id ( -- )
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
    [ class-of \ not-persistent = ] must-fail-with
] test-sqlite

[
    [ does-not-persist create-sql-statement ]
    [ class-of \ not-persistent = ] must-fail-with
] test-postgresql


TUPLE: suparclass id a ;

suparclass f {
    { "id" "ID" +db-assigned-id+ }
    { "a" "A" INTEGER }
} define-persistent

TUPLE: subbclass < suparclass b ;

subbclass "SUBCLASS" {
    { "b" "B" TEXT }
} define-persistent

TUPLE: fubbclass < subbclass ;

fubbclass "FUBCLASS" { } define-persistent

: test-db-inheritance ( -- )
    [ ] [ subbclass ensure-table ] unit-test
    [ ] [ fubbclass ensure-table ] unit-test

    [ ] [
        subbclass new 5 >>a "hi" >>b dup insert-tuple id>> "id" set
    ] unit-test

    [ t "hi" 5 ] [
        subbclass new "id" get >>id select-tuple
        [ subbclass? ] [ b>> ] [ a>> ] tri
    ] unit-test

    [ ] [ fubbclass new 0 >>a "hi" >>b insert-tuple ] unit-test

    [ t ] [ fubbclass new select-tuples [ fubbclass? ] all? ] unit-test ;

[ test-db-inheritance ] test-sqlite
[ test-db-inheritance ] test-postgresql


TUPLE: string-encoding-test id string ;

string-encoding-test "STRING_ENCODING_TEST" {
    { "id" "ID" +db-assigned-id+ }
    { "string" "STRING" TEXT }
} define-persistent

: test-string-encoding ( -- )
    [ ] [ string-encoding-test ensure-table ] unit-test

    [ ] [
        string-encoding-test new
            "\u{copyright-sign}\u{bengali-letter-cha}" >>string
        [ insert-tuple ] [ id>> "id" set ] bi
    ] unit-test

    [ "\u{copyright-sign}\u{bengali-letter-cha}" ] [
        string-encoding-test new "id" get >>id select-tuple string>>
    ] unit-test ;

[ test-string-encoding ] test-sqlite
[ test-string-encoding ] test-postgresql

: test-queries ( -- )
    [ ] [ exam ensure-table ] unit-test
    [ ] [ 1000 [ random-exam insert-tuple ] times ] unit-test
    [ 5 ] [
        <query>
        T{ exam { score T{ interval { from { 0 t } } { to { 100 t } } } } }
            >>tuple
        5 >>limit select-tuples length
    ] unit-test ;

TUPLE: compound-foo a b c ;

compound-foo "COMPOUND_FOO"
{
    { "a" "A" INTEGER +user-assigned-id+ }
    { "b" "B" INTEGER +user-assigned-id+ }
    { "c" "C" INTEGER }
} define-persistent

: test-compound-primary-key ( -- )
    [ ] [ compound-foo ensure-table ] unit-test
    [ ] [ compound-foo drop-table ] unit-test
    [ ] [ compound-foo create-table ] unit-test
    [ ] [ 1 2 3 compound-foo boa insert-tuple ] unit-test
    [ 1 2 3 compound-foo boa insert-tuple ] must-fail
    [ ] [ 2 3 4 compound-foo boa insert-tuple ] unit-test
    [ T{ compound-foo { a 2 } { b 3 } { c 4 } } ]
    [ compound-foo new 4 >>c select-tuple ] unit-test ;

[ test-compound-primary-key ] test-sqlite
[ test-compound-primary-key ] test-postgresql

TUPLE: timez id time ;

timez "TIMEZ"
{
    { "id" "ID" +db-assigned-id+ }
    { "time" "TIME" TIME }
} define-persistent

: test-time-types ( -- )
    timez ensure-table
    timez new 3 hours >>time insert-tuple
    {
        T{ duration f 0 0 0 3 0 0 }
    } [
        timez new 3 hours >>time select-tuple time>>
    ] unit-test ;

[ test-time-types ] test-sqlite
[ test-time-types ] test-postgresql

TUPLE: example id data ;

example "EXAMPLE"
{
    { "id" "ID" +db-assigned-id+ }
    { "data" "DATA" BLOB }
} define-persistent

: test-blob-select ( -- )
    example ensure-table
    [ ] [ example new B{ 1 2 3 4 5 } >>data insert-tuple ] unit-test
    [
        T{ example { id 1 } { data B{ 1 2 3 4 5 } } }
    ] [ example new B{ 1 2 3 4 5 } >>data select-tuple ] unit-test ;

[ test-blob-select ] test-sqlite
[ test-blob-select ] test-postgresql

TUPLE: select-me id data ;

select-me "select_me"
{
    { "id" "ID" +db-assigned-id+ }
    { "data" "DATA" TEXT }
} define-persistent

: test-mapping ( -- )
    [ ] [ select-me recreate-table ] unit-test
    [ ] [ select-me new                insert-tuple ] unit-test
    [ ] [ select-me new "test2" >>data insert-tuple ] unit-test

    [
        T{ select-me { id 1 } { data f } }
        T{ select-me { id 2 } { data "test2" } }
    ] [ select-me new select-tuples first2 ] unit-test

    [ V{ f "test2" } ]
    [
        select-me new [ data>> ] collector [ each-tuple ] dip
    ] unit-test

    [ { "test" "test2" } ] [
        select-me new NULL >>data [ "test" >>data ] update-tuples
        select-me new [ data>> ] collector [ each-tuple ] dip
        sort
    ] unit-test

    [ { "test1" "test2" } ] [
        select-me new [
            dup data>> "test" = [ "test1" >>data ] [ drop f ] if
        ] update-tuples
        select-me new [ data>> ] collector [ each-tuple ] dip
        sort
    ] unit-test

    [ { "test2" } ] [
        select-me new [ data>> "test1" = ] reject-tuples
        select-me new [ data>> ] collector [ each-tuple ] dip
        sort
    ] unit-test ;

[ test-mapping ] test-sqlite
[ test-mapping ] test-postgresql
