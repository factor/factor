USING: mirrors tools.test assocs kernel arrays accessors words
namespaces math slots parser eval ;
IN: mirrors.tests

TUPLE: foo bar baz ;

C: <foo> foo

{ 2 } [ 1 2 <foo> <mirror> assoc-size ] unit-test

{ { "bar" "baz" } } [ 1 2 <foo> <mirror> keys ] unit-test

{ 1 t } [ "bar" 1 2 <foo> <mirror> at* ] unit-test

{ f f } [ "hi" 1 2 <foo> <mirror> at* ] unit-test

{ 3 } [
    3 "baz" 1 2 <foo> [ <mirror> set-at ] keep baz>>
] unit-test

[ 3 "hi" 1 2 <foo> <mirror> set-at ] must-fail

[ 3 "numerator" 1/2 <mirror> set-at ] must-fail

{ "foo" } [
    gensym [
        <mirror> [
            "foo" "name" set
        ] with-variables
    ] [ name>> ] bi
] unit-test

[ gensym <mirror> [ "compiled" off ] with-variables ] must-fail

TUPLE: declared-mirror-test
{ a integer initial: 0 } ;

{ 5 } [
    3 declared-mirror-test boa <mirror> [
        5 "a" set
        "a" get
    ] with-variables
] unit-test

[ 3 declared-mirror-test boa <mirror> [ t "a" set ] with-variables ] must-fail

TUPLE: color
{ red integer }
{ green integer }
{ blue integer } ;

[ \ + make-mirror clear-assoc ] [ mirror-slot-removal? ] must-fail-with
[ \ + make-mirror [ "name" ] dip delete-at ] [ mirror-slot-removal? ] must-fail-with

! Test reshaping with a mirror
1 2 3 color boa <mirror> "mirror" set

{ } [ "IN: mirrors.tests USE: math TUPLE: color { green integer } { red integer } { blue integer } ;" eval( -- ) ] unit-test

{ 1 } [ "red" "mirror" get at ] unit-test

{ 3 } [ { 1 2 3 } make-mirror assoc-size ] unit-test
{ 4 } [ "asdf" make-mirror assoc-size ] unit-test
{ 8 } [ \ + make-mirror assoc-size ] unit-test
