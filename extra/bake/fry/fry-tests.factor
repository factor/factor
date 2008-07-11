
USING: tools.test math prettyprint kernel io arrays vectors sequences
       generalizations bake bake.fry ;

IN: bake.fry.tests

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: unit-test* ( input output -- ) swap unit-test ;

: must-be-t ( in -- ) [ t ] swap unit-test ;
: must-be-f ( in -- ) [ f ] swap unit-test ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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

{ 1 1 } [ '[ [ [ , ] ] ] ] must-infer-as

[ { { { 3 } } } ] [
    3 '[ [ [ , 1array ] call 1array ] call 1array ] call
] unit-test

[ { { { 3 } } } ] [
    3 '[ [ [ , 1array ] call 1array ] call 1array ] call
] unit-test

! [ 10 20 30 40 '[ , V{ , { , } } , ] ] [ [ 10 V{ 20 { 30 } } 40 ] ] unit-test*

[ 10 20 30 40 '[ , V{ , { , } } , ] ]
[ [ 10 20 30 >r r> 1 narray >r >r r> r> 2 narray >vector 40 ] ]
unit-test*

[ { 1 2 3 } { 4 5 6 } { 7 8 9 } '[ , { V{ @ } { , } } ] call ]
[
  { 1 2 3 }
  { V{ 4 5 6 } { { 7 8 9 } } }
]
unit-test*

