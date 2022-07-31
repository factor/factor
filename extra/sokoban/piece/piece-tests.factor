USING: accessors kernel sokoban.tetromino sokoban.piece tools.test sequences arrays namespaces ;

! Tests for sokoban.tetromino and sokoban.piece, since there's not much to test in sokoban.tetromino

! these two tests rely on the first level_num of the first tetromino being the
! 'I' tetromino in its vertical orientation.
{ 4 } [ tetrominoes get first states>> first blocks-width ] unit-test
{ 1 } [ tetrominoes get first states>> first blocks-height ] unit-test

! { { 0 0 } } [ random-tetromino <piece> location>> ] unit-test
! { 0 } [ 10 <random-piece> level_num>> ] unit-test

{ { { 0 0 } { 1 0 } { 2 0 } { 3 0 } } }
[ tetrominoes get first <piece> piece-blocks ] unit-test

{ { { 0 0 } { 0 1 } { 0 2 } { 0 3 } } }
[ tetrominoes get first <piece> 1 rotate-piece piece-blocks ] unit-test

{ { { 1 1 } { 2 1 } { 3 1 } { 4 1 } } }
[ tetrominoes get first <piece> { 1 1 } move-piece piece-blocks ] unit-test

{ 3 } [ tetrominoes get second <piece> piece-width ] unit-test
{ 2 } [ tetrominoes get second <piece> 1 rotate-piece piece-width ] unit-test
