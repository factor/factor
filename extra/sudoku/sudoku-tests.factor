USING: io.streams.string sudoku tools.test ;

{ "Puzzle:
. . 1 . . 5 3 . .
. 5 . 4 9 . . . .
. . . 1 . 2 . 6 4
. . . . . . 7 5 .
6 . . . . . . . 1
. 3 5 . . . . . .
4 6 . 9 . 3 . . .
. . . . 2 4 . 9 .
. . 3 6 . . 1 . .
Solution:
2 4 1 8 6 5 3 7 9
3 5 6 4 9 7 2 1 8
8 7 9 1 3 2 5 6 4
1 9 4 3 8 6 7 5 2
6 8 2 5 7 9 4 3 1
7 3 5 2 4 1 9 8 6
4 6 7 9 1 3 8 2 5
5 1 8 7 2 4 6 9 3
9 2 3 6 5 8 1 4 7
1 solutions.
" } [
    [ sudoku-demo ] with-string-writer
] unit-test
