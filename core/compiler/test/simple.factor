USING: compiler tools.test kernel kernel.private
combinators.private ;
IN: temporary

! Test empty word
[ ] [ [ ] compile-call ] unit-test

! Test literals
[ 1 ] [ [ 1 ] compile-call ] unit-test
[ 31 ] [ [ 31 ] compile-call ] unit-test
[ 255 ] [ [ 255 ] compile-call ] unit-test
[ -1 ] [ [ -1 ] compile-call ] unit-test
[ 65536 ] [ [ 65536 ] compile-call ] unit-test
[ -65536 ] [ [ -65536 ] compile-call ] unit-test
[ "hey" ] [ [ "hey" ] compile-call ] unit-test

! Calls
: no-op ;

[ ] [ [ no-op ] compile-call ] unit-test
[ 3 ] [ [ no-op 3 ] compile-call ] unit-test
[ 3 ] [ [ 3 no-op ] compile-call ] unit-test

: bar 4 ;

[ 4 ] [ [ bar no-op ] compile-call ] unit-test
[ 4 3 ] [ [ no-op bar 3 ] compile-call ] unit-test
[ 3 4 ] [ [ 3 no-op bar ] compile-call ] unit-test

[ ] [ no-op ] unit-test

! Conditionals

[ 1 ] [ t [ [ 1 ] [ 2 ] if ] compile-call ] unit-test
[ 2 ] [ f [ [ 1 ] [ 2 ] if ] compile-call ] unit-test
[ 1 3 ] [ t [ [ 1 ] [ 2 ] if 3 ] compile-call ] unit-test
[ 2 3 ] [ f [ [ 1 ] [ 2 ] if 3 ] compile-call ] unit-test

[ "hi" ] [ 0 [ { [ "hi" ] [ "bye" ] } dispatch ] compile-call ] unit-test
[ "bye" ] [ 1 [ { [ "hi" ] [ "bye" ] } dispatch ] compile-call ] unit-test

[ "hi" 3 ] [ 0 [ { [ "hi" ] [ "bye" ] } dispatch 3 ] compile-call ] unit-test
[ "bye" 3 ] [ 1 [ { [ "hi" ] [ "bye" ] } dispatch 3 ] compile-call ] unit-test

[ 4 1 ] [ 0 [ { [ bar 1 ] [ 3 1 ] } dispatch ] compile-call ] unit-test
[ 3 1 ] [ 1 [ { [ bar 1 ] [ 3 1 ] } dispatch ] compile-call ] unit-test
[ 4 1 3 ] [ 0 [ { [ bar 1 ] [ 3 1 ] } dispatch 3 ] compile-call ] unit-test
[ 3 1 3 ] [ 1 [ { [ bar 1 ] [ 3 1 ] } dispatch 3 ] compile-call ] unit-test

! Labels

: recursive ( ? -- ) [ f recursive ] when ; inline

[ ] [ t [ recursive ] compile-call ] unit-test

[ ] [ t recursive ] unit-test

! Make sure error reporting works

[ [ dup ] compile-call ] unit-test-fails
[ [ drop ] compile-call ] unit-test-fails

! Regression

[ ] [ [ callstack ] compile-call drop ] unit-test

! Regression

: empty ;

[ "b" ] [ 1 [ empty { [ "a" ] [ "b" ] } dispatch ] compile-call ] unit-test
