! Copyright (C) 2009 Philipp Brüschweiler
! See https://factorcode.org/license.txt for BSD license.
USING: infix infix.private kernel literals locals math
math.constants math.functions sequences tools.test ;
IN: infix.tests

{ 0 } [ [infix 0 infix] ] unit-test
{ 0.5 } [ [infix 3.0/6 infix] ] unit-test
{ 1+2/3 } [ [infix 5/3 infix] ] unit-test
{ 3 } [ [infix 2*7%3+1 infix] ] unit-test
{ 1419857 } [ [infix 17**5 infix] ] unit-test
{ 1 } [ [infix 2-
    1
    -5*
    0 infix]
] unit-test

{ 0.0 } [ [infix sin(0) infix] ] unit-test
{ 10 } [ [infix lcm(2,5) infix] ] unit-test
{ 1.0 } [ [infix +cos(-0*+3) infix] ] unit-test

{ f } [ 2 \ gcd check-word ] unit-test ! multiple return values
{ f } [ 1 \ drop check-word ] unit-test ! no return value
{ f } [ 1 \ lcm check-word ] unit-test ! takes 2 args

: qux ( -- x ) 2 ;
{ t } [ 0 \ qux check-word ] unit-test
{ 8 } [ [infix qux()*3+2 infix] ] unit-test
: foobar ( x -- y ) 1 + ;
{ t } [ 1 \ foobar check-word ] unit-test
{ 4 } [ [infix foobar(3*5%12) infix] ] unit-test
: stupid_function ( x x x x x -- y ) + + + + ;
{ t } [ 5 \ stupid_function check-word ] unit-test
{ 10 } [ [infix stupid_function (0, 1, 2, 3, 4) infix] ] unit-test

{ -1 } [ [let 1 :> a [infix -a infix] ] ] unit-test

{ CHAR: f } [ [let "foo" :> s [infix s[0] infix] ] ] unit-test
{ CHAR: r } [ [let "bar" :> s [infix s[-1] infix] ] ] unit-test
{ "foo" } [ [let "foobar" :> s [infix s[0:3] infix] ] ] unit-test
{ "foo" } [ [let "foobar" :> s [infix s[:3] infix] ] ] unit-test
{ "bar" } [ [let "foobar" :> s [infix s[-3:] infix] ] ] unit-test
{ "boof" } [ [let "foobar" :> s [infix s[-3::-1] infix] ] ] unit-test
{ "foobar" } [ [let "foobar" :> s [infix s[:] infix] ] ] unit-test
{ "foa" } [ [let "foobar" :> s [infix s[::2] infix] ] ] unit-test
{ "bar" } [ [let "foobar" :> s [infix s[-3:100] infix] ] ] unit-test
{ "foobar" } [ [let "foobar" :> s [infix s[-100:100] infix] ] ] unit-test
{ "olh" } [ [let "hello" :> s [infix s[4::-2] infix] ] ] unit-test
{ "rb" } [ [let "foobar" :> s [infix s[:1:-2] infix] ] ] unit-test
{ "foa" } [ [let "foobar" :> s [infix s[:-1:2] infix] ] ] unit-test
{ "rbo" } [ [let "foobar" :> s [infix s[::-2] infix] ] ] unit-test
{ "rbo" } [ [let "foobar" :> s [infix s[:0:-2] infix] ] ] unit-test
{ "rb" } [ [let "foobar" :> s [infix s[:-5:-2] infix] ] ] unit-test

INFIX:: foo ( x y -- z ) x**2-abs(y) ;

{ 194 } [ 15 31 foo ] unit-test

{ "foobar" } [
    [let "foo" :> foo
        [let "bar" :> bar
            [infix append(foo, bar) infix]
        ]
    ]
] unit-test

{ "foobar" } [ [infix append("foo", "bar") infix] ] unit-test

${ pi } [ [infix pi infix] ] unit-test
