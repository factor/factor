IN: scratchpad
USE: compiler
USE: test
USE: inference
USE: lists

[ [ ] ] [ [ ] simplify ] unit-test
[ [ [ #return ] ] ] [ [ [ #return ] ] simplify ] unit-test
[ [ #jump | car ] ] [ [ [ #call | car ] [ #return ] ] simplify car ] unit-test

[ [ [ #return ] ] ]
[ 123 [ [ #call | car ] [ #label | 123 ] [ #return ] ] find-label ]
unit-test

[ [ [ #return ] ] ]
[ [ [ #label | 123 ] [ #return ] ] follow ]
unit-test

[ [ [ #return ] ] ]
[
    [
        [ #jump-label | 123 ]
        [ #call | car ]
        [ #label | 123 ]
        [ #return ]
    ] follow
]
unit-test

[
    [ #jump | car ]
]
[
    [
        [ #call | car ]
        [ #jump-label | 123 ]
        [ #label | 123 ]
        [ #return ]
    ] simplify car
] unit-test
