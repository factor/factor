IN: fry.tests
USING: fry tools.test math prettyprint kernel io arrays
sequences ;

[ [ 3 + ] ] [ 3 '[ , + ] ] unit-test

[ [ 1 3 + ] ] [ 1 3 '[ , , + ] ] unit-test

[ [ 1 + ] ] [ 1 [ + ] '[ , @ ] ] unit-test

[ [ 1 + . ] ] [ 1 [ + ] '[ , @ . ] ] unit-test

[ [ + - ] ] [ [ + ] [ - ] '[ @ @ ] ] unit-test

[ [ "a" write "b" print ] ]
[ "a" "b" '[ , write , print ] ] unit-test

[ [ 1 2 + 3 4 - ] ]
[ [ + ] [ - ] '[ 1 2 @ 3 4 @ ] ] unit-test

[ 1/2 ] [
    1 '[ , _ / ] 2 swap call
] unit-test

[ { { 1 "a" "A" } { 1 "b" "B" } { 1 "c" "C" } } ] [
    1 '[ , _ _ 3array ]
    { "a" "b" "c" } { "A" "B" "C" } rot 2map
] unit-test

[ { { 1 "a" } { 1 "b" } { 1 "c" } } ] [
    '[ 1 _ 2array ]
    { "a" "b" "c" } swap map
] unit-test

[ 1 2 ] [
    1 2 '[ _ , ] call
] unit-test

[ { { 1 "a" 2 } { 1 "b" 2 } { 1 "c" 2 } } ] [
    1 2 '[ , _ , 3array ]
    { "a" "b" "c" } swap map
] unit-test

: funny-dip '[ @ _ ] call ; inline

[ "hi" 3 ] [ "h" "i" 3 [ append ] funny-dip ] unit-test

[ { 1 2 3 } ] [
    3 1 '[ , [ , + ] map ] call
] unit-test

[ { 1 { 2 { 3 } } } ] [
    1 2 3 '[ , [ , [ , 1array ] call 2array ] call 2array ] call
] unit-test
