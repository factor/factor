USE: arithmetic
USE: lists
USE: kernel
USE: random
USE: stack
USE: test
USE: vectors

[ { } ] [ [ ] list>vector ] unit-test
[ { 1 2 } ] [ [ 1 2 ] list>vector ] unit-test

[ t ] [
    100 empty-vector [ drop 0 100 random-int ] vector-map
    dup vector>list list>vector =
] unit-test

[ f ] [ { } { 1 2 3 } = ] unit-test
[ f ] [ { 1 2 } { 1 2 3 } = ] unit-test
[ f ] [ [ 1 2 ] { 1 2 3 } = ] unit-test
[ f ] [ { 1 2 } [ 1 2 3 ] = ] unit-test

[ [ 1 4 9 16 ] ] [ [ 1 2 3 4 ] ]
[ list>vector [ dup * ] vector-map vector>list ] test-word
[ t ] [ [ 1 2 3 4 ] ]
[ list>vector [ number? ] vector-all? ] test-word
[ f ] [ [ 1 2 3 4 ] ]
[ list>vector [ 3 > ] vector-all? ] test-word
[ t ] [ [ ] ]
[ list>vector [ 3 > ] vector-all? ] test-word
