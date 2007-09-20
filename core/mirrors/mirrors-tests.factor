USING: mirrors tools.test assocs kernel arrays ;
IN: temporary

TUPLE: foo bar baz ;

C: <foo> foo

[ { foo-bar foo-baz } ] [ 1 2 <foo> <mirror> keys ] unit-test

[ 1 t ] [ \ foo-bar 1 2 <foo> <mirror> at* ] unit-test

[ f f ] [ "hi" 1 2 <foo> <mirror> at* ] unit-test

[ 3 ] [
    3 \ foo-baz 1 2 <foo> [ <mirror> set-at ] keep foo-baz
] unit-test
