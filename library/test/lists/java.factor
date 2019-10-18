USE: compiler
USE: lists
USE: math
USE: stack
USE: strings
USE: test

[ [ 2 1 0 0 ] ] [ [ 2list ] ] [ balance>list ] test-word
[ [ 3 1 0 0 ] ] [ [ 3list ] ] [ balance>list ] test-word
[ [ 2 1 0 0 ] ] [ [ append ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ array>list ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ car ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ cdr ] ] [ balance>list ] test-word
[ [ 2 1 0 0 ] ] [ [ cons ] ] [ balance>list ] test-word
[ [ 2 1 0 0 ] ] [ [ contains? ] ] [ balance>list ] test-word
[ [ 2 0 0 0 ] ] [ [ cons@ ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ count ] ] [ balance>list ] do-not-test-word
[ [ 2 1 0 0 ] ] [ [ nth ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ last* ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ last ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ length ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ list? ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ cons? ] ] [ balance>list ] test-word
[ [ 2 1 0 0 ] ] [ [ remove ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ reverse ] ] [ balance>list ] test-word
[ [ 2 2 0 0 ] ] [ [ [ < ] partition ] ] [ balance>list ] test-word
[ [ 2 2 0 0 ] ] [ [ [ nip string? ] partition ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ num-sort ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ str-sort ] ] [ balance>list ] test-word
[ [ 2 1 0 0 ] ] [ [ swons ] ] [ balance>list ] test-word
[ [ 2 1 0 0 ] ] [ [ tree-contains?   ] ] [ balance>list ] test-word
[ [ 1 2 0 0 ] ] [ [ uncons ] ] [ balance>list ] test-word
[ [ 2 1 0 0 ] ] [ [ unique ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ unit ] ] [ balance>list ] test-word
[ [ 1 2 0 0 ] ] [ [ unswons ] ] [ balance>list ] test-word

[ [ ]       ] [ [ ]       ] [ array>list ] test-word
[ [ 1 2 3 ] ] [ [ 1 2 3 ] ] [ array>list ] test-word

