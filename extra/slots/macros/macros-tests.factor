! Copyright (C) 2011 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math slots.macros tools.test ;
IN: slots.macros.tests

TUPLE: foo a b c ;

{ 1 } [ T{ foo { a 1 } { b 2 } { c 3 } } "a" slot ] unit-test

{ T{ foo { b 4 } } } [
    foo new
    [ 4 swap "b" set-slot ] keep
] unit-test

{ T{ foo { a 7 } { b 5 } { c 6 } } } [
    foo new
        5 "b" set-slot*
        6 "c" set-slot*
        7 "a" set-slot*
] unit-test

{ T{ foo { a 1 } { b 4 } { c 3 } } } [
    T{ foo { a 1 } { b 2 } { c 3 } } clone
    [ "b" [ 2 * ] change-slot ] keep
] unit-test

{ T{ foo { a 1/3 } { b 4 } { c 3 } } } [
    T{ foo { a 1 } { b 2 } { c 3 } } clone
    "b" [ 2 * ] change-slot*
    "a" [ 3 / ] change-slot*
] unit-test

{ T{ foo { a 9 } { b 1 } } } [
    T{ foo { a 8 } } clone
    [ "a" inc-slot ]
    [ "b" inc-slot ]
    [ ] tri
] unit-test

{ T{ foo { a 12 } { b 3 } } } [
    T{ foo { a 10 } } clone
    [ 2 swap "a" slot+ ]
    [ 3 swap "b" slot+ ]
    [ ] tri
] unit-test

{ T{ foo { a V{ 1 2 } } { b V{ 3 } } } } [
    foo new
    V{ 1 } clone "a" set-slot*
    [ 2 swap "a" push-slot ]
    [ 3 swap "b" push-slot ]
    [ ] tri
] unit-test

{ 2 1 3 } [
    T{ foo { a 1 } { b 2 } { c 3 } }
    { "b" "a" "c" } slots
] unit-test

{ { 2 1 3 } } [
    T{ foo { a 1 } { b 2 } { c 3 } }
    { "b" "a" "c" } slots>array
] unit-test

{ T{ foo { a "one" } { b "two" } { c "three" } } } [
    "two" "one" "three"
    T{ foo { a 1 } { b 2 } { c 3 } } clone
    [ { "b" "a" "c" } set-slots ] keep
] unit-test

{ T{ foo { a "one" } { b "two" } { c "three" } } } [
    { "two" "one" "three" }
    T{ foo { a 1 } { b 2 } { c 3 } } clone
    [ { "b" "a" "c" } array>set-slots ] keep
] unit-test
