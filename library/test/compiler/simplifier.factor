IN: scratchpad
USE: compiler
USE: test
USE: inference
USE: lists
USE: kernel
USE: namespaces

[ t ] [ \ >r [ [ r> ] [ >r ] ] next-physical? ] unit-test
[ f t ] [ [ [ r> ] [ >r ] ] \ >r cancel nip ] unit-test
[ [ [ >r ] [ r> ] ] f ] [ [ [ >r ] [ r> ] ] \ >r cancel nip ] unit-test

[ [ [ #jump 123 ] [ #return ] ] t ]
[ [ [ #call 123 ] [ #return ] ] #return #jump reduce ] unit-test

[ [ ] ] [ [ ] simplify ] unit-test
[ [ [ #return ] ] ] [ [ [ #return ] ] simplify ] unit-test
[ [[ #jump car ]] ] [ [ [[ #call car ]] [ #return ] ] simplify car ] unit-test

[ [ [ #return ] ] ]
[
    [
        123 [ [[ #call car ]] [[ #label 123 ]] [ #return ] ]
        simplifying set find-label cdr
    ] with-scope
]
unit-test

[ [ [ #return ] ] ]
[
    [
        [
            [[ #jump-label 123 ]]
            [[ #call car ]]
            [[ #label 123 ]]
            [ #return ]
        ] dup simplifying set next-logical
    ] with-scope
]
unit-test

[
    [ [[ #return f ]] ]
]
[
    [
        [[ #jump-label 123 ]]
        [[ #label 123 ]]
        [ #return ]
    ] simplify
] unit-test

[
    [ [[ #jump car ]] ]
]
[
    [
        [[ #call car ]]
        [[ #jump-label 123 ]]
        [[ #label 123 ]]
        [ #return ]
    ] simplify
] unit-test

[
    [ [[ swap f ]] ]
] [
    [
        [[ #jump-label 1 ]]
        [[ #label 1 ]]
        [[ #jump-label 2 ]]
        [[ #label 2 ]]
        [[ swap f ]]
    ] simplify
] unit-test
