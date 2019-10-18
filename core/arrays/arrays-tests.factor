USING: arrays kernel sequences sequences.private growable
tools.test vectors layouts system math math.functions
vectors.private ;
IN: temporary

[ -2 { "a" "b" "c" } nth ] unit-test-fails
[ 10 { "a" "b" "c" } nth ] unit-test-fails
[ "hi" -2 { "a" "b" "c" } set-nth ] unit-test-fails
[ "hi" 10 { "a" "b" "c" } set-nth ] unit-test-fails
[ f ] [ { "a" "b" "c" } dup clone eq? ] unit-test
[ "hi" ] [ "hi" 1 { "a" "b" "c" } clone [ set-nth ] keep second ] unit-test
[ V{ "a" "b" "c" } ] [ { "a" "b" "c" } >vector ] unit-test
[ f ] [ { "a" "b" "c" } dup >array eq? ] unit-test
[ t ] [ { "a" "b" "c" } dup { } like eq? ] unit-test
[ t ] [ { "a" "b" "c" } dup dup length array>vector underlying eq? ] unit-test
[ V{ "a" "b" "c" } ] [ { "a" "b" "c" } V{ } like ] unit-test
[ { "a" "b" "c" } ] [ { "a" } { "b" "c" } append ] unit-test
[ { "a" "b" "c" "d" "e" } ]
[ { "a" } { "b" "c" } { "d" "e" } 3append ] unit-test

[ -1 f <array> ] unit-test-fails
[ cell-bits cell log2 - 2^ f <array> ] unit-test-fails
