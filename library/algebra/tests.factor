USING: algebra test math kernel ;

[ [ - [ + x [ mod [ * 2 pi ] 4 ] ] ] ] [
    ([ - x + [ 2 * pi ] mod 4 ])
] unit-test
[ 13/3 ] [
    1 2 3 [ x y z ]  ([ [ sq y ] + x / z ]) eval-infix call
] unit-test
[ [ + x 1/2 ] ] [ ([ x + 3 / 6 ]) fold-consts ] unit-test
[ 1 ] [ 5 3 [ x ] ([ sq x + 6 ]) install-mod eval-infix call ] unit-test
[ 1.0 -1.0 ] [ 1 0 -1 quadratic-formula ] unit-test
