IN: scratchpad
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: stack
USE: test
USE: strings

[ [ [ 3 2 1 ] [ 5 4 3 ] [ 6 ] ] ]
[ [ 1 2 3 ] [ 3 4 5 ] [ 6 ] 3list [ reverse ] map ] unit-test

[ f ] [ [ "Hello" { } 4/3 ] [ string? ] all? ] unit-test
[ t ] [ [ ] [ ] all? ] unit-test
[ t ] [ [ "hi" t 1/2 ] [ ] all? ] unit-test

[ [ 1 2 3 ] ] [ [ 1 4 2 5 3 6 ] [ 4 < ] subset ] unit-test

[ [ 43 "a" [ ] ] ] [ [ "a" 43 43 43 [ ] 43 "a" [ ] ] prune ] unit-test

[ "fdsfs" num-sort ] unit-test-fails
[ [ ] ] [ [ ] num-sort ] unit-test
[ [ "2 + 2" ] ] [ [ "2 + 2" ] [ str-lexi> ] sort ] unit-test
[ [ 1 2 3 4 5 6 7 ] ] [ [ 6 4 5 7 2 1 3 ] num-sort ] unit-test

[ f ] [ [ { } { } "Hello" ] all=? ] unit-test
[ f ] [ [ { 2 } { } { } ] all=? ] unit-test
[ t ] [ [ ] all=? ] unit-test
[ t ] [ [ 1/2 ] all=? ] unit-test
[ t ] [ [ 1.0 10/10 1 ] all=? ] unit-test

[ 5 ] [ [ 5 ] [ < ] top ] unit-test
[ 5 ] [ [ 5 6 ] [ < ] top ] unit-test
[ 6 ] [ [ 5 6 ] [ > ] top ] unit-test
[ 99 ] [ 100 count [ > ] top ] unit-test
[ 0 ] [ 100 count [ < ] top ] unit-test

[ f ] [ [ ] [ ] some? ] unit-test
[ t ] [ [ 1 ] [ ] some? >boolean ] unit-test
[ t ] [ [ 1 2 3 ] [ 2 > ] some? >boolean ] unit-test
[ f ] [ [ 1 2 3 ] [ 10 > ] some? ] unit-test
