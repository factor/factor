USING: kernel tetris.board tetris.piece tools.test arrays
colors ;

[ { { f f } { f f } { f f } } ] [ 2 3 make-rows ] unit-test
[ { { f f } { f f } { f f } } ] [ 2 3 <board> board-rows ] unit-test
[ 1 { f f } ] [ 2 3 <board> { 1 1 } board@block ] unit-test
[ f ] [ 2 3 <board> { 1 1 } board-block ] unit-test
[ 2 3 <board> { 2 3 } board-block ] unit-test-fails
red 1array [ 2 3 <board> dup { 1 1 } red board-set-block { 1 1 } board-block ] unit-test
[ t ] [ 2 3 <board> { 1 1 } block-free? ] unit-test
[ f ] [ 2 3 <board> dup { 1 1 } red board-set-block { 1 1 } block-free? ] unit-test
[ t ] [ 2 3 <board> dup { 1 1 } red board-set-block { 1 2 } block-free? ] unit-test
[ t ] [ 2 3 <board> dup { 1 1 } red board-set-block { 0 1 } block-free? ] unit-test
[ t ] [ 2 3 <board> { 0 0 } block-in-bounds? ] unit-test
[ f ] [ 2 3 <board> { -1 0 } block-in-bounds? ] unit-test
[ t ] [ 2 3 <board> { 1 2 } block-in-bounds? ] unit-test
[ f ] [ 2 3 <board> { 2 2 } block-in-bounds? ] unit-test
[ t ] [ 2 3 <board> { 1 1 } location-valid? ] unit-test
[ f ] [ 2 3 <board> dup { 1 1 } red board-set-block { 1 1 } location-valid? ] unit-test
[ t ] [ 10 10 <board> 10 <random-piece> piece-valid? ] unit-test
[ f ] [ 2 3 <board> 10 <random-piece> { 1 2 } over set-piece-location piece-valid? ] unit-test
[ { { f } { f } } ] [ 1 1 <board> dup add-row board-rows ] unit-test
[ { { f } } ] [ 1 2 <board> dup { 0 1 } red board-set-block dup remove-full-rows board-rows ] unit-test
[ { { f } { f } } ] [ 1 2 <board> dup { 0 1 } red board-set-block dup check-rows drop board-rows ] unit-test
