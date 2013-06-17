USING: assocs kernel math math.functions math.statistics sequences
math.order tools.test math.vectors ;
FROM: math.ranges => [a,b] ;
IN: math.statistics.tests

[ 3 ] [ { 1 2 3 4 5 } 1 power-mean ] unit-test
[ t ] [ { 1 2 3 4 5 } [ 2 power-mean ] [ quadratic-mean ] bi 1e-10 ~ ] unit-test
[ 1 ] [ { 1 } mean ] unit-test
[ 0 ] [ { } mean ] unit-test
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

[ 1 ] [ { 1 2 3 } sample-var ] unit-test
[ 16 ] [ { 4 6 8 10 10 12 14 16 } sample-var ] unit-test

{ 16 } [ { 4 6 8 10 12 14 16 } population-var ] unit-test
{ 1.0 } [ { 7 8 9 } sample-std ] unit-test
{ 2/3 } [ { 7 8 9 } 0 var-ddof ] unit-test
{ 2/3 } [ { 7 8 9 } population-var ] unit-test
{ 1 } [ { 7 8 9 } 1 var-ddof ] unit-test
{ 1 } [ { 7 8 9 } sample-var ] unit-test
{ 2 } [ { 7 8 9 } 2 var-ddof ] unit-test
{ 0 } [ { 7 8 9 } 3 var-ddof ] unit-test

{ t } [ { 7 8 9 } 0 std-ddof 0.816496580927726 .0001 ~ ] unit-test
{ t } [ { 7 8 9 } population-std 0.816496580927726 .0001 ~ ] unit-test
{ 1.0 } [ { 7 8 9 } 1 std-ddof ] unit-test
{ 1.0 } [ { 7 8 9 } sample-std ] unit-test
{ 1.0 } [ { 7 8 9 } sample-std ] unit-test
{ t } [ { 7 8 9 } 2 std-ddof 1.414213562373095 .0001 ~ ] unit-test
{ 0.0 } [ { 7 8 9 } 3 std-ddof ] unit-test

[ t ] [ { 1 2 3 4 } sample-ste 0.6454972243679028 - .0001 < ] unit-test

[ t ] [ { 23.2 33.4 22.5 66.3 44.5 } sample-std 18.1906 - .0001 < ] unit-test

[ 0 ] [ { 1 } sample-var ] unit-test
[ 0.0 ] [ { 1 } sample-std ] unit-test
[ 0.0 ] [ { 1 } sample-ste ] unit-test

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

{ H{ { 1 1/2 } { 2 1/6 } { 3 1/3 } } }
[ { 1 1 1 1 1 1 2 2 3 3 3 3 } normalized-histogram ] unit-test

{
    V{ 0 3 6 9 }
    V{ 1 4 7 }
    V{ 2 5 8 }
} [
    10 iota [ 3 mod ] collect-by
    [ 0 of ] [ 1 of ] [ 2 of ] tri
] unit-test

[ 0 ] [ { 1 } { 1 } sample-cov ] unit-test
[ 2/3 ] [ { 1 2 3 } { 4 5 6 } population-cov ] unit-test

[ 0.75 ] [ { 1 2 3 4 } dup sample-corr ] unit-test
[ 1.0 ] [ { 1 2 3 4 } dup population-corr ] unit-test
[ -0.75 ] [ { 1 2 3 4 } { -4 -5 -6 -7 } sample-corr ] unit-test

[ { 1 2 4 7 } ] [ { 1 1 2 3 } cum-sum ] unit-test
[ { 1 1 2 6 } ] [ { 1 1 2 3 } cum-product ] unit-test
[ { 5 3 3 1 } ] [ { 5 3 4 1 } cum-min ] unit-test
[ { 1 3 3 5 } ] [ { 1 3 1 5 } cum-max ] unit-test
[ { 1.0 1.5 2.0 } ] [ { 1.0 2.0 3.0 } cum-mean ] unit-test

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

{ 0x1.02eb63cff3f8p0 } [ { 1 2 3 } entropy ] unit-test

{ 1.0 } [ 0.5 binary-entropy ] unit-test

{ { -4 13 -5 2 4 } } [ { 1 -3 10 5 7 11 } differences ] unit-test

{ t t } [
    { 6.5 3.8 6.6 5.7 6.0 6.4 5.3 } standardize
    [ mean 0 1e-10 ~ ] [ sample-var 1 1e-10 ~ ] bi
] unit-test

{ t t } [
    { { 1 -1 2 } { 2 0 0 } { 0 1 -1 } } standardize-2d
    flip
    [ [ mean ] map { 0 0 0 } 1e-10 v~ ]
    [ [ sample-var ] map { 1 1 1 } 1e-10 v~ ] bi
] unit-test

{ { 0 0 0 } } [ { 1 1 1 } standardize ] unit-test

{ { 0 1/4 1/2 3/4 1 } } [ 5 iota rescale ] unit-test


{
    { 2 2 2 1 0 5 6 7 7 7 7 }
} [
    { 30 30 30 20 10 40 50 60 60 60 60 } rank-values
] unit-test

{
    { 1 0 2 3 4 }
}
[ { 3 1 4 15 92 } rank-values ] unit-test

{ { 1 1 2 3 3 4 } }
[ { 1 2 3 3 2 3 } [ odd? ] cum-count ] unit-test

{ { 0 0 1 2 2 3 } }
[ { 1 2 3 3 2 3 } [ 3 = ] cum-count ] unit-test

{ { 0 1 3 6 } }
[ { 1 2 3 4 } cum-sum0 ] unit-test

{
    H{
        { 0 V{ 600 603 606 609 } }
        { 1 V{ 601 604 607 610 } }
        { 2 V{ 602 605 608 } }
    }
}
[ 600 610 [a,b] [ 3 mod ] collect-by ] unit-test


{
    H{ { 0 V{ 0 3 6 9 } } { 1 V{ 1 4 7 10 } } { 2 V{ 2 5 8 } } }
}
[ 600 610 [a,b] [ 3 mod ] collect-index-by ] unit-test


{ { 1 } } [
    { 1 2 3 4 5 10 21 12 12 12 12203 3403 030 3022 2 2 }
    { 1/1000 } quantile5
] unit-test
