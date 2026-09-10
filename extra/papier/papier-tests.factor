USING: accessors assocs game.worlds kernel locals math math.functions math.vectors
papier papier.map sequences tools.test ui.gestures ;
IN: papier.tests

: <input-world> ( -- world )
    papier-world new t >>focused?
    load-slabs dup slabs-by-name [ >>slabs ] [ >>slabs-by-name ] bi* ;

: player-x ( world -- x )
    slabs-by-name>> "marco" swap at center>> first ;

:: held-movement ( key -- ? )
    <input-world> :> world
    world player-x :> before
    f key f <key-down> world handle-gesture drop
    world tick-game-world
    world tick-game-world
    world player-x before < ;

{ t } [ "LEFT" held-movement ] unit-test
{ t } [ "a" held-movement ] unit-test

:: released-movement ( -- ? )
    <input-world> :> world
    f "RIGHT" f <key-down> world handle-gesture drop
    world tick-game-world
    world player-x :> moved
    { S+ } "RIGHT" f <key-up> world handle-gesture drop
    world tick-game-world
    moved -3.0 > world player-x moved = and ;

{ t } [ released-movement ] unit-test

:: alias-release ( -- ? )
    <input-world> :> world
    f "LEFT" f <key-down> world handle-gesture drop
    f "A" f <key-down> world handle-gesture drop
    f "LEFT" f <key-up> world handle-gesture drop
    world tick-game-world
    world player-x -3.0 < ;

{ t } [ alias-release ] unit-test

:: focus-release ( -- ? )
    <input-world> :> world
    f "d" f <key-down> world handle-gesture drop
    lose-focus world handle-gesture drop
    world tick-game-world
    world player-x -3.0 = world held-keys>> empty? and ;

{ t } [ focus-release ] unit-test

:: separate-worlds ( -- ? )
    <input-world> :> first
    <input-world> :> second
    f "RIGHT" f <key-down> first handle-gesture drop
    first tick-game-world second tick-game-world
    first player-x -3.0 > second player-x -3.0 = and ;

{ t } [ separate-worlds ] unit-test

{ t } [
    papier-world new
    dup f "LEFT" f <key-down> swap handle-gesture drop
    dup f "LEFT" f <key-down> swap handle-gesture drop
    held-keys>> { "left" } =
] unit-test

: player-z ( world -- z )
    slabs-by-name>> "marco" swap at center>> third ;

:: depth-movement ( key -- z )
    <input-world> :> world
    f key f <key-down> world handle-gesture drop
    world tick-game-world
    world player-z ;

{ t } [ "UP" depth-movement 0.0 < ] unit-test
{ t } [ "w" depth-movement 0.0 < ] unit-test
{ t } [ "DOWN" depth-movement 0.0 > ] unit-test
{ t } [ "s" depth-movement 0.0 > ] unit-test

! Opposite directions cancel; diagonals retain the cardinal movement speed.
{ f f } [
    <input-world> { "left" "d" } >>held-keys keyboard-input
] unit-test

{ t } [
    <input-world> { "right" "w" } >>held-keys keyboard-input drop
    l2-norm move-rate 0.000001 ~
] unit-test

{ t } [
    <input-world> { "up" } >>held-keys
    dup keyboard-input nip
    swap slabs-by-name>> "marco" swap at orient>> =
] unit-test

:: brief-tap ( -- ? )
    <input-world> :> world
    f "d" f <key-down> world handle-gesture drop
    f "d" f <key-up> world handle-gesture drop
    world tick-game-world
    world player-x :> moved
    world tick-game-world
    moved -3.0 > world player-x moved = and ;

{ t } [ brief-tap ] unit-test
