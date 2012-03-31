USING: random sequences tools.test kernel math math.functions
sets grouping random.private math.statistics ;
IN: random.tests

[ 4 ] [ 4 random-bytes length ] unit-test
[ 7 ] [ 7 random-bytes length ] unit-test

[ 4 ] [ [ 4 random-bytes length ] with-secure-random ] unit-test
[ 7 ] [ [ 7 random-bytes length ] with-secure-random ] unit-test

[ 2 ] [ V{ 10 20 30 } [ delete-random drop ] keep length ] unit-test
[ V{ } [ delete-random drop ] keep length ] must-fail

[ t ] [ 10000 [ iota 0 [ drop 187 random + ] reduce ] keep / 2 * 187 10 ~ ] unit-test
[ t ] [ 10000 [ iota 0 [ drop 400 random + ] reduce ] keep / 2 * 400 10 ~ ] unit-test

[ t ] [ 1000 [ 400 random ] replicate members length 256 > ] unit-test

[ f ] [ 0 random ] unit-test

[ { } ] [ { } randomize ] unit-test
[ { 1 } ] [ { 1 } randomize ] unit-test

[ f ]
[ 100 [ { 0 1 } random ] replicate all-equal? ] unit-test

[ 49 ] [ 50 random-bits* log2 ] unit-test

[ { 1 2 } 3 sample ] [ too-many-samples?  ] must-fail-with

[ 3 ] [ { 1 2 3 4 } 3 sample members length ] unit-test
[ 99 ] [ 100 iota 99 sample members length ] unit-test

[ ]
[ [ 100 random-bytes ] with-system-random drop ] unit-test

{ t }
[ 50000 [ .15 exponential-random-float ] replicate [ mean ] [ std ] bi .2 ~ ] unit-test

{ t }
[ 50000 [ 1 exponential-random-float ] replicate [ mean ] [ std ] bi .2 ~ ] unit-test

{ t t }
[
    50000 [ 1 3 pareto-random-float ] replicate [ mean ] [ std ] bi
    [ 1.5 .3 ~ ] [ 3 sqrt 2 / .3 ~ ] bi*
] unit-test
