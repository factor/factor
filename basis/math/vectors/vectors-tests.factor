IN: math.vectors.tests
USING: math.vectors tools.test ;

[ { 1 2 3 } ] [ 1/2 { 2 4 6 } n*v ] unit-test
[ { 1 2 3 } ] [ { 2 4 6 } 1/2 v*n ] unit-test
[ { 1 2 3 } ] [ { 2 4 6 } 2 v/n ] unit-test
[ { 1/1 1/2 1/3 } ] [ 1 { 1 2 3 } n/v ] unit-test

[ 5 ] [ { 1 2 } norm-sq ] unit-test
[ 13 ] [ { 2 3 } norm-sq ] unit-test

[ { 1.0  2.5  } ] [ { 1.0 2.5 } { 2.5 1.0 } 0.0 vnlerp ] unit-test 
[ { 2.5  1.0  } ] [ { 1.0 2.5 } { 2.5 1.0 } 1.0 vnlerp ] unit-test 
[ { 1.75 1.75 } ] [ { 1.0 2.5 } { 2.5 1.0 } 0.5 vnlerp ] unit-test 

[ { 1.75 2.125 } ] [ { 1.0 2.5 } { 2.5 1.0 } { 0.5 0.25 } vlerp ] unit-test 
