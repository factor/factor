IN: math.vectors.simd.tests
USING: math math.vectors.simd math.vectors.simd.private
math.vectors math.functions math.private kernel.private compiler
sequences tools.test compiler.tree.debugger accessors kernel
system ;

[ float-4{ 0 0 0 0 } ] [ float-4 new ] unit-test

[ float-4{ 0 0 0 0 } ] [ [ float-4 new ] compile-call ] unit-test

[ V{ float } ] [ [ { float-4 } declare norm-sq ] final-classes ] unit-test

[ V{ float } ] [ [ { float-4 } declare norm ] final-classes ] unit-test

[ float-4{ 12 12 12 12 } ] [
    12 [ float-4-with ] compile-call
] unit-test

[ float-4{ 1 2 3 4 } ] [
    1 2 3 4 [ float-4-boa ] compile-call
] unit-test

[ float-4{ 11 22 33 44 } ] [
    float-4{ 1 2 3 4 } float-4{ 10 20 30 40 }
    [ { float-4 float-4 } declare v+ ] compile-call
] unit-test

[ float-4{ -9 -18 -27 -36 } ] [
    float-4{ 1 2 3 4 } float-4{ 10 20 30 40 }
    [ { float-4 float-4 } declare v- ] compile-call
] unit-test

[ float-4{ 10 40 90 160 } ] [
    float-4{ 1 2 3 4 } float-4{ 10 20 30 40 }
    [ { float-4 float-4 } declare v* ] compile-call
] unit-test

[ float-4{ 10 100 1000 10000 } ] [
    float-4{ 100 2000 30000 400000 } float-4{ 10 20 30 40 }
    [ { float-4 float-4 } declare v/ ] compile-call
] unit-test

[ float-4{ -10 -20 -30 -40 } ] [
    float-4{ -10 20 -30 40 } float-4{ 10 -20 30 -40 }
    [ { float-4 float-4 } declare vmin ] compile-call
] unit-test

[ float-4{ 10 20 30 40 } ] [
    float-4{ -10 20 -30 40 } float-4{ 10 -20 30 -40 }
    [ { float-4 float-4 } declare vmax ] compile-call
] unit-test

[ 10.0 ] [
    float-4{ 1 2 3 4 }
    [ { float-4 } declare sum ] compile-call
] unit-test

[ 13.0 ] [
    float-4{ 1 2 3 4 }
    [ { float-4 } declare sum 3.0 + ] compile-call
] unit-test

[ 8.0 ] [
    float-4{ 1 2 3 4 } float-4{ 2 0 2 0 }
    [ { float-4 float-4 } declare v. ] compile-call
] unit-test

[ float-4{ 5 10 15 20 } ] [
    5.0 float-4{ 1 2 3 4 }
    [ { float float-4 } declare n*v ] compile-call
] unit-test

[ float-4{ 5 10 15 20 } ] [
    float-4{ 1 2 3 4 } 5.0
    [ { float float-4 } declare v*n ] compile-call
] unit-test

[ float-4{ 10 5 2 5 } ] [
    10.0 float-4{ 1 2 5 2 }
    [ { float float-4 } declare n/v ] compile-call
] unit-test

[ float-4{ 0.5 1 1.5 2 } ] [
    float-4{ 1 2 3 4 } 2
    [ { float float-4 } declare v/n ] compile-call
] unit-test

[ float-4{ 1 0 0 0 } ] [
    float-4{ 10 0 0 0 }
    [ { float-4 } declare normalize ] compile-call
] unit-test

[ 30.0 ] [
    float-4{ 1 2 3 4 }
    [ { float-4 } declare norm-sq ] compile-call
] unit-test

[ t ] [
    float-4{ 1 0 0 0 }
    float-4{ 0 1 0 0 }
    [ { float-4 float-4 } declare distance ] compile-call
    2 sqrt 1.0e-6 ~
] unit-test

[ double-2{ 12 12 } ] [
    12 [ double-2-with ] compile-call
] unit-test

[ double-2{ 1 2 } ] [
    1 2 [ double-2-boa ] compile-call
] unit-test

[ double-2{ 11 22 } ] [
    double-2{ 1 2 } double-2{ 10 20 }
    [ { double-2 double-2 } declare v+ ] compile-call
] unit-test

[ double-2{ -9 -18 } ] [
    double-2{ 1 2 } double-2{ 10 20 }
    [ { double-2 double-2 } declare v- ] compile-call
] unit-test

