IN: scratchpad
USE: lists
USE: test

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

[ [ "car1" | "cdr1" ] [ "car2" | "cdr2" ] ]
[ "car1" "car2" "cdr1" "cdr2" 2cons ]
unit-test

[ [ "car1" | "cdr1" ] [ "car2" | "cdr2" ] ]
[ "cdr1" "cdr2" "car1" "car2" 2swons ]
unit-test
