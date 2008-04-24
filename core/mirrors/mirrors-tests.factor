USING: mirrors tools.test assocs kernel arrays accessors ;
IN: mirrors.tests

TUPLE: foo bar baz ;

C: <foo> foo

[ { "delegate" "bar" "baz" } ] [ 1 2 <foo> <mirror> keys ] unit-test

[ 1 t ] [ "bar" 1 2 <foo> <mirror> at* ] unit-test

[ f f ] [ "hi" 1 2 <foo> <mirror> at* ] unit-test

[ 3 ] [
    3 "baz" 1 2 <foo> [ <mirror> set-at ] keep foo-baz
] unit-test

[ 3 "hi" 1 2 <foo> <mirror> set-at ] [
    [ no-such-slot? ]
    [ name>> "hi" = ]
    [ object>> foo? ] tri and and
] must-fail-with

[ 3 "numerator" 1/2 <mirror> set-at ] [
    [ immutable-slot? ]
    [ name>> "numerator" = ]
    [ object>> 1/2 = ] tri and and
] must-fail-with
