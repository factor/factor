USING: kernel math math.functions math.statistics tools.test ;
IN: temporary

[ 1 ] [ { 1 } mean ] unit-test
[ 3/2 ] [ { 1 2 } mean ] unit-test
[ 0 ] [ { 0 0 0 } geometric-mean ] unit-test
[ t ] [ { 2 2 2 2 } geometric-mean 2.0 .0001 ~ ] unit-test
[ 1 ] [ { 1 1 1 } geometric-mean ] unit-test
[ 1/3 ] [ { 1 1 1 } harmonic-mean ] unit-test

[ 0 ] [ { 1 } range ] unit-test
[ 89 ] [ { 1 2 30 90 } range ] unit-test
[ 2 ] [ { 1 2 3 } median ] unit-test
[ 5/2 ] [ { 1 2 3 4 } median ] unit-test

[ 1 ] [ { 1 2 3 } var ] unit-test
[ 1 ] [ { 1 2 3 } std ] unit-test

[ t ] [ { 23.2 33.4 22.5 66.3 44.5 } std 18.1906 - .0001 < ] unit-test

[ 0 ] [ { 1 } var ] unit-test
[ 0 ] [ { 1 } std ] unit-test

