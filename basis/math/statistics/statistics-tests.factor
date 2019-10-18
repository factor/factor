USING: assocs kernel math math.functions math.statistics sequences
math.order tools.test math.vectors ;
IN: math.statistics.tests

[ 3 ] [ { 1 2 3 4 5 } 1 power-mean ] unit-test
[ t ] [ { 1 2 3 4 5 } [ 2 power-mean ] [ quadratic-mean ] bi 1e-10 ~ ] unit-test
[ 1 ] [ { 1 } mean ] unit-test
[ 3/2 ] [ { 1 2 } mean ] unit-test
[ 0 ] [ { 0 0 0 } geometric-mean ] unit-test
[ t ] [ { 2 2 2 2 } geometric-mean 2.0 .0001 ~ ] unit-test
[ 1.0 ] [ { 1 1 1 } geometric-mean ] unit-test
[ 1/3 ] [ { 1 1 1 } harmonic-mean ] unit-test
[ 5+1/4 ] [ { 1 3 5 7 } contraharmonic-mean ] unit-test
[ 18 ] [ { 4 8 15 16 23 42 } 0 trimmed-mean ] unit-test
[ 15+1/2 ] [ { 4 8 15 16 23 42 } 0.2 trimmed-mean ] unit-test
[ 3 ] [ { 1 3 3 3 3 5 } 0.2 winsorized-mean ] unit-test

[ 0 ] [ { 1 } range ] unit-test
[ 89 ] [ { 1 2 30 90 } range ] unit-test
[ 2 ] [ { 1 2 3 } median ] unit-test
[ 5/2 ] [ { 1 2 3 4 } median ] unit-test

{ 1 } [ { 1 2 3 4 } 0 kth-smallest ] unit-test
{ 3 } [ { 1 2 3 4 } 2 kth-smallest ] unit-test

{ 4 } [ { 1 2 3 4 } 0 kth-largest ] unit-test
{ 2 } [ { 1 2 3 4 } 2 kth-largest ] unit-test

[ { 1 2 3 4 } 30 kth-largest ] [ bounds-error? ] must-fail-with
[ { 1 2 3 4 } 2 [ [ ] compare ] kth-object ] [ bounds-error? ] must-fail-with
{ 3 } [ { 1 2 3 4 } 2 [ before? ] kth-object ] unit-test

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

[ 1 ] [ { 1 2 3 } var ] unit-test
[ 16 ] [ { 4 6 8 10 10 12 14 16 } var ] unit-test

[ 16 ] [ { 4 6 8 10 12 14 16 } full-var ] unit-test
[ 1.0 ] [ { 7 8 9 } std ] unit-test
[ t ] [ { 1 2 3 4 } ste 0.6454972243679028 - .0001 < ] unit-test

[ t ] [ { 23.2 33.4 22.5 66.3 44.5 } std 18.1906 - .0001 < ] unit-test

[ 0 ] [ { 1 } var ] unit-test
[ 0.0 ] [ { 1 } std ] unit-test
[ 0.0 ] [ { 1 } ste ] unit-test

{ 2 } [ { 1 3 5 7 } mean-dev ] unit-test
{ 4/5 } [ { 1 3 3 3 5 } median-dev ] unit-test

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

[ 0.75 ] [ { 1 2 3 4 } dup corr ] unit-test
[ -0.75 ] [ { 1 2 3 4 } { -4 -5 -6 -7 } corr ] unit-test

[ { 1 2 4 7 } ] [ { 1 1 2 3 } cum-sum ] unit-test
[ { 1 1 2 6 } ] [ { 1 1 2 3 } cum-product ] unit-test
[ { 5 3 3 1 } ] [ { 5 3 4 1 } cum-min ] unit-test
[ { 1 3 3 5 } ] [ { 1 3 1 5 } cum-max ] unit-test

{ t }
[
    { 6 7 15 36 39 40 41 42 43 47 49 } { 1/4 1/2 3/4 } quantile1 [ >float ] map
    { 15.0 40.0 43.0 } .00001 v~
] unit-test

{ t }
[
    { 6 7 15 36 39 40 41 42 43 47 49 } { 1/4 1/2 3/4 } quantile3 [ >float ] map
    { 15.0 40.0 42.0 } .00001 v~
] unit-test

{ t }
[
    { 6 7 15 36 39 40 41 42 43 47 49 } { 1/4 1/2 3/4 } quantile4 [ >float ] map
    { 13.0 39.5 42.25 } .00001 v~
] unit-test

{ t }
[
    { 6 7 15 36 39 40 41 42 43 47 49 } { 1/4 1/2 3/4 } quantile5 [ >float ] map
    { 20+1/4 40 42+3/4 } .00001 v~
] unit-test

{ t }
[
    { 6 7 15 36 39 40 41 42 43 47 49 } { 1/4 1/2 3/4 } quantile6 [ >float ] map
    { 15.0 40.0 43.0 } .00001 v~
] unit-test

{ t }
[
    { 6 7 15 36 39 40 41 42 43 47 49 } { 1/4 1/2 3/4 } quantile7 [ >float ] map
    { 25.5 40.0 42.5 } .00001 v~
] unit-test

{ t }
[
    { 6 7 15 36 39 40 41 42 43 47 49 } { 1/4 1/2 3/4 } quantile8 [ >float ] map
    { 18.5 40.0 42.83333333333334 } .00001 v~
] unit-test

{ t }
[
    { 6 7 15 36 39 40 41 42 43 47 49 } { 1/4 1/2 3/4 } quantile9 [ >float ] map
    { 18.9375 40.0 42.8125 } .00001 v~
] unit-test

{ 1.0986122886681096 } [ { 1 2 3 } entropy ] unit-test

{ 1.0 } [ 0.5 binary-entropy ] unit-test

{ { -4 13 -5 2 4 } } [ { 1 -3 10 5 7 11 } differences ] unit-test

{ t t } [
    { 6.5 3.8 6.6 5.7 6.0 6.4 5.3 } standardize
    [ mean 0 1e-10 ~ ] [ var 1 1e-10 ~ ] bi
] unit-test

{ { 0 1/4 1/2 3/4 1 } } [ 5 iota rescale ] unit-test
