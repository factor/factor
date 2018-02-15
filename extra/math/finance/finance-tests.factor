USING: kernel math math.functions math.finance sequences
tools.test ;

{ { 1 2 3 4 5 } } [ { 1 2 3 4 5 } 1 ema ] unit-test
{ { 1+1/2 2+1/2 3+1/2 4+1/2 } } [ { 1 2 3 4 5 } 2 ema ] unit-test
{ { 2 3 4 } } [ { 1 2 3 4 5 } 3 ema ] unit-test

{ { 2 4 } } [ { 1 3 5 } 2 sma ] unit-test

{ { 2 3 4 5 } } [ 6 <iota> 2 dema ] unit-test

{ t } [ 6 <iota> 2 [ dema ] [ 1 gdema ] 2bi = ] unit-test

{ { 3 4 5 } } [ 6 <iota> 2 tema ] unit-test
{ { 6 7 8 9 } } [ 10 <iota> 3 tema ] unit-test

{ { 1 3 1 } } [ { 1 3 2 6 3 } 2 momentum ] unit-test

{ { 0.0 50.0 25.0 75.0 100.0 125.0 -50.0 -75.0 -90.0 } } [
    { 1 1.5 1.25 1.75 2.0 2.25 0.5 0.25 0.1 } performance
] unit-test

{ 4+1/6 } [ 100 semimonthly ] unit-test
