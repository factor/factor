USING: accessors kernel tetris.game tetris.board tetris.piece tools.test
sequences ;

{ t } [ <default-tetris> [ current-piece ] [ next-piece ] bi and t f ? ] unit-test
{ t } [ <default-tetris> { 1 1 } can-move? ] unit-test
{ t } [ <default-tetris> { 1 1 } tetris-move ] unit-test
{ 1 } [ <default-tetris> dup { 1 1 } tetris-move drop current-piece location>> second ] unit-test
{ 1 } [ <default-tetris> level ] unit-test
{ 1 } [ <default-tetris> 9 >>rows level ] unit-test
{ 2 } [ <default-tetris> 10 >>rows level ] unit-test
{ 0 } [ 3 0 rows-score ] unit-test
{ 80 } [ 1 1 rows-score ] unit-test
{ 4800 } [ 3 4 rows-score ] unit-test
{ 1 } [ <default-tetris> dup 3 score-rows dup 3 score-rows dup 3 score-rows level ] unit-test
{ 2 } [ <default-tetris> dup 4 score-rows dup 4 score-rows dup 2 score-rows level ] unit-test
