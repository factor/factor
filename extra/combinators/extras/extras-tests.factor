! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators.extras io.files kernel math
modern.slices sequences splitting tools.test ;
IN: combinators.extras.tests


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

{ "hi " "there" } [
    "hi there" {
        { [ dup "there" subsequence-starts ] [ cut ] }
        [ f ]
    } cond*
] unit-test

{ "hi " "there" } [
    "hi there" {
        { [ dup "foo" subsequence-starts ] [ head f ] }
        { [ dup "there" subsequence-starts ] [ cut ] }
        [ f ]
    } cond*
] unit-test

{ "hi there" f } [
    "hi there" {
        { [ dup "foo" subsequence-starts ] [ head f ] }
        { [ dup "bar" subsequence-starts ] [ cut ] }
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

{ 1 2 3 } [ 1 2 [ 3 ] dip-1up ] unit-test
{ 2 2 } [ 1 2 [ 1 + ] dip-1up ] unit-test
{ 20 11 } [ 10 20 [ 1 + ] dip-1up ] unit-test

{ 0 10 20 30 40 50 60 80 71 } [ 0 10 20 30 40 50 60 70 80 [ 1 + ]  dip-1up ] unit-test
{ 0 10 20 30 40 50 70 80 61 } [ 0 10 20 30 40 50 60 70 80 [ 1 + ] 2dip-1up ] unit-test
{ 0 10 20 30 40 60 70 80 51 } [ 0 10 20 30 40 50 60 70 80 [ 1 + ] 3dip-1up ] unit-test


{ 0 10 20 30 40 50 80 61 71 } [ 0 10 20 30 40 50 60 70 80 [ [ 1 + ] bi@ ]  dip-2up ] unit-test
{ 0 10 20 30 40 70 80 51 61 } [ 0 10 20 30 40 50 60 70 80 [ [ 1 + ] bi@ ] 2dip-2up ] unit-test
{ 0 10 20 30 60 70 80 41 51 } [ 0 10 20 30 40 50 60 70 80 [ [ 1 + ] bi@ ] 3dip-2up ] unit-test

{ 0 10 20 60 70 80 31 41 51 } [ 0 10 20 30 40 50 60 70 80 [ [ 1 + ] tri@ ] 3dip-3up ] unit-test

{ 4 "abcd" 97 98 99 100 } [
    0 "abcd"
    [ [ CHAR: a = ] accept1 ]
    [ [ CHAR: b = ] accept1 ]
    [ [ CHAR: c = ] accept1 ]
    [ [ CHAR: d = ] accept1 ] 4craft-1up
] unit-test

{ 20 30 2500 } [ 20 30 [ + sq ] 2keep-1up ] unit-test

{ 10 1 } [ 10 [ drop 1 ] keep-1up ] unit-test
{ 10 20 1 } [ 10 20 [ 2drop 1 ] 2keep-1up ] unit-test
{ 10 20 30 1 } [ 10 20 30 [ 3drop 1 ] 3keep-1up ] unit-test


{ 10 1 } [ 10 [ drop 1 ] keep-1up ] unit-test
{ 10 20 1 } [ 10 20 [ 2drop 1 ] 2keep-1up ] unit-test
{ 10 20 30 1 } [ 10 20 30 [ 3drop 1 ] 3keep-1up ] unit-test

{ 10 1 2 } [ 10 [ drop 1 2 ] keep-2up ] unit-test
{ 10 20 1 2 } [ 10 20 [ 2drop 1 2 ] 2keep-2up ] unit-test
{ 10 20 30 1 2 } [ 10 20 30 [ 3drop 1 2 ] 3keep-2up ] unit-test

{ 10 1 2 3 } [ 10 [ drop 1 2 3 ] keep-3up ] unit-test
{ 10 20 1 2 3 } [ 10 20 [ 2drop 1 2 3 ] 2keep-3up ] unit-test
{ 10 20 30 1 2 3 } [ 10 20 30 [ 3drop 1 2 3 ] 3keep-3up ] unit-test

: test-keep-under ( -- a b c d e ) 1 [ [ 5 + ] call 10 20 30 ] keep-under ;
: test-2keep-under ( -- a b c d e f g ) 1 2 [ [ 5 + ] bi@ 10 20 30 ] 2keep-under ;
: test-3keep-under ( -- a b c d e f g h i ) 1 2 3 [ [ 5 + ] tri@ 10 20 30 ] 3keep-under ;
: test-4keep-under ( -- a b c d e f g h i j k l ) 1 2 3 4 [ [ 5 + ] quad@ 10 20 30 40 ] 4keep-under ;

{ 1 6 10 20 30 } [ test-keep-under ] unit-test
{ 1 2 6 7 10 20 30 } [ test-2keep-under ] unit-test
{ 1 2 3 6 7 8 10 20 30 } [ test-3keep-under ] unit-test
{ 1 2 3 4  6 7 8 9 10 20 30 40 } [ test-4keep-under ] unit-test

{ 1 2 3 4 1 2 3 4 5 } [ 1 2 3 4 [ 5 ] 4keep-under ] unit-test
{ 1 2 3 4 1 2 3 4 5 6 7 8 9 10 } [ 1 2 3 4 [ 5 6 7 8 9 10 ] 4keep-under ] unit-test


{ 3 { 1 2 3 } }
[ 0 { 1 2 3 } [ 1 + ] 1temp1d map ] unit-test

{ 3 { { 1 1 } { 2 2 } { 3 3 } } }
[ 0 { { 1 1 } { 2 2 } { 3 3 } } [ 1 + ] 1temp2d assoc-map ] unit-test

{ 103 203 { { 1 1 } { 2 2 } { 3 3 } } }
[ 100 200 { { 1 1 } { 2 2 } { 3 3 } } [ [ 1 + ] bi@ ] 2temp2d assoc-map ] unit-test

