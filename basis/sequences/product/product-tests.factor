! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel make math sequences sequences.product tools.test ;

{ { { 0 "a" } { 0 "b" } { 1 "a" } { 1 "b" } { 2 "a" } { 2 "b" } } }
[ { { 0 1 2 } { "a" "b" } } <product-sequence> >array ] unit-test

{ { "a" "b" "aa" "bb" "aaa" "bbb" } }
[ { { 1 2 3 } { "a" "b" } } [ first2 <repetition> concat ] product-map ] unit-test

{
    {
        { 0 "a" t }
        { 0 "a" f }
        { 0 "b" t }
        { 0 "b" f }
        { 1 "a" t }
        { 1 "a" f }
        { 1 "b" t }
        { 1 "b" f }
        { 2 "a" t }
        { 2 "a" f }
        { 2 "b" t }
        { 2 "b" f }
    }
} [ { { 0 1 2 } { "a" "b" } { t f } } [ ] product-map ] unit-test

{ "a1a2b1b2c1c2" } [
    [
        { { "a" "b" "c" } { "1" "2" } }
        [ [ % ] each ] product-each
    ] "" make
] unit-test

{ { } } [ { { } { 1 } } [ ] product-map ] unit-test
{ } [ { { } { 1 } } [ drop ] product-each ] unit-test

{ f } [
    { } [ sum zero? ] product-find
] unit-test

{ f } [
    { f } [ sum zero? ] product-find
] unit-test

{ { 2 4 8 } } [
    { { 1 2 3 } { 4 5 6 } { 7 8 9 } }
    [ [ even? ] all? ] product-find
] unit-test

{ f } [
    { { 1 2 3 } { 4 5 6 } { 7 8 9 } }
    [ [ 10 > ] all? ] product-find
] unit-test
