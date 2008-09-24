USING: kernel math math.functions math.finance tools.test ;

IN: math.finance.tests

[ { 2 4 } ] [ { 1 3 5 } 2 sma ] unit-test

[ { 1 3 1 } ] [ { 1 3 2 6 3 } 2 momentum ] unit-test

[ { 3 } ] [ 3 1 distribute ] unit-test
[ { 1 1 1 } ] [ 3 3 distribute ] unit-test
[ { 2 1 2 } ] [ 5 3 distribute ] unit-test
[ { 1 0 1 0 1 } ] [ 3 5 distribute ] unit-test
[ { 143 143 143 142 143 143 143 } ] [ 1000 7 distribute ] unit-test

