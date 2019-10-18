! Copyright (c) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test trees.splay math namespaces assocs
sequences random sets make grouping ;
IN: trees.splay.tests

: randomize-numeric-splay-tree ( splay-tree -- )
    100 iota [ drop 100 random of drop ] with each ;

: make-numeric-splay-tree ( n -- splay-tree )
    iota <splay> [ [ conjoin ] curry each ] keep ;

[ t ] [
    100 make-numeric-splay-tree dup randomize-numeric-splay-tree
    [ [ drop , ] assoc-each ] { } make [ < ] monotonic?
] unit-test

[ 10 ] [ 10 make-numeric-splay-tree keys length ] unit-test
[ 10 ] [ 10 make-numeric-splay-tree values length ] unit-test

[ f ] [ <splay> f 4 pick set-at 4 of ] unit-test

! Ensure that f can be a value
[ t ] [ <splay> f 4 pick set-at 4 swap key? ] unit-test

[
{ { 1 "a" } { 2 "b" } { 3 "c" } { 4 "d" } { 5 "e" } { 6 "f" } }
] [
{
    { 4 "d" } { 5 "e" } { 6 "f" }
    { 1 "a" } { 2 "b" } { 3 "c" }
} >splay >alist
] unit-test

[ 0 ] [
    100 iota [ dup zip >splay ] keep
    [ over delete-at ] each assoc-size
] unit-test
