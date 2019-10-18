USING: kernel math math.functions math.finance tools.test ;

IN: math.finance.tests

[ { 2 4 } ] [ { 1 3 5 } 2 sma ] unit-test

[ { 1 3 1 } ] [ { 1 3 2 6 3 } 2 momentum ] unit-test

[ 4+1/6 ] [ 100 semimonthly ] unit-test
