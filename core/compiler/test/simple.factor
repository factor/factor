USING: compiler tools.test kernel kernel.private
combinators.private ;
IN: temporary

! Test empty word
[ ] [ [ ] compile-1 ] unit-test

! Test literals
[ 1 ] [ [ 1 ] compile-1 ] unit-test
[ 31 ] [ [ 31 ] compile-1 ] unit-test
[ 255 ] [ [ 255 ] compile-1 ] unit-test
[ -1 ] [ [ -1 ] compile-1 ] unit-test
[ 65536 ] [ [ 65536 ] compile-1 ] unit-test
[ -65536 ] [ [ -65536 ] compile-1 ] unit-test
[ "hey" ] [ [ "hey" ] compile-1 ] unit-test

! Calls
: no-op ;

[ ] [ [ no-op ] compile-1 ] unit-test
[ 3 ] [ [ no-op 3 ] compile-1 ] unit-test
[ 3 ] [ [ 3 no-op ] compile-1 ] unit-test

: bar 4 ;

[ 4 ] [ [ bar no-op ] compile-1 ] unit-test
[ 4 3 ] [ [ no-op bar 3 ] compile-1 ] unit-test
[ 3 4 ] [ [ 3 no-op bar ] compile-1 ] unit-test

[ ] [ no-op ] unit-test

! Conditionals

[ 1 ] [ t [ [ 1 ] [ 2 ] if ] compile-1 ] unit-test
[ 2 ] [ f [ [ 1 ] [ 2 ] if ] compile-1 ] unit-test
[ 1 3 ] [ t [ [ 1 ] [ 2 ] if 3 ] compile-1 ] unit-test
[ 2 3 ] [ f [ [ 1 ] [ 2 ] if 3 ] compile-1 ] unit-test

[ "hi" ] [ 0 [ { [ "hi" ] [ "bye" ] } dispatch ] compile-1 ] unit-test
[ "bye" ] [ 1 [ { [ "hi" ] [ "bye" ] } dispatch ] compile-1 ] unit-test

[ "hi" 3 ] [ 0 [ { [ "hi" ] [ "bye" ] } dispatch 3 ] compile-1 ] unit-test
[ "bye" 3 ] [ 1 [ { [ "hi" ] [ "bye" ] } dispatch 3 ] compile-1 ] unit-test

[ 4 1 ] [ 0 [ { [ bar 1 ] [ 3 1 ] } dispatch ] compile-1 ] unit-test
[ 3 1 ] [ 1 [ { [ bar 1 ] [ 3 1 ] } dispatch ] compile-1 ] unit-test
[ 4 1 3 ] [ 0 [ { [ bar 1 ] [ 3 1 ] } dispatch 3 ] compile-1 ] unit-test
[ 3 1 3 ] [ 1 [ { [ bar 1 ] [ 3 1 ] } dispatch 3 ] compile-1 ] unit-test

! Labels

: recursive ( ? -- ) [ f recursive ] when ; inline

[ ] [ t [ recursive ] compile-1 ] unit-test

\ recursive compile

[ ] [ t recursive ] unit-test

! Make sure error reporting works

[ [ dup ] compile-1 ] unit-test-fails
[ [ drop ] compile-1 ] unit-test-fails
