USING: math.vectors tools.test kernel specialized-arrays compiler
kernel.private alien.c-types math.functions ranges arrays ;
SPECIALIZED-ARRAY: int

{ { 10 20 30 } } [ 10 { 1 2 3 } n*v ] unit-test
{ { 1 2 3 } } [ 1/2 { 2 4 6 } n*v ] unit-test
{ { 1 2 3 } } [ { 2 4 6 } 1/2 v*n ] unit-test
{ { 1 2 3 } } [ { 2 4 6 } 2 v/n ] unit-test
{ { 1/1 1/2 1/3 } } [ 1 { 1 2 3 } n/v ] unit-test

{ { 1 4 27 } } [ { 1 2 3 } { 1 2 3 } v^ ] unit-test
{ { 1 4 9 } } [ { 1 2 3 } 2 v^n ] unit-test
{ { 2 4 8 } } [ 2 { 1 2 3 } n^v ] unit-test

{ 5 } [ { 1 2 } norm-sq ] unit-test
{ 13 } [ { 2 3 } norm-sq ] unit-test

{ t } [ { 1 2 3 } [ norm ] [ 2 p-norm ] bi = ] unit-test
{ t } [ { 1 2 3 } 3 p-norm 3.301927248894626 1e-10 ~ ] unit-test

{ { 1.0  2.5  } } [ { 1.0 2.5 } { 2.5 1.0 } 0.0 vnlerp ] unit-test
{ { 2.5  1.0  } } [ { 1.0 2.5 } { 2.5 1.0 } 1.0 vnlerp ] unit-test
{ { 1.75 1.75 } } [ { 1.0 2.5 } { 2.5 1.0 } 0.5 vnlerp ] unit-test

{ { 1.75 2.125 } } [ { 1.0 2.5 } { 2.5 1.0 } { 0.5 0.25 } vlerp ] unit-test

{ 1.125 } [ 0.0 1.0 2.0 4.0 { 0.5 0.25 } bilerp ] unit-test

{ 17 } [ 0 1 2 3 4 5 6 7 { 1 2 3 } trilerp ] unit-test

{ { 0 3 2 5 4 } } [ { 1 2 3 4 5 } { 1 1 1 1 1 } v+- ] unit-test

{ 32 } [ { 1 2 3 } { 4 5 6 } vdot ] unit-test
{ -1 } [ { C{ 0 1 } } dup vdot ] unit-test

{ 1 } [ { C{ 0 1 } } dup hdot ] unit-test

{ { 1 2 3 } } [
    { t t t } [ { 1 2 3 } ] [ { 4 5 6 } ] vif
] unit-test

{ { 4 5 6 } } [
    { f f f } [ { 1 2 3 } ] [ { 4 5 6 } ] vif
] unit-test

{ { 1 5 3 } } [
    { t f t } [ { 1 2 3 } ] [ { 4 5 6 } ] vif
] unit-test

{ { 0 30 100 } } [
    { -10 30 120 } { 0 0 0 } { 100 100 100 } vclamp
] unit-test

{ { 0 0 1 } } [ { 1 0 0 } { 0 1 0 } cross ] unit-test
{ { 1 0 0 } } [ { 0 1 0 } { 0 0 1 } cross ] unit-test
{ { 0 1 0 } } [ { 0 0 1 } { 1 0 0 } cross ] unit-test
{ { 0.0 -0.707 0.707 } } [ { 1.0 0.0 0.0 } { 0.0 0.707 0.707 } cross ] unit-test
{ { 0 -2 2 } } [ { -1 -1 -1 } { 1 -1 -1 } cross ] unit-test
{ { 1 0 0 } } [ { 1 1 0 } { 1 0 0 } proj ] unit-test

{ { 3 12 21 30 } } [ 3 1 10 3 <range> n*v >array ] unit-test
{ { 3 12 21 30  } } [ 1 10 3 <range> 3 v*n >array ] unit-test
{ { 4 7 10 13 } } [ 3 1 10 3 <range> n+v >array ] unit-test
{ { 4 7 10 13 } } [ 1 10 3 <range> 3 v+n >array ] unit-test
{ { 2 -1 -4 -7 } } [ 3 1 10 3 <range> n-v >array ] unit-test
{ { -2 1 4 7 } } [ 1 10 3 <range> 3 v-n >array ] unit-test
{ { 1/3 4/3 7/3 10/3 } } [ 1 10 3 <range> 3 v/n >array ] unit-test
{ { 6 11 16 21 } } [ 1 10 3 <range> 5 20 2 <range> v+ >array ] unit-test
{ { -4 -3 -2 -1 } } [ 1 10 3 <range> 5 20 2 <range> v- >array ] unit-test

{ { 3 11/2 8 21/2 } } [ 1 10 3 <range> 5 20 2 <range> vavg >array ] unit-test
{ { -1 -4 -7 -10 } } [ 1 10 3 <range> vneg >array ] unit-test
