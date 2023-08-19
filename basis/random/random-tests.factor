USING: random sequences tools.test kernel math math.constants
math.functions sets grouping random.private math.statistics ;

{ 4 } [ 4 random-bytes length ] unit-test
{ 7 } [ 7 random-bytes length ] unit-test

{ 4 } [ [ 4 random-bytes length ] with-secure-random ] unit-test
{ 7 } [ [ 7 random-bytes length ] with-secure-random ] unit-test

{ 2 } [ V{ 10 20 30 } [ delete-random drop ] keep length ] unit-test
[ V{ } [ delete-random drop ] keep length ] must-fail

{ t } [ 10000 [ <iota> 0 [ drop 187 random + ] reduce ] keep / 2 * 187 10 ~ ] unit-test
{ t } [ 10000 [ <iota> 0 [ drop 400 random + ] reduce ] keep / 2 * 400 10 ~ ] unit-test

{ t } [ 1000 [ 400 random ] replicate members length 256 > ] unit-test

{ f } [ 0 random ] unit-test

{ { } } [ { } randomize ] unit-test
{ { 1 } } [ { 1 } randomize ] unit-test

{ f }
[ 100 [ { 0 1 } random ] replicate all-equal? ] unit-test

{ 49 } [ 50 random-bits* log2 ] unit-test

[ { 1 2 } 3 sample ] [ too-many-samples?  ] must-fail-with

{ 3 } [ { 1 2 3 4 } 3 sample members length ] unit-test
{ 99 } [ 100 <iota> 99 sample members length ] unit-test

{ }
[ [ 100 random-bytes ] with-system-random drop ] unit-test

{ t t }
[ 500000 [ 0 1 normal-random-float ] replicate [ mean 0 .2 ~ ] [ std 1 .2 ~ ] bi ] unit-test

{ t }
[ 500000 [ .15 exponential-random-float ] replicate [ mean ] [ std ] bi .2 ~ ] unit-test

{ t }
[ 500000 [ 1 exponential-random-float ] replicate [ mean ] [ std ] bi .2 ~ ] unit-test

{ t t }
[
    500000 [ 1 3 pareto-random-float ] replicate [ mean ] [ std ] bi
    [ 1.5 .5 ~ ] [ 3 sqrt 2 / .5 ~ ] bi*
] unit-test

{ t t }
[
    500000 [ 2 3 gamma-random-float ] replicate
    [ mean 6 .2 ~ ] [ std 2 sqrt 3 * .2 ~ ] bi
] unit-test

{ t t }
[
    500000 [ 2 3 beta-random-float ] replicate
    [ mean 2 2 3 + / .2 ~ ]
    [ std 2 sqrt 3 sqrt + 2 3 + dup 1 + sqrt * / .2 ~ ] bi
] unit-test

{ t }
[ 500000 [ 3 4 von-mises-random-float ] replicate mean 3 .2 ~ ] unit-test

{ t t }
[
    500000 [ 2 7 triangular-random-float ] replicate
    [ mean 2 7 + 2 / .2 ~ ] [ std 7 2 - 2 6 sqrt * / .2 ~ ] bi
] unit-test

{ t t }
[
    500000 [ 2 3 laplace-random-float ] replicate
    [ mean 2 .2 ~ ] [ std 2 sqrt 3 * .2 ~ ] bi
] unit-test

{ t t }
[
    500000 [ 12 rayleigh-random-float ] replicate
    [ mean pi 2 / sqrt 12 * .2 ~ ]
    [ std 2 pi 2 / - sqrt 12 * .2 ~ ] bi
] unit-test

{ t t }
[
    500000 [ 3 4 logistic-random-float ] replicate
    [ mean 3 .2 ~ ] [ std pi 4 * 3 sqrt / .2 ~ ] bi
] unit-test

{ t t }
[
    500000 [ 10 0.6 binomial-random ] replicate
    [ mean 6 .1 ~ ] [ std 1.5 .1 ~ ] bi
] unit-test

{ t t }
[
    500000 [ 100 0.8 binomial-random ] replicate
    [ mean 80 .1 ~ ] [ std 4 .1 ~ ] bi
] unit-test
