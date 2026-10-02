USING: accessors assocs game.worlds kernel locals math math.functions math.vectors math.vectors.simd
papier papier.map papier.render sequences tools.test ui.gestures ;
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

:: limited-movement ( key -- position )
    <input-world> :> world
    f key f <key-down> world handle-gesture drop
    400 [ world tick-game-world ] times
    world slabs-by-name>> "marco" swap at center>> ;

! Holding a direction stops at the ground edge, including diagonal input.
{ -2.0 } [ "UP" limited-movement third ] unit-test
{ -2.0 } [ "w" limited-movement third ] unit-test
{ 2.0 } [ "DOWN" limited-movement third ] unit-test
{ 2.0 } [ "s" limited-movement third ] unit-test

{ 9.25 0.0 -2.0 } [| |
    <input-world> { "d" "w" } >>held-keys :> world
    400 [ world tick-game-world ] times
    world slabs-by-name>> "marco" swap at center>> first3
] unit-test

! Bounds and foot height follow the ground, rather than camera position.
{ 1.0 4.0 } [| |
    <input-world> :> world
    world slabs-by-name>> "ground" swap at
        { 0.0 0.0 1.0 1.0 } >float-4 >>center
        { 10.0 3.0 2.0 1.0 } >float-4 >>size drop
    f "s" f <key-down> world handle-gesture drop
    400 [ world tick-game-world ] times
    world slabs-by-name>> "marco" swap at center>> [ second ] [ third ] bi
] unit-test

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

: draw-order ( world -- names )
    slabs>> eye order-slabs [ name>> ] map ;

{ { "backdrop" "ground" "cat" "marco" } } [
    <input-world> draw-order
] unit-test

! Crossing the cat's depth changes which character covers the other.
{ { "backdrop" "ground" "marco" "cat" }
  { "backdrop" "ground" "cat" "marco" } } [| |
    <input-world> :> world
    f "w" f <key-down> world handle-gesture drop
    3 [ world tick-game-world ] times
    world draw-order
    f "w" f <key-up> world handle-gesture drop
    f "s" f <key-down> world handle-gesture drop
    4 [ world tick-game-world ] times
    world draw-order
] unit-test

! Distance sideways does not change depth ordering.
{ { "backdrop" "ground" "cat" "marco" } } [| |
    <input-world> :> world
    f "a" f <key-down> world handle-gesture drop
    100 [ world tick-game-world ] times
    world draw-order
] unit-test
