! Copyright (c) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test splay-trees namespaces assocs
sequences random ;
IN: temporary

: randomize-numeric-splay-tree ( splay-tree -- )
    100 [ drop 100 random swap at drop ] curry* each ;

: make-numeric-splay-tree ( n -- splay-tree )
    dup <splay-tree> -rot [ pick set-at ] 2each ;

[ t ] [
    100 make-numeric-splay-tree dup randomize-numeric-splay-tree
    [ [ drop , ] assoc-each ] { } make [ < ] monotonic?
] unit-test

[ 10 ] [ 10 make-numeric-splay-tree keys length ] unit-test
[ 10 ] [ 10 make-numeric-splay-tree values length ] unit-test

[ f ] [ <splay-tree> f 4 pick set-at 4 swap at ] unit-test

! Ensure that f can be a value
[ t ] [ <splay-tree> f 4 pick set-at 4 swap key? ] unit-test

[
{ { 1 "a" } { 2 "b" } { 3 "c" } { 4 "d" } { 5 "e" } { 6 "f" } }
] [
{
    { 4 "d" } { 5 "e" } { 6 "f" }
    { 1 "a" } { 2 "b" } { 3 "c" }
} >splay-tree >alist
] unit-test
