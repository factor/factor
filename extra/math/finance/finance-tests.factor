USING: kernel math math.functions math.finance sequences
tools.test ;

IN: math.finance.tests

[ { 1 2 3 4 5 } ] [ { 1 2 3 4 5 } 1 ema ] unit-test
[ { 1+1/2 2+1/2 3+1/2 4+1/2 } ] [ { 1 2 3 4 5 } 2 ema ] unit-test
[ { 2 3 4 } ] [ { 1 2 3 4 5 } 3 ema ] unit-test

[ { 2 4 } ] [ { 1 3 5 } 2 sma ] unit-test

[ { 2 3 4 5 } ] [ 6 iota 2 dema ] unit-test

[ t ] [ 6 iota 2 [ dema ] [ 1 gdema ] 2bi = ] unit-test

[ { 3 4 5 } ] [ 6 iota 2 tema ] unit-test
[ { 6 7 8 9 } ] [ 10 iota 3 tema ] unit-test

[ { 1 3 1 } ] [ { 1 3 2 6 3 } 2 momentum ] unit-test

[ 4+1/6 ] [ 100 semimonthly ] unit-test
