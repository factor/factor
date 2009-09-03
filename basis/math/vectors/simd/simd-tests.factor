IN: math.vectors.simd.tests
USING: math math.vectors.simd math.vectors.simd.private
math.vectors math.functions kernel.private compiler sequences
tools.test compiler.tree.debugger accessors kernel ;

[ 4float-array{ 0 0 0 0 } ] [ 4float-array new ] unit-test

[ V{ float } ] [ [ { 4float-array } declare norm-sq ] final-classes ] unit-test

[ V{ float } ] [ [ { 4float-array } declare norm ] final-classes ] unit-test

[ 4float-array{ 12 12 12 12 } ] [
    12 [ 4float-array-with ] compile-call
] unit-test

[ 4float-array{ 1 2 3 4 } ] [
    1 2 3 4 [ 4float-array-boa ] compile-call
] unit-test

[ 4float-array{ 11 22 33 44 } ] [
    4float-array{ 1 2 3 4 } 4float-array{ 10 20 30 40 }
    [ { 4float-array 4float-array } declare v+ ] compile-call
] unit-test

[ 4float-array{ -9 -18 -27 -36 } ] [
    4float-array{ 1 2 3 4 } 4float-array{ 10 20 30 40 }
    [ { 4float-array 4float-array } declare v- ] compile-call
] unit-test

[ 4float-array{ 10 40 90 160 } ] [
    4float-array{ 1 2 3 4 } 4float-array{ 10 20 30 40 }
    [ { 4float-array 4float-array } declare v* ] compile-call
] unit-test

[ 4float-array{ 10 100 1000 10000 } ] [
    4float-array{ 100 2000 30000 400000 } 4float-array{ 10 20 30 40 }
    [ { 4float-array 4float-array } declare v/ ] compile-call
] unit-test

[ 4float-array{ -10 -20 -30 -40 } ] [
    4float-array{ -10 20 -30 40 } 4float-array{ 10 -20 30 -40 }
    [ { 4float-array 4float-array } declare vmin ] compile-call
] unit-test

[ 4float-array{ 10 20 30 40 } ] [
    4float-array{ -10 20 -30 40 } 4float-array{ 10 -20 30 -40 }
    [ { 4float-array 4float-array } declare vmax ] compile-call
] unit-test

[ 10.0 ] [
    4float-array{ 1 2 3 4 }
    [ { 4float-array } declare sum ] compile-call
] unit-test

[ 13.0 ] [
    4float-array{ 1 2 3 4 }
    [ { 4float-array } declare sum 3.0 + ] compile-call
] unit-test

[ 8.0 ] [
    4float-array{ 1 2 3 4 } 4float-array{ 2 0 2 0 }
    [ { 4float-array 4float-array } declare v. ] compile-call
] unit-test

[ 4float-array{ 5 10 15 20 } ] [
    5.0 4float-array{ 1 2 3 4 }
    [ { float 4float-array } declare n*v ] compile-call
] unit-test

[ 4float-array{ 5 10 15 20 } ] [
    4float-array{ 1 2 3 4 } 5.0
    [ { float 4float-array } declare v*n ] compile-call
] unit-test

[ 4float-array{ 10 5 2 5 } ] [
    10.0 4float-array{ 1 2 5 2 }
    [ { float 4float-array } declare n/v ] compile-call
] unit-test

[ 4float-array{ 0.5 1 1.5 2 } ] [
    4float-array{ 1 2 3 4 } 2
    [ { float 4float-array } declare v/n ] compile-call
] unit-test

[ 4float-array{ 1 0 0 0 } ] [
    4float-array{ 10 0 0 0 }
    [ { 4float-array } declare normalize ] compile-call
] unit-test

[ 30.0 ] [
    4float-array{ 1 2 3 4 }
    [ { 4float-array } declare norm-sq ] compile-call
] unit-test

[ t ] [
    4float-array{ 1 0 0 0 }
    4float-array{ 0 1 0 0 }
    [ { 4float-array 4float-array } declare distance ] compile-call
    2 sqrt 1.0e-6 ~
] unit-test

[ 2double-array{ 12 12 } ] [
    12 [ 2double-array-with ] compile-call
] unit-test

[ 2double-array{ 1 2 } ] [
    1 2 [ 2double-array-boa ] compile-call
] unit-test

[ 2double-array{ 11 22 } ] [
    2double-array{ 1 2 } 2double-array{ 10 20 }
    [ { 2double-array 2double-array } declare v+ ] compile-call
] unit-test

[ 2double-array{ -9 -18 } ] [
    2double-array{ 1 2 } 2double-array{ 10 20 }
    [ { 2double-array 2double-array } declare v- ] compile-call
] unit-test

[ 2double-array{ 10 40 } ] [
    2double-array{ 1 2 } 2double-array{ 10 20 }
    [ { 2double-array 2double-array } declare v* ] compile-call
] unit-test

[ 2double-array{ 10 100 } ] [
    2double-array{ 100 2000 } 2double-array{ 10 20 }
    [ { 2double-array 2double-array } declare v/ ] compile-call
] unit-test

[ 2double-array{ -10 -20 } ] [
    2double-array{ -10 20 } 2double-array{ 10 -20 }
    [ { 2double-array 2double-array } declare vmin ] compile-call
] unit-test

[ 2double-array{ 10 20 } ] [
    2double-array{ -10 20 } 2double-array{ 10 -20 }
    [ { 2double-array 2double-array } declare vmax ] compile-call
] unit-test

[ 3.0 ] [
    2double-array{ 1 2 }
    [ { 2double-array } declare sum ] compile-call
] unit-test

