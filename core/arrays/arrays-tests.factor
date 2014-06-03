USING: accessors arrays kernel sequences sequences.private growable
tools.test vectors layouts system math vectors.private ;
IN: arrays.tests

[ -2 { "a" "b" "c" } nth ] must-fail
[ 10 { "a" "b" "c" } nth ] must-fail
[ "hi" -2 { "a" "b" "c" } set-nth ] must-fail
[ "hi" 10 { "a" "b" "c" } set-nth ] must-fail
[ f ] [ { "a" "b" "c" } dup clone eq? ] unit-test
[ "hi" ] [ "hi" 1 { "a" "b" "c" } clone [ set-nth ] keep second ] unit-test
[ V{ "a" "b" "c" } ] [ { "a" "b" "c" } >vector ] unit-test
[ f ] [ { "a" "b" "c" } dup >array eq? ] unit-test
[ t ] [ { "a" "b" "c" } dup { } like eq? ] unit-test
[ t ] [ { "a" "b" "c" } dup dup length vector boa underlying>> eq? ] unit-test
[ V{ "a" "b" "c" } ] [ { "a" "b" "c" } V{ } like ] unit-test
[ { "a" "b" "c" } ] [ { "a" } { "b" "c" } append ] unit-test
[ { "a" "b" "c" "d" "e" } ]
[ { "a" } { "b" "c" } { "d" "e" } 3append ] unit-test

[ -1 f <array> ] must-fail
[ cell-bits cell log2 - 2^ f <array> ] must-fail
! To big for a fixnum #1045
[ 67 2^ 3 <array> ] must-fail
