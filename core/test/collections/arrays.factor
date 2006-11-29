IN: temporary
USING: arrays kernel sequences sequences-internals test vectors ;

[ -2 { "a" "b" "c" } nth ] unit-test-fails
[ 10 { "a" "b" "c" } nth ] unit-test-fails
[ "hi" -2 { "a" "b" "c" } set-nth ] unit-test-fails
[ "hi" 10 { "a" "b" "c" } set-nth ] unit-test-fails
[ f ] [ { "a" "b" "c" } dup clone eq? ] unit-test
[ "hi" ] [ "hi" 1 { "a" "b" "c" } clone [ set-nth ] keep second ] unit-test
[ V{ "a" "b" "c" } ] [ { "a" "b" "c" } >vector ] unit-test
[ f ] [ { "a" "b" "c" } dup >array eq? ] unit-test
[ t ] [ { "a" "b" "c" } dup { } like eq? ] unit-test
[ t ] [ { "a" "b" "c" } dup array>vector underlying eq? ] unit-test
[ V{ "a" "b" "c" } ] [ { "a" "b" "c" } V{ } like ] unit-test
[ { "a" "b" "c" } ] [ { "a" } { "b" "c" } append ] unit-test
[ { "a" "b" "c" "d" "e" } ]
[ { "a" } { "b" "c" } { "d" "e" } append3 ] unit-test
