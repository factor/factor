! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs combinators.extras io.files kernel math sequences
splitting tools.test splitting ;

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


{ t } [ "resource:" [ file-exists? ] ?1arg >boolean ] unit-test
{ f } [ f [ file-exists? ] ?1arg ] unit-test
{ f } [ "/homeasdfasdf123123" [ file-exists? ] ?1arg ] unit-test

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

{ f } [ f { } chain ] unit-test
{ 3 } [ H{ { 1 H{ { 2 3 } } } } { [ 1 of ] [ 2 of ] } chain ] unit-test
{ f } [ H{ { 1 H{ { 3 4 } } } } { [ 1 of ] [ 2 of ] } chain ] unit-test
{ f } [ H{ { 2 H{ { 3 4 } } } } { [ 1 of ] [ 2 of ] } chain ] unit-test
{ 5 } [
    "hello factor!" { [ split-words ] [ first ] [ length ] } chain
] unit-test

{
    { 1 2 3 4 }
    { 1 2 3 4 }
    { 1 2 3 4 }
    { 1 2 3 4 }
} [
    1 2 3 4
    [ 4array ] [ 4array ] [ 4array ] [ 4array ] 4quad
] unit-test

{
    { 1 2 3 4 }
    { 5 6 7 8 }
    { 9 10 11 12 }
} [
    1 2 3 4  5 6 7 8  9 10 11 12
    [ 4array ] [ 4array ] [ 4array ] 4tri*
] unit-test

{
    { 1 2 3 4 }
    { 5 6 7 8 }
    { 9 10 11 12 }
} [
    1 2 3 4  5 6 7 8  9 10 11 12
    [ 4array ] 4tri@
] unit-test