USING: refs tools.test kernel ;

[ 3 ] [
    H{ { "a" 3 } } "a" <value-ref> get-ref
] unit-test

[ 4 ] [
    4 H{ { "a" 3 } } clone "a" <value-ref>
    [ set-ref ] keep
    get-ref
] unit-test

[ "a" ] [
    H{ { "a" 3 } } "a" <key-ref> get-ref
] unit-test

[ H{ { "b" 3 } } ] [
    "b" H{ { "a" 3 } } clone [
        "a" <key-ref>
        set-ref
    ] keep
] unit-test
