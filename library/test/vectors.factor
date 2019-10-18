USE: arithmetic
USE: lists
USE: stdio
USE: test
USE: vectors

"Vector tests." print

[ [ 1 4 9 16 ] ] [ [ 1 2 3 4 ] ]
[ list>vector [ sq ] vector-map vector>list ] test-word
[ t ] [ [ 1 2 3 4 ] ]
[ list>vector [ number? ] vector-all? ] test-word
[ f ] [ [ 1 2 3 4 ] ]
[ list>vector [ 3 > ] vector-all? ] test-word
[ t ] [ [ ] ]
[ list>vector [ 3 > ] vector-all? ] test-word
