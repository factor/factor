USING: accessors kernel pg.game pg.board pg.piece tools.test
sequences ;
FROM: pg.game => level>> ;

{ t } [ <default-pg> [ current-piece ] [ next-piece ] bi and t f ? ] unit-test
{ t } [ <default-pg> { 1 1 } can-move? ] unit-test
{ t } [ <default-pg> { 1 1 } pg-move ] unit-test
{ 1 } [ <default-pg> dup { 1 1 } pg-move drop current-piece location>> second ] unit-test
{ 1 } [ <default-pg> level>> ] unit-test
{ 1 } [ <default-pg> 9 >>rows level>> ] unit-test
{ 2 } [ <default-pg> 10 >>rows level>> ] unit-test
{ 0 } [ 3 0 rows-score ] unit-test
{ 80 } [ 1 1 rows-score ] unit-test
{ 4800 } [ 3 4 rows-score ] unit-test
{ 1 } [ <default-pg> dup 3 score-rows dup 3 score-rows dup 3 score-rows level>> ] unit-test
{ 2 } [ <default-pg> dup 4 score-rows dup 4 score-rows dup 2 score-rows level>> ] unit-test
