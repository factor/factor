USING: game_lib_test game_lib.board tools.test ;

! testing win function
{ f } [ 3 3 f make-board check-win ] unit-test
{ t } [ 3 3 f make-board { { 0 0 } { 1 0 } { 2 0 } } "vocab:game_lib_test/resources/O.png" set-multicell check-win ] unit-test
{ t } [ 3 3 f make-board { { 0 0 } { 0 1 } { 0 2 } } "vocab:game_lib_test/resources/X.png" set-multicell check-win ] unit-test
{ t } [ 3 3 f make-board { { 0 0 } { 1 1 } { 2 2 } } "vocab:game_lib_test/resources/X.png" set-multicell check-win ] unit-test
{ f } [ 3 3 f make-board { { 0 0 } { 1 0 } { 2 2 } } "vocab:game_lib_test/resources/O.png" set-multicell check-win ] unit-test
{ t } [ 3 3 f make-board { { 2 0 } { 1 1 } { 0 2 } } "vocab:game_lib_test/resources/O.png" set-multicell check-win ] unit-test

