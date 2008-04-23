IN: compiler.tests
USING: kernel tools.test compiler.units ;

TUPLE: color red green blue ;

[ T{ color f 1 2 3 } ]
[ 1 2 3 [ color boa ] compile-call ] unit-test

[ 1 3 ] [
    1 2 3 color boa
    [ { color-red color-blue } get-slots ] compile-call
] unit-test

[ T{ color f 10 2 20 } ] [
    10 20
    1 2 3 color boa [
        [
            { set-color-red set-color-blue } set-slots
        ] compile-call
    ] keep
] unit-test

[ T{ color f f f f } ]
[ [ color new ] compile-call ] unit-test