[ double-2{ 10 40 } ] [
    double-2{ 1 2 } double-2{ 10 20 }
    [ { double-2 double-2 } declare v* ] compile-call
] unit-test

[ double-2{ 10 100 } ] [
    double-2{ 100 2000 } double-2{ 10 20 }
    [ { double-2 double-2 } declare v/ ] compile-call
] unit-test

[ double-2{ -10 -20 } ] [
    double-2{ -10 20 } double-2{ 10 -20 }
    [ { double-2 double-2 } declare vmin ] compile-call
] unit-test

[ double-2{ 10 20 } ] [
    double-2{ -10 20 } double-2{ 10 -20 }
    [ { double-2 double-2 } declare vmax ] compile-call
] unit-test

[ 3.0 ] [
    double-2{ 1 2 }
    [ { double-2 } declare sum ] compile-call
] unit-test

[ 7.0 ] [
    double-2{ 1 2 }
    [ { double-2 } declare sum 4.0 + ] compile-call
] unit-test

[ 16.0 ] [
    double-2{ 1 2 } double-2{ 2 7 }
    [ { double-2 double-2 } declare v. ] compile-call
] unit-test

[ double-2{ 5 10 } ] [
    5.0 double-2{ 1 2 }
    [ { float double-2 } declare n*v ] compile-call
] unit-test

[ double-2{ 5 10 } ] [
    double-2{ 1 2 } 5.0
    [ { float double-2 } declare v*n ] compile-call
] unit-test

[ double-2{ 10 5 } ] [
    10.0 double-2{ 1 2 }
    [ { float double-2 } declare n/v ] compile-call
] unit-test

[ double-2{ 0.5 1 } ] [
    double-2{ 1 2 } 2
    [ { float double-2 } declare v/n ] compile-call
] unit-test

[ double-2{ 0 0 } ] [ double-2 new ] unit-test

[ double-2{ 1 0 } ] [
    double-2{ 10 0 }
    [ { double-2 } declare normalize ] compile-call
] unit-test

[ 5.0 ] [
    double-2{ 1 2 }
    [ { double-2 } declare norm-sq ] compile-call
] unit-test

[ t ] [
    double-2{ 1 0 }
    double-2{ 0 1 }
    [ { double-2 double-2 } declare distance ] compile-call
    2 sqrt 1.0e-6 ~
] unit-test

[ double-4{ 0 0 0 0 } ] [ double-4 new ] unit-test

[ double-4{ 1 2 3 4 } ] [
    1 2 3 4 double-4-boa
] unit-test

[ double-4{ 1 1 1 1 } ] [
    1 double-4-with
] unit-test

[ double-4{ 0 1 2 3 } ] [
    1 double-4-with [ * ] map-index
] unit-test

[ V{ float } ] [ [ { double-4 } declare norm-sq ] final-classes ] unit-test

[ V{ float } ] [ [ { double-4 } declare norm ] final-classes ] unit-test

[ double-4{ 12 12 12 12 } ] [
    12 [ double-4-with ] compile-call
] unit-test

[ double-4{ 1 2 3 4 } ] [
    1 2 3 4 [ double-4-boa ] compile-call
] unit-test

[ double-4{ 11 22 33 44 } ] [
    double-4{ 1 2 3 4 } double-4{ 10 20 30 40 }
    [ { double-4 double-4 } declare v+ ] compile-call
] unit-test

[ double-4{ -9 -18 -27 -36 } ] [
    double-4{ 1 2 3 4 } double-4{ 10 20 30 40 }
    [ { double-4 double-4 } declare v- ] compile-call
] unit-test

[ double-4{ 10 40 90 160 } ] [
    double-4{ 1 2 3 4 } double-4{ 10 20 30 40 }
    [ { double-4 double-4 } declare v* ] compile-call
] unit-test

[ double-4{ 10 100 1000 10000 } ] [
    double-4{ 100 2000 30000 400000 } double-4{ 10 20 30 40 }
    [ { double-4 double-4 } declare v/ ] compile-call
] unit-test

[ double-4{ -10 -20 -30 -40 } ] [
    double-4{ -10 20 -30 40 } double-4{ 10 -20 30 -40 }
    [ { double-4 double-4 } declare vmin ] compile-call
] unit-test

[ double-4{ 10 20 30 40 } ] [
    double-4{ -10 20 -30 40 } double-4{ 10 -20 30 -40 }
    [ { double-4 double-4 } declare vmax ] compile-call
] unit-test

