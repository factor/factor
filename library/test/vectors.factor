USE: arithmetic
USE: lists
USE: stack
USE: test
USE: vectors

[ [ 1 4 9 16 ] ] [ [ 1 2 3 4 ] ]
[ list>vector [ dup * ] vector-map vector>list ] test-word
[ t ] [ [ 1 2 3 4 ] ]
[ list>vector [ number? ] vector-all? ] test-word
[ f ] [ [ 1 2 3 4 ] ]
[ list>vector [ 3 > ] vector-all? ] test-word
[ t ] [ [ ] ]
[ list>vector [ 3 > ] vector-all? ] test-word
