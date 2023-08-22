! Copyright (c) 2005 Mackenzie Straight.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs fry grouping kernel math random sequences sets
tools.test trees.splay ;
IN: trees.splay.tests

: randomize-numeric-splay-tree ( splay-tree -- )
    100 <iota> [ drop 100 random of drop ] with each ;

: make-numeric-splay-tree ( n -- splay-tree )
    <iota> <splay> [ '[ dup _ set-at ] each ] keep ;

{ t } [
    100 make-numeric-splay-tree dup randomize-numeric-splay-tree
    [ drop ] { } assoc>map [ < ] monotonic?
] unit-test

{ 10 } [ 10 make-numeric-splay-tree keys length ] unit-test
{ 10 } [ 10 make-numeric-splay-tree values length ] unit-test

{ f } [ <splay> f 4 pick set-at 4 of ] unit-test

! Ensure that f can be a value
{ t } [ <splay> f 4 pick set-at 4 swap key? ] unit-test

{
    { { 1 "a" } { 2 "b" } { 3 "c" } { 4 "d" } { 5 "e" } { 6 "f" } }
} [
    {
        { 4 "d" } { 5 "e" } { 6 "f" }
        { 1 "a" } { 2 "b" } { 3 "c" }
    } >splay >alist
] unit-test

{ 0 } [
    100 <iota> [ dup zip >splay ] keep
    [ over delete-at ] each assoc-size
] unit-test

: test-tree ( -- tree )
    SPLAY{
        { 7 "seven" }
        { 9 "nine" }
        { 4 "four" }
        { 4 "replaced four" }
        { 7 "replaced seven" }
    } clone ;

! test assoc-size
{ 3 } [ test-tree assoc-size ] unit-test
{ 2 } [ test-tree 9 over delete-at assoc-size ] unit-test

! Test that converting trees doesn't give linked lists
{
    SPLAY{ { 1 1 } { 3 3 } { 2 2 } }
} [ SPLAY{ { 1 1 } { 3 3 } { 2 2 } } >splay ] unit-test
