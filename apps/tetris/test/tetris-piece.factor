USING: kernel tetromino tetris-piece test sequences arrays namespaces ;

! Tests for tetromino and tetris-piece, since there's not much to test in tetromino

! these two tests rely on the first rotation of the first tetromino being the
! 'I' tetromino in its vertical orientation.
[ 4 ] [ tetrominoes get first tetromino-states first blocks-width ] unit-test
[ 1 ] [ tetrominoes get first tetromino-states first blocks-height ] unit-test

[ { 0 0 } ] [ random-tetromino <piece> piece-location ] unit-test
[ 0 ] [ 10 <random-piece> piece-rotation ] unit-test

[ { { 0 0 } { 1 0 } { 2 0 } { 3 0 } } ]
[ tetrominoes get first <piece> piece-blocks ] unit-test

[ { { 0 0 } { 0 1 } { 0 2 } { 0 3 } } ]
[ tetrominoes get first <piece> dup 1 rotate-piece piece-blocks ] unit-test

[ { { 1 1 } { 2 1 } { 3 1 } { 4 1 } } ]
[ tetrominoes get first <piece> dup { 1 1 } move-piece piece-blocks ] unit-test

[ 3 ] [ tetrominoes get second <piece> piece-width ] unit-test
[ 2 ] [ tetrominoes get second <piece> dup 1 rotate-piece piece-width ] unit-test
