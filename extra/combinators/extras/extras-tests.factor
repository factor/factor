! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.extras io.files kernel math sequences
tools.test ;

{ "a b" }
[ "a" "b" [ " " glue ] once ] unit-test

{ "a b c" }
[ "a" "b" "c" [ " " glue ] twice ] unit-test

{ "a b c d" }
[ "a" "b" "c" "d" [ " " glue ] thrice ] unit-test

{ { "negative" 0 "positive" } } [
    { -1 0 1 } [
        {
           { [ 0 > ] [ "positive" ] }
           { [ 0 < ] [ "negative" ] }
           [ ]
        } cond-case
    ] map
] unit-test

{ { 1 2 3 } } [ 1 { [ ] [ 1 + ] [ 2 + ] } cleave-array ] unit-test

{ 2 15 } [ 1 2 3 4 5 6 [ - - ] [ + + ] 3bi* ] unit-test

{ 2 5 } [ 1 2 3 4 5 6 [ - - ] 3bi@ ] unit-test

{ 3 1 } [ 1 2 [ + ] keepd ] unit-test

{ "1" "123" } [ "1" "123" [ length ] [ > ] swap-when ] unit-test
{ "123" "1" } [ "1" "123" [ length ] [ < ] swap-when ] unit-test


{ t } [ "resource:" [ exists? ] ?1arg >boolean ] unit-test
{ f } [ f [ exists? ] ?1arg ] unit-test
{ f } [ "/homeasdfasdf123123" [ exists? ] ?1arg ] unit-test

{ "hi " "there" } [
    "hi there" {
        { [ "there" over subseq-start ] [ cut ] }
        [ f ]
    } cond*
] unit-test

{ "hi " "there" } [
    "hi there" {
        { [ "foo" over subseq-start ] [ head f ] }
        { [ "there" over subseq-start ] [ cut ] }
        [ f ]
    } cond*
] unit-test

{ "hi there" f } [
    "hi there" {
        { [ "foo" over subseq-start ] [ head f ] }
        { [ "bar" over subseq-start ] [ cut ] }
        [ f ]
    } cond*
] unit-test
