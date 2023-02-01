! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors math.order sorting.specification tools.test
arrays sequences kernel assocs multiline sorting.functor ;
IN: sorting.specification.tests

TUPLE: sort-test a b c tuple2 ;

TUPLE: tuple2 d ;

{
    {
        T{ sort-test { a 1 } { b 3 } { c 9 } }
        T{ sort-test { a 1 } { b 1 } { c 10 } }
        T{ sort-test { a 1 } { b 1 } { c 11 } }
        T{ sort-test { a 2 } { b 5 } { c 2 } }
        T{ sort-test { a 2 } { b 5 } { c 3 } }
    }
} [
    {
        T{ sort-test f 1 3 9 }
        T{ sort-test f 1 1 10 }
        T{ sort-test f 1 1 11 }
        T{ sort-test f 2 5 3 }
        T{ sort-test f 2 5 2 }
    } { { a>> <=> } { b>> >=< } { c>> <=> } } sort-with-spec
] unit-test

{
    {
        T{ sort-test { a 1 } { b 3 } { c 9 } }
        T{ sort-test { a 1 } { b 1 } { c 10 } }
        T{ sort-test { a 1 } { b 1 } { c 11 } }
        T{ sort-test { a 2 } { b 5 } { c 2 } }
        T{ sort-test { a 2 } { b 5 } { c 3 } }
    }
} [
    {
        T{ sort-test f 1 3 9 }
        T{ sort-test f 1 1 10 }
        T{ sort-test f 1 1 11 }
        T{ sort-test f 2 5 3 }
        T{ sort-test f 2 5 2 }
    } { { a>> <=> } { b>> >=< } { c>> <=> } } sort-with-spec
] unit-test

{ { } } [
    { } { { a>> <=> } { b>> >=< } { c>> <=> } } sort-with-spec
] unit-test

{ { } } [ { } { } sort-with-spec ] unit-test

{
    {
        T{ sort-test { a 6 } { tuple2 T{ tuple2 { d 1 } } } }
        T{ sort-test { a 6 } { tuple2 T{ tuple2 { d 2 } } } }
        T{ sort-test { a 5 } { tuple2 T{ tuple2 { d 3 } } } }
        T{ sort-test { a 6 } { tuple2 T{ tuple2 { d 3 } } } }
        T{ sort-test { a 6 } { tuple2 T{ tuple2 { d 3 } } } }
        T{ sort-test { a 5 } { tuple2 T{ tuple2 { d 4 } } } }
    }
} [
    {
        T{ sort-test f 6 f f T{ tuple2 f 1 } }
        T{ sort-test f 5 f f T{ tuple2 f 4 } }
        T{ sort-test f 6 f f T{ tuple2 f 3 } }
        T{ sort-test f 6 f f T{ tuple2 f 3 } }
        T{ sort-test f 5 f f T{ tuple2 f 3 } }
        T{ sort-test f 6 f f T{ tuple2 f 2 } }
    } { { tuple2>> d>> <=> } { a>> <=> } } sort-with-spec
] unit-test


{ { "a" "b" "c" } } [ { "b" "c" "a" } { <=> <=> } sort-with-spec ] unit-test
{ { "b" "c" "a" } } [ { "b" "c" "a" } { } sort-with-spec ] unit-test

<< "length-test" [ length ] define-sorting >>

{ { { 1 } { 1 2 3 } { 1 3 2 } { 3 2 1 } } }
[
    { { 3 2 1 } { 1 2 3 } { 1 3 2 } { 1 } }
    { length-test<=> <=> } sort-with-spec
] unit-test

{ { { { 0 } 1 } { { 1 } 2 } { { 1 } 1 } { { 3 1 } 2 } } }
[
    { { { 3 1 } 2 } { { 1 } 2 } { { 0 } 1 } { { 1 } 1 } }
    { length-test<=> <=> } sort-keys-with-spec
] unit-test

{ { { 0 { 1 } } { 1 { 1 } } { 3 { 2 4 } } { 1 { 2 0 0 0 } } } }
[
    { { 3 { 2 4 } } { 1 { 2 0 0 0 } } { 0 { 1 } } { 1 { 1 } } }
    { length-test<=> <=> } sort-values-with-spec
] unit-test

{ { { "apples" 1 } { "bananas" 2 } { "cherries" 3 } } } [
    H{ { "apples" 1 } { "bananas" 2 } { "cherries" 3 } }
    { { sequences:length <=> } } sort-keys-with-spec
] unit-test
