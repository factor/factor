IN: temporary
USING: kernel tools.test compiler ;

TUPLE: color red green blue ;

[ T{ color f 1 2 3 } ]
[ 1 2 3 [ color construct-boa ] compile-1 ] unit-test

[ 1 3 ] [
    1 2 3 color construct-boa
    [ { color-red color-blue } get-slots ] compile-1
] unit-test

[ T{ color f 10 2 20 } ] [
    10 20
    1 2 3 color construct-boa [
        [
            { set-color-red set-color-blue } set-slots
        ] compile-1
    ] keep
] unit-test

[ T{ color f f f f } ]
[ [ color construct-empty ] compile-1 ] unit-test

[ T{ color "a" f "b" f } ] [
    "a" "b"
    [ { set-delegate set-color-green } color construct ]
    compile-1
] unit-test

[ T{ color f f f f } ] [ [ { } color construct ] compile-1 ] unit-test