[ 10.0 ] [
    double-4{ 1 2 3 4 }
    [ { double-4 } declare sum ] compile-call
] unit-test

[ 13.0 ] [
    double-4{ 1 2 3 4 }
    [ { double-4 } declare sum 3.0 + ] compile-call
] unit-test

[ 8.0 ] [
    double-4{ 1 2 3 4 } double-4{ 2 0 2 0 }
    [ { double-4 double-4 } declare v. ] compile-call
] unit-test

[ double-4{ 5 10 15 20 } ] [
    5.0 double-4{ 1 2 3 4 }
    [ { float double-4 } declare n*v ] compile-call
] unit-test

[ double-4{ 5 10 15 20 } ] [
    double-4{ 1 2 3 4 } 5.0
    [ { float double-4 } declare v*n ] compile-call
] unit-test

[ double-4{ 10 5 2 5 } ] [
    10.0 double-4{ 1 2 5 2 }
    [ { float double-4 } declare n/v ] compile-call
] unit-test

[ double-4{ 0.5 1 1.5 2 } ] [
    double-4{ 1 2 3 4 } 2
    [ { float double-4 } declare v/n ] compile-call
] unit-test

[ double-4{ 1 0 0 0 } ] [
    double-4{ 10 0 0 0 }
    [ { double-4 } declare normalize ] compile-call
] unit-test

[ 30.0 ] [
    double-4{ 1 2 3 4 }
    [ { double-4 } declare norm-sq ] compile-call
] unit-test

[ t ] [
    double-4{ 1 0 0 0 }
    double-4{ 0 1 0 0 }
    [ { double-4 double-4 } declare distance ] compile-call
    2 sqrt 1.0e-6 ~
] unit-test

[ float-8{ 0 0 0 0 0 0 0 0 } ] [ float-8 new ] unit-test

[ float-8{ 0 0 0 0 0 0 0 0 } ] [ [ float-8 new ] compile-call ] unit-test

[ float-8{ 1 1 1 1 1 1 1 1 } ] [ 1 float-8-with ] unit-test

[ float-8{ 1 1 1 1 1 1 1 1 } ] [ [ 1 float-8-with ] compile-call ] unit-test

[ float-8{ 1 2 3 4 5 6 7 8 } ] [ 1 2 3 4 5 6 7 8 float-8-boa ] unit-test

[ float-8{ 1 2 3 4 5 6 7 8 } ] [ [ 1 2 3 4 5 6 7 8 float-8-boa ] compile-call ] unit-test

[ float-8{ 3 6 9 12 15 18 21 24 } ] [
    float-8{ 1 2 3 4 5 6 7 8 }
    float-8{ 2 4 6 8 10 12 14 16 }
    [ { float-8 float-8 } declare v+ ] compile-call
] unit-test

[ float-8{ -1 -2 -3 -4 -5 -6 -7 -8 } ] [
    float-8{ 1 2 3 4 5 6 7 8 }
    float-8{ 2 4 6 8 10 12 14 16 }
    [ { float-8 float-8 } declare v- ] compile-call
] unit-test

[ float-8{ -1 -2 -3 -4 -5 -6 -7 -8 } ] [
    -0.5
    float-8{ 2 4 6 8 10 12 14 16 }
    [ { float float-8 } declare n*v ] compile-call
] unit-test

[ float-8{ -1 -2 -3 -4 -5 -6 -7 -8 } ] [
    float-8{ 2 4 6 8 10 12 14 16 }
    -0.5
    [ { float-8 float } declare v*n ] compile-call
] unit-test

[ float-8{ 256 128 64 32 16 8 4 2 } ] [
    256.0
    float-8{ 1 2 4 8 16 32 64 128 }
    [ { float float-8 } declare n/v ] compile-call
] unit-test

[ float-8{ -1 -2 -3 -4 -5 -6 -7 -8 } ] [
    float-8{ 2 4 6 8 10 12 14 16 }
    -2.0
    [ { float-8 float } declare v/n ] compile-call
] unit-test

! Test puns; only on x86
cpu x86? [
    [ double-2{ 4 1024 } ] [
        float-4{ 0 1 0 2 }
        [ { float-4 } declare dup v+ underlying>> double-2 boa dup v+ ] compile-call
    ] unit-test
    
    [ 33.0 ] [
        double-2{ 1 2 } double-2{ 10 20 }
        [ { double-2 double-2 } declare v+ underlying>> 3.0 float* ] compile-call
    ] unit-test
] when
