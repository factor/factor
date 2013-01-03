IN: math.vectors.tests
USING: math.vectors tools.test kernel specialized-arrays compiler
kernel.private alien.c-types math.functions ;
SPECIALIZED-ARRAY: int

[ { 1 2 3 } ] [ 1/2 { 2 4 6 } n*v ] unit-test
[ { 1 2 3 } ] [ { 2 4 6 } 1/2 v*n ] unit-test
[ { 1 2 3 } ] [ { 2 4 6 } 2 v/n ] unit-test
[ { 1/1 1/2 1/3 } ] [ 1 { 1 2 3 } n/v ] unit-test

{ { 1 4 27 } } [ { 1 2 3 } { 1 2 3 } v^ ] unit-test
{ { 1 4 9 } } [ { 1 2 3 } 2 v^n ] unit-test
{ { 2 4 8 } } [ 2 { 1 2 3 } n^v ] unit-test

[ 5 ] [ { 1 2 } norm-sq ] unit-test
[ 13 ] [ { 2 3 } norm-sq ] unit-test

{ t } [ { 1 2 3 } [ norm ] [ 2 p-norm ] bi = ] unit-test
{ t } [ { 1 2 3 } 3 p-norm 3.301927248894626 1e-10 ~ ] unit-test

[ { 1.0  2.5  } ] [ { 1.0 2.5 } { 2.5 1.0 } 0.0 vnlerp ] unit-test
[ { 2.5  1.0  } ] [ { 1.0 2.5 } { 2.5 1.0 } 1.0 vnlerp ] unit-test
[ { 1.75 1.75 } ] [ { 1.0 2.5 } { 2.5 1.0 } 0.5 vnlerp ] unit-test

[ { 1.75 2.125 } ] [ { 1.0 2.5 } { 2.5 1.0 } { 0.5 0.25 } vlerp ] unit-test 

[ 1.125 ] [ 0.0 1.0 2.0 4.0 { 0.5 0.25 } bilerp ] unit-test

[ 17 ] [ 0 1 2 3 4 5 6 7 { 1 2 3 } trilerp ] unit-test

[ { 0 3 2 5 4 } ] [ { 1 2 3 4 5 } { 1 1 1 1 1 } v+- ] unit-test

[ 32 ] [ { 1 2 3 } { 4 5 6 } v. ] unit-test
[ -1 ] [ { C{ 0 1 } } dup v. ] unit-test

[ 1 ] [ { C{ 0 1 } } dup h. ] unit-test


{ { 1 2 3 } } [
    { t t t } [ { 1 2 3 } ] [ { 4 5 6 } ] vif
] unit-test

{ { 4 5 6 } } [
    { f f f } [ { 1 2 3 } ] [ { 4 5 6 } ] vif
] unit-test

{ { 1 5 3 } } [
    { t f t } [ { 1 2 3 } ] [ { 4 5 6 } ] vif
] unit-test
