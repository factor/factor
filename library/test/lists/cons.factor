IN: scratchpad
USE: lists
USE: test

[ 5 car ] unit-test-fails
[ "Hello world" cdr ] unit-test-fails

[ f ] [ f         cons? ] unit-test
[ f ] [ t         cons? ] unit-test
[ t ] [ [ t | f ] cons? ] unit-test

[ [ 1 | 2 ] ] [ 1 2 cons ] unit-test
[ [ 1 ]     ] [ 1 f cons ] unit-test

[ [ 1 | 2 ] ] [ 2 1 swons ] unit-test
[ [ 1 ]     ] [ f 1 swons ] unit-test

[ [ [ [ ] ] ] ] [ [ ] unit unit ] unit-test

[ 1 ] [ [ 1 | 2 ] car ] unit-test
[ 2 ] [ [ 1 | 2 ] cdr ] unit-test

[ 1 2     ] [ [ 1 | 2 ] uncons ] unit-test
[ 1 [ 2 ] ] [ [ 1 2 ]   uncons ] unit-test

[ 1 2     ] [ [ 2 | 1 ] unswons ] unit-test
[ [ 2 ] 1 ] [ [ 1 2 ]   unswons ] unit-test

[ [ 1 2 ]   ] [ 1 2   2list  ] unit-test
[ [ 1 2 3 ] ] [ 1 2 3 3list  ] unit-test

[ 1 3 ] [ [ 1 | 2 ] [ 3 | 4 ] 2car ] unit-test
[ 2 4 ] [ [ 1 | 2 ] [ 3 | 4 ] 2cdr ] unit-test
[ 1 3 2 4 ] [ [ 1 | 2 ] [ 3 | 4 ] 2uncons ] unit-test
