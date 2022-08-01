USING: accessors kernel sokoban.game sokoban.board sokoban.piece tools.test
sequences ;

! { t } [ <default-sokoban> [ current-piece ] [ next-piece ] bi and t f ? ] unit-test
! { t } [ <default-sokoban> { 1 1 } can-move? ] unit-test
{ t } [ <default-sokoban> { 1 1 } sokoban-move ] unit-test
! { 1 } [ <default-sokoban> dup { 1 1 } sokoban-move drop current-piece location>> second ] unit-test
{ 0 } [ <default-sokoban> level>> ] unit-test
! { 1 } [ <default-sokoban> 9 >>rows level>> ] unit-test
! { 2 } [ <default-sokoban> 10 >>rows level>> ] unit-test
! { 0 } [ 3 0 rows-score ] unit-test
! { 80 } [ 1 1 rows-score ] unit-test
! { 4800 } [ 3 4 rows-score ] unit-test
! { 1 } [ <default-sokoban> dup 3 score-rows dup 3 score-rows dup 3 score-rows level ] unit-test
! { 2 } [ <default-sokoban> dup 4 score-rows dup 4 score-rows dup 2 score-rows level ] unit-test
