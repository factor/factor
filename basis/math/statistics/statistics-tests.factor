USING: assocs kernel math math.functions math.statistics sequences tools.test ;
IN: math.statistics.tests

[ 1 ] [ { 1 } mean ] unit-test
[ 3/2 ] [ { 1 2 } mean ] unit-test
[ 0 ] [ { 0 0 0 } geometric-mean ] unit-test
[ t ] [ { 2 2 2 2 } geometric-mean 2.0 .0001 ~ ] unit-test
[ 1.0 ] [ { 1 1 1 } geometric-mean ] unit-test
[ 1/3 ] [ { 1 1 1 } harmonic-mean ] unit-test

[ 0 ] [ { 1 } range ] unit-test
[ 89 ] [ { 1 2 30 90 } range ] unit-test
[ 2 ] [ { 1 2 3 } median ] unit-test
[ 5/2 ] [ { 1 2 3 4 } median ] unit-test

{ 1 } [ { 1 2 3 4 } 0 kth-smallest ] unit-test
{ 3 } [ { 1 2 3 4 } 2 kth-smallest ] unit-test

{ 4 } [ { 1 2 3 4 } 0 kth-largest ] unit-test
{ 2 } [ { 1 2 3 4 } 2 kth-largest ] unit-test

[ 1 ] [ { 1 } mode ] unit-test
[ 3 ] [ { 1 2 3 3 3 4 5 6 76 7 2 21 1 3 3 3 } mode ] unit-test

[ { } median ] must-fail
[ { } upper-median ] must-fail
[ { } lower-median ] must-fail

[ 2 ] [ { 1 2 3 4 } lower-median ] unit-test
[ 3 ] [ { 1 2 3 4 } upper-median ] unit-test
[ 3 ] [ { 1 2 3 4 5 } lower-median ] unit-test
[ 3 ] [ { 1 2 3 4 5 } upper-median ] unit-test


[ 1 ] [ { 1 } lower-median ] unit-test
[ 1 ] [ { 1 } upper-median ] unit-test
[ 1 ] [ { 1 } median ] unit-test

[ 1 ] [ { 1 2 } lower-median ] unit-test
[ 2 ] [ { 1 2 } upper-median ] unit-test
[ 3/2 ] [ { 1 2 } median ] unit-test

[ 1 ] [ { 1 2 3 } sample-var ] unit-test
[ 16 ] [ { 4 6 8 10 10 12 14 16 } sample-var ] unit-test

[ 16 ] [ { 4 6 8 10 12 14 16 } var ] unit-test
[ 4.0 ] [ { 4 6 8 10 12 14 16 } std ] unit-test
[ t ] [ { 1 2 3 4 } ste 0.6454972243679028 - .0001 < ] unit-test

[ t ] [ { 23.2 33.4 22.5 66.3 44.5 } std 18.1906 - .0001 < ] unit-test

[ 0 ] [ { 1 } var ] unit-test
[ 0.0 ] [ { 1 } std ] unit-test
[ 0.0 ] [ { 1 } ste ] unit-test

[
    H{
        { 97 2 }
        { 98 2 }
        { 99 2 }
    }
] [
    "aabbcc" histogram
] unit-test

{
    V{ 0 3 6 9 }
    V{ 1 4 7 }
    V{ 2 5 8 }
} [
    10 iota [ 3 mod ] collect-by
    [ 0 swap at ] [ 1 swap at ] [ 2 swap at ] tri
] unit-test

[ 0 ] [ { 1 } { 1 } cov ] unit-test
[ 2/3 ] [ { 1 2 3 } { 4 5 6 } cov ] unit-test

[ 1.0 ] [ { 1 2 3 } { 1 2 3 } corr ] unit-test
[ -1.0 ] [ { 1 2 3 } { -4 -5 -6 } corr ] unit-test

[ { 1 2 4 7 } ] [ { 1 1 2 3 } cum-sum ] unit-test
[ { 1 1 2 6 } ] [ { 1 1 2 3 } cum-product ] unit-test
[ { 5 3 3 1 } ] [ { 5 3 4 1 } cum-min ] unit-test
[ { 1 3 3 5 } ] [ { 1 3 1 5 } cum-max ] unit-test
