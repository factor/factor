USE: lists
USE: kernel
USE: math
USE: random
USE: test
USE: vectors
USE: strings

[ 3 { } vector-nth ] unit-test-fails
[ 3 #{ 1 2 } vector-nth ] unit-test-fails

[ 5 list>vector ] unit-test-fails
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

[ t ] [ { } hashcode { } hashcode = ] unit-test
[ t ] [ { 1 2 3 } hashcode { 1 2 3 } hashcode = ] unit-test
[ t ] [ { 1 { 2 } 3 } hashcode { 1 { 2 } 3 } hashcode = ] unit-test
[ t ] [ { } hashcode { } hashcode = ] unit-test

[ { 1 2 3 4 5 6 } ]
[ { 1 2 3 } vector-clone dup { 4 5 6 } vector-append ] unit-test

[ { "" "a" "aa" "aaa" } ]
[ 4 [ CHAR: a fill ] vector-project ]
unit-test

[ { 6 8 10 12 } ]
[ { 1 2 3 4 } { 5 6 7 8 } [ + ] vector-2map ]
unit-test

[ { [ 1 | 5 ] [ 2 | 6 ] [ 3 | 7 ] [ 4 | 8 ] } ]
[ { 1 2 3 4 } { 5 6 7 8 } vector-zip ]
unit-test

[ [ ] ] [ 0 { } vector-tail ] unit-test
[ [ ] ] [ 2 { 1 2 } vector-tail ] unit-test
[ [ 3 4 ] ] [ 2 { 1 2 3 4 } vector-tail ] unit-test
[ 2 [ ] vector-tail ] unit-test-fails

[ [ 3 ] ] [ 1 { 1 2 3 } vector-tail* ] unit-test
