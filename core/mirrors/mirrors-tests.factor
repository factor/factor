USING: mirrors tools.test assocs kernel arrays ;
IN: mirrors.tests

TUPLE: foo bar baz ;

C: <foo> foo

[ { "delegate" "bar" "baz" } ] [ 1 2 <foo> <mirror> keys ] unit-test

[ 1 t ] [ "bar" 1 2 <foo> <mirror> at* ] unit-test

[ f f ] [ "hi" 1 2 <foo> <mirror> at* ] unit-test

[ 3 ] [
    3 "baz" 1 2 <foo> [ <mirror> set-at ] keep foo-baz
] unit-test
