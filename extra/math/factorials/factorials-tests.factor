USING: kernel math.factorials math.functions ranges sequences tools.test ;

{ 1 } [ -1 factorial ] unit-test ! not necessarily correct
{ 1 } [ 0 factorial ] unit-test
{ 1 } [ 1 factorial ] unit-test
{ 3628800 } [ 10 factorial ] unit-test

{ { 1 1 2 6 24 120 720 5040 40320 362880 3628800 } } [
    10 factorials
] unit-test

{
    {
        1/0. 1/105 1/0. -1/15 1/0. 1/3 1/0. -1 1/0.
        1 1 1 2 3 8 15 48 105 384 945 3840
    }
} [ -10 10 [a..b] [ double-factorial ] map ] unit-test

{ 1 } [ 10 10 factorial/ ] unit-test
{ 720 } [ 10 7 factorial/ ] unit-test
{ 604800 } [ 10 3 factorial/ ] unit-test
{ 3628800 } [ 10 0 factorial/ ] unit-test
{ 6 } [ 3 -3 factorial/ ] unit-test
{ 1/6 } [ -3 3 factorial/ ] unit-test
{ 1/720 } [ 7 10 factorial/ ] unit-test

{ 17160 } [ 10 4 rising-factorial ] unit-test
{ 1/57120 } [ 10 -4 rising-factorial ] unit-test
{ 10 } [ 10 1 rising-factorial ] unit-test
{ 0 } [ 10 0 rising-factorial ] unit-test

{ 5040 } [ 10 4 falling-factorial ] unit-test
{ 1/24024 } [ 10 -4 falling-factorial ] unit-test
{ 10 } [ 10 1 falling-factorial ] unit-test
{ 0 } [ 10 0 falling-factorial ] unit-test

{ 7301694400 } [ 100 5 3 factorial-power ] unit-test
{ 5814000000 } [ 100 5 5 factorial-power ] unit-test
{ 4549262400 } [ 100 5 7 factorial-power ] unit-test
{ 384000000 } [ 100 5 20 factorial-power ] unit-test
{ 384000000 } [ 100 5 20 factorial-power ] unit-test
{ 44262400 } [ 100 5 24 factorial-power ] unit-test
{ 0 } [ 100 5 25 factorial-power ] unit-test
{ 4760 } [ 20 3 3 factorial-power ] unit-test
{ 1/17342 } [ 20 -3 3 factorial-power ] unit-test
{ 1/2618 } [ 20 -3 -3 factorial-power ] unit-test
{ 11960 } [ 20 3 -3 factorial-power ] unit-test
{ t } [ 20 3 [ 1 factorial-power ] [ falling-factorial ] 2bi = ] unit-test
{ t } [ 20 3 [ 0 factorial-power ] [ ^ ] 2bi = ] unit-test

{ { 1 2 6 30 210 2310 } } [ 6 <iota> [ primorial ] map ] unit-test

{ t } [
    6 <iota>
    [ [ double-factorial ] map ]
    [ [ 2 multifactorial ] map ]
    bi =
] unit-test

{ { 1 2 12 120 1680 30240 } }
[ 6 <iota> [ quadruple-factorial ] map ] unit-test

{ { 1 1 2 12 288 } } [ 5 <iota> [ super-factorial ] map ] unit-test

{ { 1 1 4 108 27648 } } [ 5 <iota> [ hyper-factorial ] map ] unit-test

{ { 1 1 1 5 19 101 619 4421 35899 326981 } }
[ 10 <iota> [ alternating-factorial ] map ] unit-test

{ { 1 1 2 9 262144 } } [ 5 <iota> [ exponential-factorial ] map ] unit-test

{ V{ 2 3 5 7 23 719 5039 } }
[ 10,000 <iota> [ factorial-prime? ] filter ] unit-test

{ V{ 3 5 7 29 31 211 2309 2311 } }
[ 10,000 <iota> [ primorial-prime? ] filter ] unit-test

{ 10 } [ 3628800 reverse-factorial ] unit-test
{ 12 } [ 479001600 reverse-factorial ] unit-test
{ 3 } [ 6 reverse-factorial ] unit-test
{ 1 } [ 1 reverse-factorial ] unit-test
{ f } [ 18 reverse-factorial ] unit-test

{
    {
        1
        0
        1
        2
        9
        44
        265
        1854
        14833
        133496
        1334961
        14684570
        176214841
        2290792932
        32071101049
        481066515734
        7697064251745
        130850092279664
        2355301661033953
    }
} [ 19 <iota> [ subfactorial ] map ] unit-test
