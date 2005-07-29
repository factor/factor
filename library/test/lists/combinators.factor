IN: temporary
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: test
USE: strings
USE: sequences

[ { [ 3 2 1 ] [ 5 4 3 ] [ 6 ] } ]

[ [ "a" 43 [ ] ] ] [ [ "a" 43 43 43 [ ] 43 "a" [ ] ] prune ] unit-test

[ "fdsfs" [ > ] sort ] unit-test-fails
[ [ ] ] [ [ ] [ > ] sort ] unit-test
[ [ "2 + 2" ] ] [ [ "2 + 2" ] [ lexi> ] sort ] unit-test
[ [ 1 2 3 4 5 6 7 ] ] [ [ 6 4 5 7 2 1 3 ] [ > ] sort ] unit-test

[ f ] [ [ { } { } "Hello" ] [ = ] every? ] unit-test
[ f ] [ [ { 2 } { } { } ] [ = ] every? ] unit-test
[ t ] [ [ ] [ = ] every? ] unit-test
[ t ] [ [ 1/2 ] [ = ] every? ] unit-test
[ t ] [ [ 1.0 10/10 1 ] [ = ] every? ] unit-test

[ [ 2 3 4 ] ] [ 1 [ 1 2 3 ] [ + ] map-with ] unit-test
