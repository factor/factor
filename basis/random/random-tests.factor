USING: random sequences tools.test kernel math math.functions
sets grouping random.private ;
IN: random.tests

[ 4 ] [ 4 random-bytes length ] unit-test
[ 7 ] [ 7 random-bytes length ] unit-test

[ 4 ] [ [ 4 random-bytes length ] with-secure-random ] unit-test
[ 7 ] [ [ 7 random-bytes length ] with-secure-random ] unit-test

[ 2 ] [ V{ 10 20 30 } [ delete-random drop ] keep length ] unit-test
[ V{ } [ delete-random drop ] keep length ] must-fail

[ t ] [ 10000 [ 0 [ drop 187 random + ] reduce ] keep / 2 * 187 10 ~ ] unit-test
[ t ] [ 10000 [ 0 [ drop 400 random + ] reduce ] keep / 2 * 400 10 ~ ] unit-test

[ t ] [ 1000 [ 400 random ] replicate prune length 256 > ] unit-test

[ f ] [ 0 random ] unit-test

[ { } ] [ { } randomize ] unit-test
[ { 1 } ] [ { 1 } randomize ] unit-test

[ f ]
[ 100 [ { 0 1 } random ] replicate all-equal? ] unit-test

[ 49 ] [ 50 random-bits* log2 ] unit-test