[ 7.0 ] [
    2double-array{ 1 2 }
    [ { 2double-array } declare sum 4.0 + ] compile-call
] unit-test

[ 16.0 ] [
    2double-array{ 1 2 } 2double-array{ 2 7 }
    [ { 2double-array 2double-array } declare v. ] compile-call
] unit-test

[ 2double-array{ 5 10 } ] [
    5.0 2double-array{ 1 2 }
    [ { float 2double-array } declare n*v ] compile-call
] unit-test

[ 2double-array{ 5 10 } ] [
    2double-array{ 1 2 } 5.0
    [ { float 2double-array } declare v*n ] compile-call
] unit-test

[ 2double-array{ 10 5 } ] [
    10.0 2double-array{ 1 2 }
    [ { float 2double-array } declare n/v ] compile-call
] unit-test

[ 2double-array{ 0.5 1 } ] [
    2double-array{ 1 2 } 2
    [ { float 2double-array } declare v/n ] compile-call
] unit-test

[ 2double-array{ 0 0 } ] [ 2double-array new ] unit-test

[ 2double-array{ 1 0 } ] [
    2double-array{ 10 0 }
    [ { 2double-array } declare normalize ] compile-call
] unit-test

[ 5.0 ] [
    2double-array{ 1 2 }
    [ { 2double-array } declare norm-sq ] compile-call
] unit-test

[ t ] [
    2double-array{ 1 0 }
    2double-array{ 0 1 }
    [ { 2double-array 2double-array } declare distance ] compile-call
    2 sqrt 1.0e-6 ~
] unit-test

[ 4double-array{ 0 0 0 0 } ] [ 4double-array new ] unit-test

[ 4double-array{ 1 2 3 4 } ] [
    1 2 3 4 4double-array-boa
] unit-test

[ 4double-array{ 1 1 1 1 } ] [
    1 4double-array-with
] unit-test

[ 4double-array{ 0 1 2 3 } ] [
    1 4double-array-with [ * ] map-index
] unit-test

[ V{ float } ] [ [ { 4double-array } declare norm-sq ] final-classes ] unit-test

[ V{ float } ] [ [ { 4double-array } declare norm ] final-classes ] unit-test

[ 4double-array{ 12 12 12 12 } ] [
    12 [ 4double-array-with ] compile-call
] unit-test

[ 4double-array{ 1 2 3 4 } ] [
    1 2 3 4 [ 4double-array-boa ] compile-call
] unit-test

[ 4double-array{ 11 22 33 44 } ] [
    4double-array{ 1 2 3 4 } 4double-array{ 10 20 30 40 }
    [ { 4double-array 4double-array } declare v+ ] compile-call
] unit-test

[ 4double-array{ -9 -18 -27 -36 } ] [
    4double-array{ 1 2 3 4 } 4double-array{ 10 20 30 40 }
    [ { 4double-array 4double-array } declare v- ] compile-call
] unit-test

[ 4double-array{ 10 40 90 160 } ] [
    4double-array{ 1 2 3 4 } 4double-array{ 10 20 30 40 }
    [ { 4double-array 4double-array } declare v* ] compile-call
] unit-test

[ 4double-array{ 10 100 1000 10000 } ] [
    4double-array{ 100 2000 30000 400000 } 4double-array{ 10 20 30 40 }
    [ { 4double-array 4double-array } declare v/ ] compile-call
] unit-test

[ 4double-array{ -10 -20 -30 -40 } ] [
    4double-array{ -10 20 -30 40 } 4double-array{ 10 -20 30 -40 }
    [ { 4double-array 4double-array } declare vmin ] compile-call
] unit-test

[ 4double-array{ 10 20 30 40 } ] [
    4double-array{ -10 20 -30 40 } 4double-array{ 10 -20 30 -40 }
    [ { 4double-array 4double-array } declare vmax ] compile-call
] unit-test

[ 10.0 ] [
    4double-array{ 1 2 3 4 }
    [ { 4double-array } declare sum ] compile-call
] unit-test

[ 13.0 ] [
    4double-array{ 1 2 3 4 }
    [ { 4double-array } declare sum 3.0 + ] compile-call
] unit-test

[ 8.0 ] [
    4double-array{ 1 2 3 4 } 4double-array{ 2 0 2 0 }
    [ { 4double-array 4double-array } declare v. ] compile-call
] unit-test

[ 4double-array{ 5 10 15 20 } ] [
    5.0 4double-array{ 1 2 3 4 }
    [ { float 4double-array } declare n*v ] compile-call
] unit-test

[ 4double-array{ 5 10 15 20 } ] [
    4double-array{ 1 2 3 4 } 5.0
    [ { float 4double-array } declare v*n ] compile-call
] unit-test

[ 4double-array{ 10 5 2 5 } ] [
    10.0 4double-array{ 1 2 5 2 }
    [ { float 4double-array } declare n/v ] compile-call
] unit-test

[ 4double-array{ 0.5 1 1.5 2 } ] [
    4double-array{ 1 2 3 4 } 2
    [ { float 4double-array } declare v/n ] compile-call
] unit-test

[ 4double-array{ 1 0 0 0 } ] [
    4double-array{ 10 0 0 0 }
    [ { 4double-array } declare normalize ] compile-call
] unit-test

[ 30.0 ] [
    4double-array{ 1 2 3 4 }
    [ { 4double-array } declare norm-sq ] compile-call
] unit-test

[ t ] [
    4double-array{ 1 0 0 0 }
    4double-array{ 0 1 0 0 }
    [ { 4double-array 4double-array } declare distance ] compile-call
    2 sqrt 1.0e-6 ~
] unit-test

