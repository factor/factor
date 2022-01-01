USING: accessors arrays colors kernel tetris.board tetris.piece tools.test ;

{ { { f f } { f f } { f f } } } [ 2 3 make-rows ] unit-test
{ { { f f } { f f } { f f } } } [ 2 3 <board> rows>> ] unit-test
{ 1 { f f } } [ 2 3 <board> { 1 1 } board@block ] unit-test
{ f } [ 2 3 <board> { 1 1 } block ] unit-test
[ 2 3 <board> { 2 3 } block ] must-fail
{ COLOR: red } [ 2 3 <board> dup { 1 1 } COLOR: red set-block { 1 1 } block ] unit-test
{ t } [ 2 3 <board> { 1 1 } block-free? ] unit-test
{ f } [ 2 3 <board> dup { 1 1 } COLOR: red set-block { 1 1 } block-free? ] unit-test
{ t } [ 2 3 <board> dup { 1 1 } COLOR: red set-block { 1 2 } block-free? ] unit-test
{ t } [ 2 3 <board> dup { 1 1 } COLOR: red set-block { 0 1 } block-free? ] unit-test
{ t } [ 2 3 <board> { 0 0 } block-in-bounds? ] unit-test
{ f } [ 2 3 <board> { -1 0 } block-in-bounds? ] unit-test
{ t } [ 2 3 <board> { 1 2 } block-in-bounds? ] unit-test
{ f } [ 2 3 <board> { 2 2 } block-in-bounds? ] unit-test
{ t } [ 2 3 <board> { 1 1 } location-valid? ] unit-test
{ f } [ 2 3 <board> dup { 1 1 } COLOR: red set-block { 1 1 } location-valid? ] unit-test
{ t } [ 10 10 <board> 10 <random-piece> piece-valid? ] unit-test
{ f } [ 2 3 <board> 10 <random-piece> { 1 2 } >>location piece-valid? ] unit-test
{ { { f } { f } } } [ 1 1 <board> add-row rows>> ] unit-test
{ { { f } } } [ 1 2 <board> dup { 0 1 } COLOR: red set-block remove-full-rows rows>> ] unit-test
{ { { f } { f } } } [ 1 2 <board> dup { 0 1 } COLOR: red set-block dup check-rows drop rows>> ] unit-test
